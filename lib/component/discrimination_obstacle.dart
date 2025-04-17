import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/animation.dart';
import 'package:flame/effects.dart';
import 'package:flutter/foundation.dart';
import '../game/avoid_the_bias_game.dart';
import '../player/player_component.dart';

/// 장애물 컴포넌트 클래스. 장애물 스프라이트와 충돌 로직, 크기 설정 등을 담당한다.
class DiscriminationObstacle extends SpriteComponent
    with CollisionCallbacks, HasGameRef<AvoidTheBiasGame> {
  // 장애물 최소/최대 너비와 세로 비율
  static const double minWidth = 30.0;
  static const double maxWidth = 50.0;
  static const double aspectRatio = 1.0;

  // 충돌 시 중복 퀴즈 트리거를 방지하기 위한 플래그
  bool hasTriggered = false;

  /// 생성자: 위치와 크기를 지정
  DiscriminationObstacle({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  /// 컴포넌트 로드 시 스프라이트 로딩 및 히트박스, 이펙트 설정
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprites = ['obstacle_1.png', 'obstacle_2.png', 'obstacle_3.png'];
    sprites.shuffle();
    try {
      sprite = await gameRef.loadSprite(sprites.first);
      debugPrint('✅ obstacle sprite loaded: ${sprites.first}');
    } catch (e) {
      debugPrint('❌ Failed to load obstacle sprite: $e');
    }
    add(RectangleHitbox());

    // 심장박동처럼 커졌다 작아지는 애니메이션 효과
    add(
      ScaleEffect.to(
        Vector2(0.8, 0.8),
        EffectController(
          duration: 0.5,
          reverseDuration: 0.5,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  /// 플레이어와 충돌 시 퀴즈 트리거
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // 이미 퀴즈를 발생시켰다면 무시
    if (hasTriggered) return;

    if (other is PlayerComponent) {
      hasTriggered = true; // 중복 방지
      removeFromParent();

      // 간단한 테스트용 설명. 실제 구현에서는 JSON 데이터에서 설명을 받아야 함
      gameRef.triggerQuiz(explanation: '성소수자에 대한 포괄적 성교육은 청소년의 건강한 성장에 도움이 됩니다.');
    }
  }

  /// 랜덤 위치 및 크기로 장애물을 생성하는 팩토리 메서드
  static DiscriminationObstacle randomObstacle(double minX, double maxX) {
    final rand = Random();
    final width = minWidth + rand.nextDouble() * (maxWidth - minWidth);
    final height = width * aspectRatio;
    final x = minX + rand.nextDouble() * (maxX - minX);
    return DiscriminationObstacle(
      position: Vector2(x, -height),
      size: Vector2(width, height),
    );
  }
}