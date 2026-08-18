import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nostr/nostr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/nostr_keys.dart';

/// A small bank of beauty-themed phrases suggested to brand-new users on
/// first launch. The phrase itself has no fixed-wordlist requirement (see
/// nostr_keys.dart) — this is just a friendly default so a first-time user
/// isn't stuck staring at an empty "type something memorable" field. They
/// can always type their own via the restore flow.
const suggestedPhraseBank = [
  'My blush never goes out of style',
  'Glow eternal, secret key',
  'Red lipstick, hidden balance',
  'Soft power, sharp focus',
  'Velvet touch, iron grip',
];

/// Owns the device's currently-active key phrase and its derived
/// keypairs. A phrase is either generated on first use or set via restore;
/// either way the same phrase always re-derives the same keys, on any
/// device.
///
/// The phrase is the account's private key material at rest — anyone who
/// reads it has full account access, the same as reading a raw private
/// key — so it lives in platform secure storage (Keychain on iOS,
/// Keystore-backed on Android via [FlutterSecureStorage]), not
/// shared_preferences. Earlier versions of this app stored it in
/// shared_preferences; [ensureIdentity] migrates any such install
/// automatically the first time it runs (see [_migrateLegacyPhraseIfNeeded]).
class IdentityRepository {
  IdentityRepository._();

  static final instance = IdentityRepository._();

  static const _phraseKey = 'bbs_key_phrase';
  static const _secureStorage = FlutterSecureStorage();

  String? _phrase;
  Keys? _keys;
  Keys? _belleKeys;

  /// The active key phrase, or null before [ensureIdentity] /
  /// [restoreFromPhrase] has run.
  String? get phrase => _phrase;

  /// The active identity keypair, or null before an identity is loaded.
  Keys? get keys => _keys;

  /// The active per-account Belle chat keypair, or null before an
  /// identity is loaded.
  Keys? get belleKeys => _belleKeys;

  /// Loads the stored phrase, or generates and persists a suggested one
  /// if this is a brand-new install. Safe to call multiple times — later
  /// calls are a no-op once an identity is active in memory.
  ///
  /// Returns the active phrase.
  Future<String> ensureIdentity() async {
    if (_phrase != null) return _phrase!;

    final migrated = await _migrateLegacyPhraseIfNeeded();
    final stored = migrated ?? await _secureStorage.read(key: _phraseKey);

    if (stored != null && stored.isNotEmpty) {
      _activate(stored);
      return stored;
    }

    final generated =
        suggestedPhraseBank[Random().nextInt(suggestedPhraseBank.length)];
    await _secureStorage.write(key: _phraseKey, value: generated);
    _activate(generated);
    return generated;
  }

  /// One-time migration for installs from before secure storage was
  /// introduced: if a phrase is sitting in shared_preferences (its old,
  /// less-protected home), move it into secure storage and delete the old
  /// copy so it isn't left behind in both places.
  ///
  /// Returns the migrated phrase, or null if there was nothing to migrate.
  Future<String?> _migrateLegacyPhraseIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_phraseKey);
    if (legacy == null || legacy.isEmpty) return null;

    await _secureStorage.write(key: _phraseKey, value: legacy);
    await prefs.remove(_phraseKey);
    return legacy;
  }

  /// Sets [phrase] as the device's active identity, overwriting whatever
  /// was there before (used by the "restore from another phrase" flow).
  /// Callers are responsible for clearing/refreshing any data cached
  /// under the previous identity (see `ProgressRepository.clearLocalCache`).
  Future<void> restoreFromPhrase(String phrase) async {
    await _secureStorage.write(key: _phraseKey, value: phrase);
    _activate(phrase);
  }

  void _activate(String phrase) {
    _phrase = phrase;
    _keys = deriveIdentityKeys(phrase);
    _belleKeys = deriveBelleKeys(phrase);
  }

  /// Clears the in-memory active identity so the next [ensureIdentity]
  /// call re-reads from storage instead of short-circuiting on a cached
  /// value. Only meaningful in tests — this singleton otherwise lives for
  /// the app's whole process lifetime, so production code never needs to
  /// "forget" the active identity.
  @visibleForTesting
  void resetForTesting() {
    _phrase = null;
    _keys = null;
    _belleKeys = null;
  }
}
