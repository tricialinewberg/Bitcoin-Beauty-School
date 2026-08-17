import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/main.dart';

void main() {
  testWidgets('App boots and shows the app name', (WidgetTester tester) async {
    await tester.pumpWidget(const BitcoinBeautySchoolApp());

    expect(find.text('Bitcoin Beauty School'), findsOneWidget);
  });
}
