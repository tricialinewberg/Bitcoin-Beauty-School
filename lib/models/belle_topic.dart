/// One scripted Bitcoin topic Belle can respond to, as authored in
/// content/belle/belle_scripted_responses.json.
class BelleTopic {
  const BelleTopic({
    required this.id,
    required this.tier,
    required this.keywords,
    required this.response,
  });

  final String id;
  final String tier;
  final List<String> keywords;
  final String response;

  factory BelleTopic.fromJson(Map<String, dynamic> json) => BelleTopic(
    id: json['id'] as String,
    tier: json['tier'] as String,
    keywords: (json['keywords'] as List).cast<String>(),
    response: json['response'] as String,
  );
}

/// The 4 canned replies Belle falls back to outside a matched topic — see
/// content/belle/belle_scripted_responses.json's "fallback" object.
class BelleFallbackResponses {
  const BelleFallbackResponses({
    required this.noMatch,
    required this.financialAdviceAttempt,
    required this.altcoinQuestion,
    required this.quizQuestionDetected,
  });

  final String noMatch;
  final String financialAdviceAttempt;
  final String altcoinQuestion;
  final String quizQuestionDetected;

  factory BelleFallbackResponses.fromJson(Map<String, dynamic> json) =>
      BelleFallbackResponses(
        noMatch: json['no_match'] as String,
        financialAdviceAttempt: json['financial_advice_attempt'] as String,
        altcoinQuestion: json['altcoin_question'] as String,
        quizQuestionDetected: json['quiz_question_detected'] as String,
      );
}

/// The full parsed contents of belle_scripted_responses.json.
class BelleScriptedContent {
  const BelleScriptedContent({required this.topics, required this.fallback});

  final List<BelleTopic> topics;
  final BelleFallbackResponses fallback;

  factory BelleScriptedContent.fromJson(Map<String, dynamic> json) =>
      BelleScriptedContent(
        topics: (json['topics'] as List)
            .map((t) => BelleTopic.fromJson(t as Map<String, dynamic>))
            .toList(),
        fallback: BelleFallbackResponses.fromJson(
          json['fallback'] as Map<String, dynamic>,
        ),
      );
}
