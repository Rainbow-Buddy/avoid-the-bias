import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game/avoid_the_bias_game.dart';
import '../player/player_component.dart';

class SafeZone extends SpriteComponent
    with HasGameRef<AvoidTheBiasGame>, CollisionCallbacks {
  SafeZone(Vector2 position)
      : super(position: position, size: Vector2(80, 80));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      sprite = await gameRef.loadSprite('safe_zone.png');
      debugPrint('✅ safe_zone sprite loaded');
    } catch (e) {
      debugPrint('❌ Failed to load safe_zone sprite: $e');
    }
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF81C784); // 연두색
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && !gameRef.roundCompleted) {
      gameRef.handleSafeZoneReached();
    }
  }
}