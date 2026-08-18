import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/data/identity_repository.dart';
import 'package:bitcoin_beauty_school/screens/belle/belle_conversation_screen.dart';
import 'package:bitcoin_beauty_school/screens/belle/belle_screen.dart';
import 'package:bitcoin_beauty_school/theme/app_theme.dart';

// No identity is bootstrapped in these tests, so ChatRepository.fetchHistory
// resolves to an empty list immediately (see chat_repository.dart — it
// checks for null keys and returns [] before ever touching the network),
// keeping this deterministic and fast.
void main() {
  setUp(() {
    IdentityRepository.instance.resetForTesting();
  });

  testWidgets(
    'shows the greeting and an empty-history message with no chats yet',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const BelleScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Hi, Bestie 👋'), findsOneWidget);
      expect(find.textContaining('No conversations yet'), findsOneWidget);
    },
  );

  testWidgets('tapping the + button opens the conversation screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const BelleScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(BelleConversationScreen), findsOneWidget);
  });
}
