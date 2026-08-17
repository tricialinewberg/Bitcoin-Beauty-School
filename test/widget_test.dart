import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/main.dart';
import 'package:bitcoin_beauty_school/screens/splash/splash_screen.dart';

void main() {
  testWidgets('App boots into the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BitcoinBeautySchoolApp());

    expect(find.byType(SplashScreen), findsOneWidget);

    // Let the splash screen's display timer and fade transition finish so
    // no timers are left pending when the test ends.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  });
}
