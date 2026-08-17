/// One answer choice as authored in the JSON. [originalId] is the
/// authoring-time letter (A-D) and stays fixed even after the option list
/// is shuffled for display — correctness is checked against it, not
/// against whatever letter badge ends up on screen.
class QuizAnswerOption {
  const QuizAnswerOption({required this.originalId, required this.text});

  final String originalId;
  final String text;

  factory QuizAnswerOption.fromJson(Map<String, dynamic> json) {
    return QuizAnswerOption(
      originalId: json['id'] as String,
      text: json['text'] as String,
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionId,
  });

  final String id;
  final String question;
  final List<QuizAnswerOption> options;
  final String correctOptionId;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((o) => QuizAnswerOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      correctOptionId: json['correct'] as String,
    );
  }

  /// A copy with the options in a new order — used to randomize which
  /// position the correct answer appears in for a given attempt.
  QuizQuestion withShuffledOptions(List<QuizAnswerOption> shuffled) {
    return QuizQuestion(
      id: id,
      question: question,
      options: shuffled,
      correctOptionId: correctOptionId,
    );
  }
}
