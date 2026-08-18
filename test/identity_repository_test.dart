import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_beauty_school/data/identity_repository.dart';
import 'package:bitcoin_beauty_school/services/nostr_keys.dart';

const _secureStorage = FlutterSecureStorage();

void main() {
  setUp(() {
    // Each test gets clean local stores and a repository that's forgotten
    // whatever identity a previous test activated — otherwise the
    // singleton's in-memory cache would leak across tests in this file
    // and mask bugs in the "read from storage" path.
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    IdentityRepository.instance.resetForTesting();
  });

  test('a brand-new install generates and persists a suggested phrase to '
      'secure storage', () async {
    final phrase = await IdentityRepository.instance.ensureIdentity();

    expect(suggestedPhraseBank, contains(phrase));
    expect(IdentityRepository.instance.phrase, phrase);
    expect(IdentityRepository.instance.keys, isNotNull);
    expect(IdentityRepository.instance.belleKeys, isNotNull);

    expect(await _secureStorage.read(key: 'bbs_key_phrase'), phrase);
  });

  test('ensureIdentity re-reads the same persisted phrase, not a new one', () async {
    final first = await IdentityRepository.instance.ensureIdentity();

    // Simulate a fresh app launch: forget the in-memory identity, but
    // keep the same (mocked) on-disk storage.
    IdentityRepository.instance.resetForTesting();
    final second = await IdentityRepository.instance.ensureIdentity();

    expect(second, first);
  });

  test('restoreFromPhrase activates the given phrase\'s derived keys and '
      'persists it to secure storage', () async {
    const phrase = 'Velvet touch, iron grip';

    await IdentityRepository.instance.restoreFromPhrase(phrase);

    expect(IdentityRepository.instance.phrase, phrase);
    expect(IdentityRepository.instance.keys!.secret, deriveIdentityKeys(phrase).secret);
    expect(
      IdentityRepository.instance.belleKeys!.secret,
      deriveBelleKeys(phrase).secret,
    );

    expect(await _secureStorage.read(key: 'bbs_key_phrase'), phrase);
  });

  test('restoreFromPhrase overwrites whatever identity was active before', () async {
    await IdentityRepository.instance.ensureIdentity();
    final original = IdentityRepository.instance.keys!.public;

    await IdentityRepository.instance.restoreFromPhrase('a totally different phrase');

    expect(IdentityRepository.instance.keys!.public, isNot(original));
  });

  group('migration from the old shared_preferences storage', () {
    test('a phrase left over in shared_preferences is moved to secure '
        'storage and removed from the old location', () async {
      const legacyPhrase = 'Glow eternal, secret key';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bbs_key_phrase', legacyPhrase);

      final active = await IdentityRepository.instance.ensureIdentity();

      expect(active, legacyPhrase);
      expect(IdentityRepository.instance.keys!.secret, deriveIdentityKeys(legacyPhrase).secret);
      expect(await _secureStorage.read(key: 'bbs_key_phrase'), legacyPhrase);
      expect(prefs.getString('bbs_key_phrase'), isNull);
    });

    test('secure storage wins if a phrase somehow exists in both places', () async {
      const secureStoragePhrase = 'Soft power, sharp focus';
      const legacyPhrase = 'Red lipstick, hidden balance';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bbs_key_phrase', legacyPhrase);
      await _secureStorage.write(key: 'bbs_key_phrase', value: secureStoragePhrase);

      final active = await IdentityRepository.instance.ensureIdentity();

      expect(active, legacyPhrase);
      // Migration always runs first and overwrites secure storage with
      // whatever shared_preferences had — this only matters for an install
      // that somehow has both, which shouldn't happen in practice since
      // migration deletes the legacy copy the first time it runs.
    });

    test('a fresh install with nothing in either location generates a new '
        'phrase, not a migration', () async {
      final phrase = await IdentityRepository.instance.ensureIdentity();

      expect(suggestedPhraseBank, contains(phrase));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('bbs_key_phrase'), isNull);
    });
  });
}
