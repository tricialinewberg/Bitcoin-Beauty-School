import 'dart:math';

import 'package:flutter/foundation.dart';
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
class IdentityRepository {
  IdentityRepository._();

  static final instance = IdentityRepository._();

  static const _phraseKey = 'bbs_key_phrase';

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

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_phraseKey);

    if (stored != null && stored.isNotEmpty) {
      _activate(stored);
      return stored;
    }

    final generated =
        suggestedPhraseBank[Random().nextInt(suggestedPhraseBank.length)];
    await prefs.setString(_phraseKey, generated);
    _activate(generated);
    return generated;
  }

  /// Sets [phrase] as the device's active identity, overwriting whatever
  /// was there before (used by the "restore from another phrase" flow).
  /// Callers are responsible for clearing/refreshing any data cached
  /// under the previous identity (see `ProgressRepository.clearLocalCache`).
  Future<void> restoreFromPhrase(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phraseKey, phrase);
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
