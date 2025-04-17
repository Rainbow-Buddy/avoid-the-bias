import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../game/avoid_the_bias_game.dart';
import 'package:flutter/material.dart';

class PlayerComponent extends SpriteComponent with HasGameRef<AvoidTheBiasGame> {
  /// Horizontal move speed in pixels per second
  final double moveSpeed = 220;

  /// Velocity vector used each frame
  Vector2 velocity = Vector2.zero();

  /// Flags set by HUD buttons for left/right input
  bool moveLeftPressed = false;
  bool moveRightPressed = false;

  /// 이전 프레임의 방향을 저장하여 버튼 오작동시에도 부드럽게 처리
  double prevDirection = 0;

  /// 경계에 도달했는지 확인하는 변수
  bool isAtLeftBoundary = false;
  bool isAtRightBoundary = false;

  PlayerComponent({required Vector2 position})
      : super(position: position, size: Vector2(70, 70));

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

    // 경계 상태 업데이트
    isAtLeftBoundary = position.x <= 0;
    isAtRightBoundary = position.x >= gameRef.size.x - size.x;

    // 터치 입력 처리 개선
    double dx = 0;
    if (moveLeftPressed && !isAtLeftBoundary) dx -= 1;
    if (moveRightPressed && !isAtRightBoundary) dx += 1;
    
    // 반대 방향 동시 입력시 이전 방향 유지 (부드러운 움직임 위해)
    if (moveLeftPressed && moveRightPressed) {
      dx = prevDirection;
    } else {
      prevDirection = dx;
    }

    // 이동 속도에 가속도 효과 적용 (부드러운 이동)
    double targetVelocityX = dx * moveSpeed;
    double currentVelocityX = velocity.x;
    
    // 부드러운 가속/감속 적용
    if (targetVelocityX != currentVelocityX) {
      double acceleration = 1500.0 * dt; // 가속도 조정
      if (targetVelocityX > currentVelocityX) {
        velocity.x = (currentVelocityX + acceleration).clamp(-moveSpeed, moveSpeed);
      } else {
        velocity.x = (currentVelocityX - acceleration).clamp(-moveSpeed, moveSpeed);
      }
    }
    
    // 적용된 속도로 이동
    position.add(velocity * dt);

    // 화면 경계 제한
    position.x = position.x.clamp(0, gameRef.size.x - size.x);

    // 수직 위치 고정
    position.y = gameRef.size.y - size.y - 50;
  }
}
