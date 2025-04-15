import 'dart:convert';
import 'package:flutter/services.dart';

class QuizEntry {
  final String question;
  final bool answer;
  final String? explanation;

  QuizEntry({required this.question, required this.answer, this.explanation});

  factory QuizEntry.fromJson(Map<String, dynamic> json) => QuizEntry(
        question: json['question'],
        answer: json['answer'],
        explanation: json['explanation'],
      );
}

class QuizLoader {
  static List<QuizEntry>? _cachedQuizzes;

  static Future<QuizEntry> loadRandomQuiz() async {
    _cachedQuizzes ??= await _loadQuizList();
    _cachedQuizzes!.shuffle();
    return _cachedQuizzes!.first;
  }

  static Future<List<QuizEntry>> _loadQuizList() async {
    final jsonString = await rootBundle.loadString('assets/quiz/quiz_questions_ko.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((e) => QuizEntry.fromJson(e)).toList();
  }
}