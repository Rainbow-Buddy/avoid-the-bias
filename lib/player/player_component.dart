import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../game/avoid_the_bias_game.dart';
import 'package:flutter/material.dart';

class PlayerComponent extends SpriteComponent
    with HasGameRef<AvoidTheBiasGame> {
  final double moveSpeed = 200;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = true;

  PlayerComponent({required Vector2 position})
      : super(position: position, size: Vector2(48, 48));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      sprite = await gameRef.loadSprite('player.png');
      add(RectangleHitbox());
      debugPrint('✅ player sprite loaded');
    } catch (e) {
      debugPrint('❌ Failed to load player sprite: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 조이스틱 방향 받아오기
    final direction = gameRef.joystick.delta.normalized();
    velocity = direction * moveSpeed;
    position += velocity * dt;

    // 중력 적용은 점프와 지면 충돌 여부에 따라 병합 필요
    if (!isOnGround) {
      velocity.y += 600 * dt; // gravity
    }

    if (position.y >= 400) {
      position.y = 400;
      velocity.y = 0;
      isOnGround = true;
    }
  }

  void jump() {
    if (isOnGround) {
      velocity.y = -300;
      isOnGround = false;
    }
  }

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);
  //   // 디버깅용 색상 박스
  //   final paint = Paint()..color = const Color(0xFF42A5F5);
  //   canvas.drawRect(size.toRect(), paint);
  // }
}