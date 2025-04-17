// avoid_the_bias_game.dart
// 게임의 전체 흐름을 관리하는 Flame 게임 클래스입니다. 
// 플레이어, 장애물, 생명 HUD, 퀴즈 오버레이, SafeZone, 버튼 등 주요 구성 요소를 포함합니다.

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '../player/player_component.dart';
import '../hud/life_display.dart';
import '../hud/timer_bar.dart';
import '../component/discrimination_obstacle.dart';
import '../component/safe_zone.dart';
import '../overlay/quiz_overlay.dart';
import '../overlay/start_button_overlay.dart';

class AvoidTheBiasGame extends FlameGame with HasCollisionDetection {
  static const double screenWidth = 540;
  static const double screenHeight = 960;

  late PlayerComponent player;
  late LifeDisplay lifeDisplay;
  late TimerBar timerBar;
  SafeZone? safeZone;
  late ParallaxComponent background;

  int round = 1;
  final int maxRounds = 3;
  int lives = 3;
  late double roundTime;
  late double timeLeft;

  bool isQuizActive = false;
  bool roundCompleted = false;
  bool isGameStarted = false;
  bool isSafeZoneSpawned = false;

  final double scrollSpeed = 150; // 장애물 및 배경 스크롤 속도
  String? currentExplanation;

  final double obstacleSpawnRate = 2.0; // 장애물 생성 주기 (초)
  final int obstaclesPerSpawn = 1;
  double timeSinceLastSpawn = 0; // 장애물 생성 시간 누적값

  final double safeZoneSpawnDelay = 20.0; // SafeZone 생성 시점 (초)
  double timeElapsed = 0.0; // 라운드 경과 시간

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 배경 이미지 구성 (세로 반복)
    background = await ParallaxComponent.load(
      [ParallaxImageData('bg_$round.png')],
      repeat: ImageRepeat.repeatY,
      baseVelocity: Vector2(0, scrollSpeed),
      size: Vector2(size.x, scrollSpeed * getRoundTime(round) * 3),
    )..priority = -10;
    add(background);

    // 플레이어 생성 (가운데 하단 위치)
    player = PlayerComponent(position: Vector2(250, screenHeight - 100));
    add(player);

    // 생명 표시 HUD
    lifeDisplay = LifeDisplay(lives: lives)
      ..position = Vector2(screenWidth - 20, 40)
      ..anchor = Anchor.topRight
      ..priority = 100;
    add(lifeDisplay);

    // 타이머 바 HUD
    roundTime = getRoundTime(round);
    timerBar = TimerBar(totalTime: roundTime)
      ..position = Vector2(30, 40)
      ..anchor = Anchor.topLeft
      ..priority = 100;
    add(timerBar);

    // 왼쪽 버튼
    final leftButton = HudButtonComponent(
      button: CircleComponent(radius: 40, paint: Paint()..color = Colors.white.withOpacity(0.7)),
      buttonDown: CircleComponent(radius: 40, paint: Paint()..color = Colors.grey.shade400),
      position: Vector2(40, screenHeight - 50),
      onPressed: () => player.moveLeftPressed = true,
      onReleased: () => player.moveLeftPressed = false,
    )..priority = 101;
    add(leftButton);

    // 오른쪽 버튼
    final rightButton = HudButtonComponent(
      button: CircleComponent(radius: 40, paint: Paint()..color = Colors.white.withOpacity(0.7)),
      buttonDown: CircleComponent(radius: 40, paint: Paint()..color = Colors.grey.shade400),
      position: Vector2(screenWidth - 100, screenHeight - 50),
      onPressed: () => player.moveRightPressed = true,
      onReleased: () => player.moveRightPressed = false,
    )..priority = 101;
    add(rightButton);

