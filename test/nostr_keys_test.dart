import 'package:flutter_test/flutter_test.dart';

import 'package:bitcoin_beauty_school/services/nostr_keys.dart';

void main() {
  group('deriveIdentityKeys', () {
    test('same phrase always derives the same keypair', () {
      const phrase = 'My blush never goes out of style';

      final a = deriveIdentityKeys(phrase);
      final b = deriveIdentityKeys(phrase);

      expect(a.secret, b.secret);
      expect(a.public, b.public);
    });

    test('different phrases derive different keypairs', () {
      final a = deriveIdentityKeys('My blush never goes out of style');
      final b = deriveIdentityKeys('Glow eternal, secret key');

      expect(a.secret, isNot(b.secret));
      expect(a.public, isNot(b.public));
    });

    test('derives a valid 64-char hex secret key', () {
      final keys = deriveIdentityKeys('any phrase at all');

      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(keys.secret), isTrue);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(keys.public), isTrue);
    });
  });

  group('deriveBelleKeys', () {
    test('same phrase always derives the same Belle keypair', () {
      const phrase = 'Red lipstick, hidden balance';

      final a = deriveBelleKeys(phrase);
      final b = deriveBelleKeys(phrase);

      expect(a.secret, b.secret);
      expect(a.public, b.public);
    });

    test('is a different keypair from the identity keypair for the same '
        'phrase', () {
      const phrase = 'Soft power, sharp focus';

      final identity = deriveIdentityKeys(phrase);
      final belle = deriveBelleKeys(phrase);

      expect(identity.secret, isNot(belle.secret));
      expect(identity.public, isNot(belle.public));
    });
  });
}
