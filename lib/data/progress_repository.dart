import 'dart:async';
import 'dart:convert';

import 'package:nostr/nostr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/nostr_relay_client.dart';
import 'identity_repository.dart';
import 'user_progress.dart';

/// Local-first storage for [UserProgress], synced to Nostr as an
/// encrypted backup.
///
/// shared_preferences is the source of truth the UI reads from — [load]
/// always returns instantly from the local cache when one exists, and
/// [save] writes locally before ever touching the network. Relay
/// publish/fetch is sync/backup: it runs in the background on save, and
/// is only consulted on [load] when there's no local cache yet (i.e.
/// right after a restore, once [clearLocalCache] has run, or on a
/// genuinely fresh install where a remote snapshot might exist from
/// another device). Network failures never surface to callers — they
/// just mean the local cache (or a fresh-account default) is used.
class ProgressRepository {
  ProgressRepository._();

  static final instance = ProgressRepository._();

  static const _localCacheKey = 'bbs_progress_cache_v1';

  /// NIP-78 (arbitrary app data) kind.
  static const _nip78Kind = 30078;

  /// The 'd' tag identifying this app's progress snapshot among whatever
  /// other kind-30078 events this pubkey might have.
  static const _nip78DTag = 'bitcoin-beauty-school:progress:v1';

  /// Returns the current progress: local cache if present, otherwise a
  /// best-effort fetch from relays, otherwise a fresh-account default.
  /// Whichever of those is returned gets written to the local cache so
  /// subsequent loads are instant.
  Future<UserProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_localCacheKey);
    if (cached != null) {
      try {
        return UserProgress.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      } catch (_) {
        // Corrupt cache entry — fall through and rebuild it below.
      }
    }

    final remote = await _fetchFromRelays();
    final progress = remote ?? UserProgress.fresh();
    await _saveLocalOnly(progress);
    return progress;
  }

  /// Writes [progress] to the local cache immediately, then publishes an
  /// encrypted backup to relays in the background. The returned future
  /// completes once the local write lands — it does not wait on the
  /// network.
  Future<void> save(UserProgress progress) async {
    await _saveLocalOnly(progress);
    unawaited(_publishToRelays(progress));
  }

  /// Clears the local cache. Call this right after switching identities
  /// (restore flow) so the next [load] is forced to fetch the *new*
  /// identity's data from relays instead of returning the previous
  /// identity's snapshot.
  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localCacheKey);
  }

  Future<void> _saveLocalOnly(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localCacheKey, jsonEncode(progress.toJson()));
  }

  Future<void> _publishToRelays(UserProgress progress) async {
    final identity = IdentityRepository.instance.keys;
    if (identity == null) return;

    try {
      final encrypted = await Encryption.encrypt(
        plaintext: jsonEncode(progress.toJson()),
        senderSecretKey: identity.secret,
        recipientPubkey: identity.public,
      );
      final event = Event.from(
        kind: _nip78Kind,
        content: encrypted,
        secretKey: identity.secret,
        tags: [
          ['d', _nip78DTag],
        ],
      );
      await NostrRelayClient.publish(event);
    } catch (_) {
      // Best-effort — the local cache already has this data.
    }
  }

  Future<UserProgress?> _fetchFromRelays() async {
    final identity = IdentityRepository.instance.keys;
    if (identity == null) return null;

    try {
      final events = await NostrRelayClient.fetch(
        Filter(
          kinds: [_nip78Kind],
          authors: [identity.public],
          tagFilters: {
            'd': [_nip78DTag],
          },
        ),
      );
      if (events.isEmpty) return null;

      // Kind 30078 is addressable/replaceable, so relays should only
      // ever return the latest per (kind, pubkey, d-tag) — but pick the
      // newest explicitly in case a relay doesn't dedupe correctly.
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latest = events.first;

      final decrypted = await Encryption.decrypt(
        payload: latest.content,
        recipientSecretKey: identity.secret,
        senderPubkey: identity.public,
      );
      return UserProgress.fromJson(
        jsonDecode(decrypted) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
