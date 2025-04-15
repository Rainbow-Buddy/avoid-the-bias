import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../game/avoid_the_bias_game.dart';
import '../player/player_component.dart';

class DiscriminationObstacle extends SpriteComponent
    with CollisionCallbacks, HasGameRef<AvoidTheBiasGame> {
  DiscriminationObstacle({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final List<String> sprites = [
      'obstacle_1.png',
      'obstacle_2.png',
      'obstacle_3.png',
    ];
    sprites.shuffle();
    try {
      sprite = await gameRef.loadSprite(sprites.first);
      debugPrint('✅ obstacle sprite loaded: ${sprites.first}');
    } catch (e) {
      debugPrint('❌ Failed to load obstacle sprite: $e');
    }

    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      removeFromParent();
      gameRef.triggerQuiz();
    }
  }

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);
  //   final paint = Paint()..color = const Color(0xFFEF5350);
  //   canvas.drawRect(size.toRect(), paint);
  // }

  static DiscriminationObstacle randomObstacle(double minX, double maxX) {
    final rand = Random();
    final double x = minX + rand.nextDouble() * (maxX - minX);
    final double y = 300 + rand.nextDouble() * 130;  // y 위치 다양화

    final double width = 40 + rand.nextDouble() * 40;
    final double height = width * 0.75;

    return DiscriminationObstacle(
      position: Vector2(x, y),
      size: Vector2(width, height),
    );
  }
}