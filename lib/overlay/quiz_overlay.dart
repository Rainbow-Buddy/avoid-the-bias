import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/avoid_the_bias_game.dart';

class QuizOverlay extends StatefulWidget {
  final AvoidTheBiasGame gameRef;

  const QuizOverlay({super.key, required this.gameRef});

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> {
  String question = '';
  bool? answer;

  @override
  void initState() {
    super.initState();
    loadRandomQuiz();
  }

  Future<void> loadRandomQuiz() async {
    final jsonString = await rootBundle.loadString('assets/quiz/quiz_questions_ko.json');
    final List<dynamic> quizList = jsonDecode(jsonString);
    quizList.shuffle();
    final selected = quizList.first;
    setState(() {
      question = selected['question'];
      answer = selected['answer'];
    });
  }

  void handleAnswer(bool selected) {
    final isCorrect = (selected == answer);
    widget.gameRef.resolveQuiz(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(179, 119, 63, 137),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                question,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => handleAnswer(true),
                    child: const Text('O', style: TextStyle(fontSize: 20)),
                  ),
                  ElevatedButton(
                    onPressed: () => handleAnswer(false),
                    child: const Text('X', style: TextStyle(fontSize: 20)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}