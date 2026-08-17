import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_beauty_school/data/identity_repository.dart';
import 'package:bitcoin_beauty_school/services/nostr_keys.dart';

void main() {
  setUp(() {
    // Each test gets a clean local store and a repository that's
    // forgotten whatever identity a previous test activated — otherwise
    // the singleton's in-memory cache would leak across tests in this
    // file and mask bugs in the "read from storage" path.
    SharedPreferences.setMockInitialValues({});
    IdentityRepository.instance.resetForTesting();
  });

  test('a brand-new install generates and persists a suggested phrase', () async {
    final phrase = await IdentityRepository.instance.ensureIdentity();

    expect(suggestedPhraseBank, contains(phrase));
    expect(IdentityRepository.instance.phrase, phrase);
    expect(IdentityRepository.instance.keys, isNotNull);
    expect(IdentityRepository.instance.belleKeys, isNotNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bbs_key_phrase'), phrase);
  });

  test('ensureIdentity re-reads the same persisted phrase, not a new one', () async {
    final first = await IdentityRepository.instance.ensureIdentity();

    // Simulate a fresh app launch: forget the in-memory identity, but
    // keep the same (mocked) on-disk storage.
    IdentityRepository.instance.resetForTesting();
    final second = await IdentityRepository.instance.ensureIdentity();

    expect(second, first);
  });

  test('restoreFromPhrase activates the given phrase\'s derived keys', () async {
    const phrase = 'Velvet touch, iron grip';

    await IdentityRepository.instance.restoreFromPhrase(phrase);

    expect(IdentityRepository.instance.phrase, phrase);
    expect(IdentityRepository.instance.keys!.secret, deriveIdentityKeys(phrase).secret);
    expect(
      IdentityRepository.instance.belleKeys!.secret,
      deriveBelleKeys(phrase).secret,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bbs_key_phrase'), phrase);
  });

  test('restoreFromPhrase overwrites whatever identity was active before', () async {
    await IdentityRepository.instance.ensureIdentity();
    final original = IdentityRepository.instance.keys!.public;

    await IdentityRepository.instance.restoreFromPhrase('a totally different phrase');

    expect(IdentityRepository.instance.keys!.public, isNot(original));
  });
}