    timeLeft = roundTime;
    initializeOverlays();
    overlays.add('StartButtonOverlay'); // 게임 시작 전 버튼
  }

  void initializeOverlays() {
    overlays.addEntry('StartButtonOverlay', (_, game) => StartButtonOverlay(gameRef: game as AvoidTheBiasGame));
    overlays.addEntry('QuizOverlay', (_, game) => QuizOverlay(gameRef: game as AvoidTheBiasGame));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameStarted) return;

    if (!isQuizActive && !roundCompleted) {
      timeLeft -= dt;
      timeElapsed += dt;
      timerBar.updateTime(timeLeft);
      if (timeLeft <= 0) endGame();
      if (timeElapsed >= safeZoneSpawnDelay && !isSafeZoneSpawned) spawnSafeZone();

      timeSinceLastSpawn += dt;
      if (timeSinceLastSpawn >= obstacleSpawnRate) {
        timeSinceLastSpawn = 0;
        _spawnObstacles();
      }

      for (final obs in children.whereType<DiscriminationObstacle>()) {
        obs.position.y += scrollSpeed * dt;
        if (obs.position.y > screenHeight + 100) obs.removeFromParent();
      }

      if (safeZone != null) safeZone!.position.y += scrollSpeed * dt;
    }
  }

  void startGame() {
    isGameStarted = true;
    timeElapsed = 0.0;
    isSafeZoneSpawned = false;
    overlays.remove('StartButtonOverlay');
    _initialObstacleSetup();
  }

  void _initialObstacleSetup() {
    for (int row = 0; row < 3; row++) {
      for (int i = 0; i < 2; i++) {
        final rand = Random();
        final minX = 100.0, maxX = 440.0;
        final x = minX + rand.nextDouble() * (maxX - minX);
        final obs = DiscriminationObstacle.randomObstacle(x - 20, x + 20);
        obs.position.y = -200.0 - (row * 250) - rand.nextDouble() * 50;
        add(obs);
      }
    }
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

  void _spawnObstacles() {
    _spawnSingleObstacleAtTop();
  }

  void _spawnSingleObstacleAtTop() {
    final rand = Random();
    final minX = 100.0, maxX = 440.0;
    final x = minX + rand.nextDouble() * (maxX - minX);
    final obs = DiscriminationObstacle.randomObstacle(x - 20, x + 20);
    final offset = rand.nextDouble() * 30;
    obs.position.y = -obs.size.y - offset;
    add(obs);
  }

  void spawnSafeZone() {
    if (isSafeZoneSpawned) return;
    isSafeZoneSpawned = true;
    safeZone = SafeZone(Vector2(250.0, -100.0));
    add(safeZone!);
  }

  /// 퀴즈를 호출하고 게임을 일시정지
  void triggerQuiz({required String explanation}) {
    if (isQuizActive) return;
    pauseEngine();
    isQuizActive = true;
    currentExplanation = explanation;
    overlays.add('QuizOverlay');
  }

  /// 퀴즈 정답 처리 및 설명 팝업 → 엔진 재시작
  void resolveQuiz(bool correct) {
    overlays.remove('QuizOverlay');
    isQuizActive = false;

    if (!correct) {
      lives -= 1;
      lifeDisplay.updateLives(lives);
      if (lives <= 0) {
        endGame();
        return;
      }
      final explanationToShow = currentExplanation;
      if (explanationToShow != null) {
        showDialog(
          context: buildContext!,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('설명'),
            content: Text(explanationToShow),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(buildContext!);
                  resumeEngine();
                },
                child: const Text('확인'),
              )
            ],
          ),
        );
      } else {
        resumeEngine();
      }
    } else {
      resumeEngine();
    }
    currentExplanation = null;
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(buildContext!),
              child: const Text('확인'),
            )
          ],
        ),
      );
    } else {
      round += 1;
      roundCompleted = true;
      Future.delayed(const Duration(seconds: 2), () {
        resetRound();
      });
    }
  }

  void resetRound() {
    children.whereType<DiscriminationObstacle>().forEach((c) => c.removeFromParent());
    if (safeZone != null) {
      safeZone!.removeFromParent();
      safeZone = null;
    }
    player.position = Vector2(250, screenHeight - 100);
    roundTime = getRoundTime(round);
    timeLeft = roundTime;
    timerBar.resetTime(timeLeft);
    background.parallax?.baseVelocity = Vector2(0, scrollSpeed);
    roundCompleted = false;
    isSafeZoneSpawned = false;
    timeElapsed = 0.0;
    timeSinceLastSpawn = 0;
    _initialObstacleSetup();
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