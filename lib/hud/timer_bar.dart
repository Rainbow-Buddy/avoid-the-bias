import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TimerBar extends PositionComponent {
  final double totalTime;
  double currentTime;

  @override
  final double width = 200;

  @override
  final double height = 16;

  TimerBar({required this.totalTime}) : currentTime = totalTime {
    position = Vector2(10, 10);
    size = Vector2(width, height);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final background = Paint()..color = Colors.grey.shade300;
    final foreground = Paint()..color = Colors.lightBlue;

    canvas.drawRect(size.toRect(), background);

    final ratio = (currentTime / totalTime).clamp(0.0, 1.0);
    final filledWidth = width * ratio;
    canvas.drawRect(Rect.fromLTWH(0, 0, filledWidth, height), foreground);
  }

  void updateTime(double time) {
    currentTime = time;
  }

  void resetTime(double time) {
    currentTime = time;
  }
}
