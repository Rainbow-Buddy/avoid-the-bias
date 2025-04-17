import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../game/avoid_the_bias_game.dart';
import '../player/player_component.dart';

class SafeZone extends SpriteComponent
    with HasGameRef<AvoidTheBiasGame>, CollisionCallbacks {
  static const double _zoneSize = 80.0;
  
  // 결승선 컴포넌트
  late FinishLine _finishLine;

  SafeZone(Vector2 position)
      : super(
          position: position, size: Vector2(80, 80)
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 결승선 먼저 추가 (스프라이트보다 낮은 레이어)
    _finishLine = FinishLine();
    add(_finishLine);

    // 히트박스 크기를 결승선 크기로 확장 (가로 540px)
    add(RectangleHitbox(
      size: Vector2(540, 80),
      position: Vector2((_finishLine.width - 80) / -2, 0),
      isSolid: true,
      // 디버그 모드에서 히트박스 가시화 (필요시 주석 해제)
      // debugMode: true,
    ));

    // Load the safe zone sprite
    try {
      sprite = await gameRef.loadSprite('safe_zone.png');
      debugPrint('✅ safe_zone sprite loaded');
    } catch (e) {
      debugPrint('❌ Failed to load safe_zone sprite: $e');
    }

    // Position at the top-middle of the map
    position = Vector2(
      (gameRef.size.x - _zoneSize) / 2,
      0,
    );
    
    debugPrint('✅ SafeZone 설정 완료: position=$position, size=$size');
  }

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);
  //   // Optional: draw a colored overlay
  //   final paint = Paint()..color = const Color(0xFF81C784);
  //   canvas.drawRect(size.toRect(), paint);
  // }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && !gameRef.roundCompleted) {
      debugPrint('💥 플레이어와 SafeZone 충돌 감지! 라운드 완료 처리');
      gameRef.handleSafeZoneReached();
    }
  }
}

/// 결승선 컴포넌트
class FinishLine extends PositionComponent {
  static const double _width = 540.0;
  static const double _height = 80.0;
  
  FinishLine() : super(size: Vector2(_width, _height), priority: -9);  // 배경(-10) 바로 위, 스프라이트(0)보다 아래
  
  @override
  void onMount() {
    super.onMount();
    // 부모 컴포넌트(SafeZone)와 위치 동기화
    final safeZone = parent as SafeZone;
    position = Vector2(
      (safeZone.width - width) / 2,  // 가운데 정렬
      0,  // 상단에 위치
    );
    
    debugPrint('✅ 결승선 설정 완료: position=$position, size=$size');
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // 반투명한 초록색 결승선
    final paint = Paint()
      ..color = const Color(0x8045C048)  // 반투명(0x80) 초록색
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(size.toRect(), paint);
    
    // 결승선 테두리
    final borderPaint = Paint()
      ..color = const Color(0xAA258C25)  // 더 진한 초록색 테두리
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(size.toRect(), borderPaint);
  }
}
