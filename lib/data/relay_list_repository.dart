import 'package:nostr/nostr.dart';

import '../services/nostr_relay_client.dart';

/// Publishes and discovers NIP-65 (Relay List Metadata) events.
///
/// This app has no follow/social graph, so the usual NIP-65 outbox-model
/// distinction between "read" (inbox) and "write" (outbox) relays doesn't
/// really apply — it's the same identity syncing its own encrypted data
/// across its own devices. Every relay in a list built by this repository
/// is marked both read and write.
class RelayListRepository {
  RelayListRepository._();

  static final instance = RelayListRepository._();

  /// Publishes a kind:10002 event advertising [urls] (all marked
  /// read+write) under [identity]'s pubkey. Best-effort — failures are
  /// swallowed, same as the rest of this app's relay-facing calls.
  Future<void> publishRelayList(Keys identity, List<String> urls) async {
    try {
      final event = RelayList.create(
        relays: [
          for (final url in urls)
            RelayMetadataData(url: url, read: true, write: true),
        ],
        secretKey: identity.secret,
      );
      await NostrRelayClient.publish(event);
    } catch (_) {
      // Best-effort — callers fall back to the default relay set.
    }
  }

  /// Fetches [pubkey]'s kind:10002 relay list, if one exists on the
  /// currently-active relay set.
  ///
  /// Returns null — not an empty list — when nothing is found or the
  /// fetch fails, so callers can tell "no relay list yet" apart from "a
  /// relay list that (invalidly) contains zero relays." Either way, the
  /// caller's move is the same: fall back to the hardcoded default set.
  Future<List<String>?> fetchRelayList(String pubkey) async {
    try {
      final events = await NostrRelayClient.fetch(
        Filter(kinds: [RelayList.kindRelayList], authors: [pubkey]),
      );
      if (events.isEmpty) return null;

      // Kind 10002 is replaceable, so relays should only ever return the
      // latest per (kind, pubkey) — pick the newest explicitly in case
      // one doesn't dedupe correctly.
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final urls = RelayList.parse(events.first).map((r) => r.url).toList();
      return urls.isEmpty ? null : urls;
    } catch (_) {
      return null;
    }
  }
}
