import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/data/identity_repository.dart';
import 'package:bitcoin_beauty_school/screens/belle/belle_conversation_screen.dart';
import 'package:bitcoin_beauty_school/theme/app_theme.dart';

void main() {
  setUp(() {
    IdentityRepository.instance.resetForTesting();
  });

  testWidgets('shows an empty-state hint before any messages are sent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const BelleConversationScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Ask Belle anything about Bitcoin'), findsOneWidget);
  });

  testWidgets(
    'sending a message shows the user bubble and a matched Belle reply',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const BelleConversationScreen()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "what's a satoshi?");
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text("what's a satoshi?"), findsOneWidget);
      expect(find.textContaining('smallest unit of bitcoin'), findsOneWidget);
    },
  );

  testWidgets('an unmatched message shows the no-match fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const BelleConversationScreen()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'what is your favorite movie');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('outside what I know well'), findsOneWidget);
  });

  testWidgets(
    'a financial-advice-seeking message shows that specific fallback, not a topic answer',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const BelleConversationScreen()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'should I buy bitcoin right now?',
      );
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('outside my lane'), findsOneWidget);
    },
  );
}
