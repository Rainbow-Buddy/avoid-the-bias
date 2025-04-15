import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LifeDisplay extends PositionComponent {
  int lives;
  final double iconSize = 24;
  final double spacing = 8;

  LifeDisplay({required this.lives}) {
    position = Vector2(700, 10);
    size = Vector2(100, iconSize);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.red;
    for (int i = 0; i < lives; i++) {
      final x = i * (iconSize + spacing);
      canvas.drawCircle(Offset(x + iconSize / 2, iconSize / 2), iconSize / 2, paint);
    }
  }

  void updateLives(int newLives) {
    lives = newLives;
  }
}