import 'package:flame/components.dart';
import '../game/avoid_the_bias_game.dart';

class BackgroundComponent extends SpriteComponent with HasGameRef<AvoidTheBiasGame> {
  BackgroundComponent()
      : super(
          size: Vector2(1600, 480),
          position: Vector2.zero(),
          priority: -10, // 제일 뒤에 깔리도록 설정
        );

  Future<void> setRound(int round) async {
    final filename = 'bg_$round.png'; // 예: bg_1.png
    sprite = await gameRef.loadSprite(filename);
  }
}
