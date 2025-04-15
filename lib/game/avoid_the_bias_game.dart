import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../player/player_component.dart';
import '../hud/life_display.dart';
import '../hud/timer_bar.dart';
import '../component/discrimination_obstacle.dart';
import '../component/safe_zone.dart';
import '../component/background_component.dart';

class AvoidTheBiasGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late PlayerComponent player;
  late LifeDisplay lifeDisplay;
  late TimerBar timerBar;
  late CameraComponent cameraComponent;
  late JoystickComponent joystick;
  late BackgroundComponent background;

  int round = 1;
  int maxRounds = 3;
  int lives = 3;
  double roundTime = 60;
  late double timeLeft;

  bool isQuizActive = false;
  bool roundCompleted = false;

  static const double screenWidth = 540;
  static const double screenHeight = 960;
  static const double worldWidth = 1600;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    background = BackgroundComponent();
    await add(background);
    await background.setRound(round);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 15, paint: Paint()..color = Colors.grey),
      background: CircleComponent(radius: 40, paint: Paint()..color = Colors.black26),
      margin: const EdgeInsets.only(left: 40, bottom: 80),
    )..priority = 100;
    add(joystick);

    player = PlayerComponent(position: Vector2(50, 400));
    world.add(player);

    cameraComponent = CameraComponent.withFixedResolution(
      world: world,
      width: screenWidth,
      height: screenHeight,
    );
    add(cameraComponent);
    camera = cameraComponent;
    camera.follow(player);

    lifeDisplay = LifeDisplay(lives: lives)
      ..priority = 100
      ..position = Vector2(size.x - 20, 20)
      ..anchor = Anchor.topRight;
    add(lifeDisplay);

    roundTime = getRoundTime(round);
    timerBar = TimerBar(totalTime: roundTime)
      ..priority = 100
      ..position = Vector2(20, 20)
      ..anchor = Anchor.topLeft;
    add(timerBar);

    spawnObstacles();
    spawnSafeZone();

    timeLeft = roundTime;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isQuizActive && !roundCompleted) {
      timeLeft -= dt;
      timerBar.updateTime(timeLeft);

      if (timeLeft <= 0) {
        endGame();
      }
    }

    player.position.x = player.position.x.clamp(0, worldWidth - player.size.x);
    player.position.y = player.position.y.clamp(0, screenHeight - player.size.y);
  }

  double getRoundTime(int round) {
    switch (round) {
      case 1:
        return 60.0;
      case 2:
        return 45.0;
      case 3:
        return 30.0;
      default:
        return 30.0;
    }
  }

  void spawnObstacles() {
    const double minX = 300;
    const double maxX = 1500;
    int baseCount = 15;
    int count = (baseCount * pow(1.3, round - 1).toDouble()).round();

    for (int i = 0; i < count; i++) {
      final double x = minX + Random().nextDouble() * (maxX - minX);
      final double y = 280 + Random().nextDouble() * 150;
      world.add(DiscriminationObstacle.randomObstacle(x, y));
    }
  }

  void spawnSafeZone() {
    final safeZone = SafeZone(Vector2(worldWidth - 100, 400));
    world.add(safeZone);
  }

  void triggerQuiz() async {
    isQuizActive = true;
    overlays.add('QuizOverlay');
  }

  void resolveQuiz(bool correct) {
    overlays.remove('QuizOverlay');
    isQuizActive = false;

    if (!correct) {
      lives -= 1;
      lifeDisplay.updateLives(lives);
      if (lives <= 0) {
        endGame();
      }
    }
  }

  void handleSafeZoneReached() {
    roundCompleted = true;
    pauseEngine();
    showDialog(
      context: buildContext!,
      builder: (_) => AlertDialog(
        title: const Text('축하합니다!'),
        content: const Text('안전하게 친구에게 도착했어요!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(buildContext!);
              resumeEngine();
              completeRound();
            },
            child: const Text('다음 라운드'),
          )
        ],
      ),
    );
  }

  void completeRound() {
    if (round >= maxRounds) {
      pauseEngine();
      showDialog(
        context: buildContext!,
        builder: (_) => AlertDialog(
          title: const Text('게임 종료'),
          content: const Text('모든 라운드를 클리어했습니다!'),
          actions: [TextButton(onPressed: () => Navigator.pop(buildContext!), child: const Text('확인'))],
        ),
      );
    } else {
      round++;
      roundCompleted = true;
      Future.delayed(const Duration(seconds: 2), () {
        resetRound();
      });
    }
  }

  void resetRound() async {
    world.children.whereType<DiscriminationObstacle>().forEach(world.remove);
    player.position = Vector2(50, 400);
    roundTime = getRoundTime(round);
    timeLeft = roundTime;
    timerBar.resetTime(timeLeft);
    spawnObstacles();
    spawnSafeZone();
    await background.setRound(round);
    roundCompleted = false;
  }

  void endGame() {
    pauseEngine();
    showDialog(
      context: buildContext!,
      builder: (_) => AlertDialog(
        title: const Text('게임 종료'),
        content: const Text('생명이 모두 소진되었습니다.'),
        actions: [TextButton(onPressed: () => Navigator.pop(buildContext!), child: const Text('닫기'))],
      ),
    );
  }
}
