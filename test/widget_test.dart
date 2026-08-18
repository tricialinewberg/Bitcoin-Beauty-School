import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_beauty_school/main.dart';
import 'package:bitcoin_beauty_school/screens/splash/splash_screen.dart';

void main() {
  testWidgets('App boots into the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const BitcoinBeautySchoolApp());

    expect(find.byType(SplashScreen), findsOneWidget);

    // Let the splash screen's display timer and fade transition finish so
    // no timers are left pending when the test ends.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Identity bootstrap also fires a best-effort, unawaited NIP-65
    // relay-list publish in the background (see
    // IdentityRepository.ensureIdentity). It doesn't block navigation,
    // but its per-relay timeout (5s) is still a pending Timer when this
    // test would otherwise end — pumpAndSettle doesn't wait for it since
    // nothing is scheduling a new frame off the back of it. Advance past
    // the timeout so it's resolved, not just abandoned.
    await tester.pump(const Duration(seconds: 6));
  });
}
