import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/quiz_question.dart';

enum QuizDifficulty {
  beginner('Beginner', 'content/quiz/beginner.json', 'beginner'),
  intermediate('Intermediate', 'content/quiz/intermediate.json', 'intermediate'),
  advanced('Advanced', 'content/quiz/advanced.json', 'advanced');

  const QuizDifficulty(this.label, this.assetPath, this.jsonKey);

  final String label;
  final String assetPath;
  final String jsonKey;

  /// The next difficulty up, or null if this is already the top tier.
  QuizDifficulty? get next => switch (this) {
    QuizDifficulty.beginner => QuizDifficulty.intermediate,
    QuizDifficulty.intermediate => QuizDifficulty.advanced,
    QuizDifficulty.advanced => null,
  };
}

/// Loads the bundled quiz JSON and builds randomized 10-question attempts.
abstract final class QuizRepository {
  static final Map<QuizDifficulty, List<QuizQuestion>> _cache = {};

  static Future<List<QuizQuestion>> _loadPool(QuizDifficulty difficulty) async {
    final cached = _cache[difficulty];
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(difficulty.assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = (json[difficulty.jsonKey] as List)
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList();

    _cache[difficulty] = list;
    return list;
  }

  /// Samples 10 questions (no duplicates) from the difficulty's 30-question
  /// pool, and shuffles each question's answer options independently.
  static Future<List<QuizQuestion>> startAttempt(
    QuizDifficulty difficulty, {
    int questionCount = 10,
  }) async {
    final pool = await _loadPool(difficulty);
    final random = Random();

    final sampled = [...pool]..shuffle(random);
    return sampled.take(questionCount).map((question) {
      final shuffledOptions = [...question.options]..shuffle(random);
      return question.withShuffledOptions(shuffledOptions);
    }).toList();
  }
}
