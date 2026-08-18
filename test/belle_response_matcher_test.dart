import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/models/belle_topic.dart';
import 'package:bitcoin_beauty_school/services/belle_response_matcher.dart';

// Reads the real bundled JSON straight off disk (dart:io) rather than via
// rootBundle — this keeps these as plain, fast `test()` cases with no
// Flutter test-binding dependency (matching nostr_keys_test.dart /
// nip17_chat_test.dart's style), while still exercising the actual
// production content rather than a hand-rolled fixture, so these tests
// stay meaningful as content/belle/belle_scripted_responses.json evolves.
BelleResponseMatcher _loadMatcher() {
  final raw = File(
    'content/belle/belle_scripted_responses.json',
  ).readAsStringSync();
  final content = BelleScriptedContent.fromJson(
    jsonDecode(raw) as Map<String, dynamic>,
  );
  return BelleResponseMatcher(content);
}

void main() {
  final matcher = _loadMatcher();

  group('matches all 15 scripted topics', () {
    const cases = {
      'satoshi': "what's a satoshi?",
      'wallets': 'how does a wallet work?',
      'blockchain_basics': 'how does bitcoin work',
      'custody': 'what does self custody mean?',
      'utxos': "what's a utxo",
      'mempool': 'what is the mempool',
      'lightning_basics': 'explain lightning network to me',
      'multisig': 'what is multisig',
      'nodes_vs_miners': 'what is a full node',
      'taproot': 'explain taproot',
      'schnorr': 'what is a schnorr signature',
      'bips': 'what is a bip',
      'lightning_routing': 'what is an htlc',
      'privacy_coinjoin': 'what is coinjoin',
      'consensus_mechanics': 'what is proof of work',
    };

    for (final entry in cases.entries) {
      test('"${entry.value}" matches topic ${entry.key}', () {
        final reply = matcher.match(entry.value);
        expect(reply.source, BelleReplySource.topic);
        expect(reply.topicId, entry.key);
        expect(reply.text, isNotEmpty);
      });
    }

    test('every topic in the content file is covered by a case above', () {
      final content = BelleScriptedContent.fromJson(
        jsonDecode(
              File(
                'content/belle/belle_scripted_responses.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>,
      );
      expect(content.topics.length, cases.length);
      expect(content.topics.map((t) => t.id).toSet(), cases.keys.toSet());
    });
  });

  group('case-insensitive and partial matching', () {
    test('matches regardless of case', () {
      final reply = matcher.match("WHAT'S A UTXO?");
      expect(reply.topicId, 'utxos');
    });

    test('matches a keyword embedded in a longer sentence', () {
      final reply = matcher.match(
        "Hey Belle, quick question - what's a satoshi anyway?",
      );
      expect(reply.topicId, 'satoshi');
    });
  });

  group('fallback cases', () {
    test('no_match for input matching no topic or special phrasing', () {
      final reply = matcher.match('what is your favorite color');
      expect(reply.source, BelleReplySource.noMatch);
      expect(reply.text, isNotEmpty);
    });

    test('financial_advice_attempt for buy/sell/timing phrasing', () {
      for (final input in [
        'should I buy bitcoin right now?',
        'should i sell my bitcoin',
        'should I invest my savings in bitcoin',
        'is now a good time to get in?',
      ]) {
        final reply = matcher.match(input);
        expect(
          reply.source,
          BelleReplySource.financialAdviceAttempt,
          reason: 'input: $input',
        );
      }
    });

    test('altcoin_question for a known altcoin mention', () {
      for (final input in [
        'what do you think about ethereum',
        'is dogecoin a good bitcoin alternative',
        'tell me about litecoin',
      ]) {
        final reply = matcher.match(input);
        expect(
          reply.source,
          BelleReplySource.altcoinQuestion,
          reason: 'input: $input',
        );
      }
    });

    test(
      'financial-advice phrasing takes priority over a topic match',
      () {
        final reply = matcher.match('should i invest in lightning network');
        expect(reply.source, BelleReplySource.financialAdviceAttempt);
      },
    );

    test('altcoin mention takes priority over a topic match', () {
      final reply = matcher.match('ethereum wallet setup');
      expect(reply.source, BelleReplySource.altcoinQuestion);
    });

    test('financial-advice phrasing takes priority over an altcoin mention', () {
      final reply = matcher.match('should i buy ethereum');
      expect(reply.source, BelleReplySource.financialAdviceAttempt);
    });
  });
}
