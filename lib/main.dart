import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/avoid_the_bias_game.dart';
import 'overlay/quiz_overlay.dart';
import 'overlay/start_button_overlay.dart';

void main() {
  runApp(const AvoidTheBiasApp());
}

class AvoidTheBiasApp extends StatelessWidget {
  const AvoidTheBiasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = AvoidTheBiasGame();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            'QuizOverlay': (context, game) =>
                QuizOverlay(gameRef: game as AvoidTheBiasGame),
            'StartButtonOverlay': (context, game) =>
                StartButtonOverlay(gameRef: game as AvoidTheBiasGame),
          },
        ),
      ),
    );
  }
}
