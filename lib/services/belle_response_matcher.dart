import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/belle_topic.dart';

/// Where a [BelleReply] came from — useful for tests and for any future UI
/// that wants to treat a redirect differently from a real answer.
enum BelleReplySource {
  topic,
  noMatch,
  financialAdviceAttempt,
  altcoinQuestion,
  quizQuestionDetected,
}

class BelleReply {
  const BelleReply({required this.text, required this.source, this.topicId});

  final String text;
  final BelleReplySource source;

  /// The matched topic's id, set only when [source] is [BelleReplySource.topic].
  final String? topicId;
}

/// Matches free-text user input against Belle's scripted topic responses.
///
/// Fully offline: no network calls, no API keys, nothing to configure. This
/// replaced an earlier plan to have Belle call an LLM through a backend
/// proxy — see the root README's Belle-content note and
/// backend/belle-proxy/README.md for why that direction was shelved (avoids
/// ongoing API cost entirely, at the cost of Belle only being able to
/// discuss the topics she's been scripted for).
class BelleResponseMatcher {
  const BelleResponseMatcher(this._content);

  final BelleScriptedContent _content;

  static const _assetPath = 'content/belle/belle_scripted_responses.json';

  static BelleResponseMatcher? _cached;

  /// Loads and parses the bundled scripted-response JSON, caching the
  /// result — same pattern as QuizRepository's pool cache, since this
  /// content is static for the lifetime of the app process.
  static Future<BelleResponseMatcher> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(_assetPath);
    final content = BelleScriptedContent.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    final matcher = BelleResponseMatcher(content);
    _cached = matcher;
    return matcher;
  }

  /// Phrasing that signals the user wants a buy/sell/timing call, not an
  /// explanation. Checked *before* topic matching — see system_prompt.md's
  /// "No financial advice" guardrail, which this preserves as a hard rule
  /// even without a live LLM to apply it contextually: a question like
  /// "should I invest in Lightning?" should get redirected, not answered
  /// as if it were just a Lightning question.
  static const _financialAdvicePhrases = [
    'should i buy',
    'should i sell',
    'should i invest',
    'is now a good time',
    'good time to buy',
    'good time to sell',
    'good time to invest',
  ];

  /// Deliberately full coin names, not bare 2-3 letter tickers ("eth",
  /// "sol", "dot", "ada" are all excluded) — those collide too easily with
  /// ordinary English words ("method" contains "eth", "console" contains
  /// "sol") to substring-match "reasonably" the way this brief asks for.
  static const _altcoinTerms = [
    'ethereum',
    'dogecoin',
    'litecoin',
    'cardano',
    'solana',
    'polkadot',
    'binance coin',
    'bnb',
    'shiba inu',
    'monero',
    'xmr',
    'tether',
    'usdt',
    'xrp',
    'altcoin',
    'altcoins',
    'other cryptocurrenc', // covers "cryptocurrency" and "cryptocurrencies"
    'other crypto',
  ];

  /// Matches [input] against Belle's scripted topics, in three passes:
  /// financial-advice phrasing, then a known-altcoin mention, then topic
  /// keywords — first match wins, falling back to `no_match` if nothing
  /// hits. Case-insensitive; matches on substring containment, so
  /// "what's a utxo" matches the "utxo" keyword even embedded in a longer
  /// sentence.
  ///
  /// Deliberately does not attempt to detect a pasted quiz question
  /// (`quiz_question_detected` in the content, exposed but unused here) —
  /// reliably telling "a real quiz question" apart from "a question that
  /// happens to be phrased like one" from free text alone isn't something
  /// simple keyword matching can do "reasonably," and quizzes already have
  /// their own dedicated screens where answers aren't typed into chat.
  BelleReply match(String input) {
    final normalized = input.toLowerCase();

    if (_financialAdvicePhrases.any(normalized.contains)) {
      return BelleReply(
        text: _content.fallback.financialAdviceAttempt,
        source: BelleReplySource.financialAdviceAttempt,
      );
    }

    if (_altcoinTerms.any(normalized.contains)) {
      return BelleReply(
        text: _content.fallback.altcoinQuestion,
        source: BelleReplySource.altcoinQuestion,
      );
    }

    for (final topic in _content.topics) {
      final matches = topic.keywords.any(
        (keyword) => normalized.contains(keyword.toLowerCase()),
      );
      if (matches) {
        return BelleReply(
          text: topic.response,
          source: BelleReplySource.topic,
          topicId: topic.id,
        );
      }
    }

    return BelleReply(
      text: _content.fallback.noMatch,
      source: BelleReplySource.noMatch,
    );
  }
}
