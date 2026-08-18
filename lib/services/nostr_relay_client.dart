import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Talks to Nostr relays over WebSocket.
///
/// The `nostr` package only handles protocol-level concerns (events,
/// signing, encryption, message framing) — it's deliberately
/// transport-agnostic and ships no relay/WebSocket client. This is that
/// transport layer.
///
/// Best-effort by design: the app is local-first (shared_preferences is
/// the source of truth the UI reads from), so relay calls here are a
/// sync/backup path. Failures are swallowed and surfaced as empty
/// results / false rather than thrown, so a flaky or unreachable relay
/// never blocks the UI.
abstract final class NostrRelayClient {
  /// A small, fixed set of well-established free public relays:
  /// - relay.damus.io: one of the largest, most reliable general-purpose
  ///   relays, operated by the Damus client team.
  /// - nos.lol: long-running, high-uptime community relay.
  /// - relay.nostr.band: reliable general-purpose relay, also run by a
  ///   team that operates Nostr search/indexing infrastructure.
  ///
  /// Publishing fans out to all three; fetching merges results from all
  /// three (deduplicated by event id). No relay is authoritative — this
  /// is redundancy, not a single point of failure.
  ///
  /// This is the default/fallback set, always available via
  /// [defaultRelayUrls]. It's also the starting value of the *active*
  /// set ([relayUrls]) that [publish]/[fetch] actually use — see
  /// [useRelays] for how a NIP-65 relay list discovered for the active
  /// identity can supplement it.
  static const defaultRelayUrls = [
    'wss://relay.damus.io',
    'wss://nos.lol',
    'wss://relay.nostr.band',
  ];

  static List<String> _activeRelayUrls = List.of(defaultRelayUrls);

  /// The relay set [publish] and [fetch] currently use. Starts as
  /// [defaultRelayUrls]; changes when [useRelays] or
  /// [resetToDefaultRelays] is called.
  static List<String> get relayUrls => List.unmodifiable(_activeRelayUrls);

  /// Switches the active relay set to [urls] — used once a NIP-65
  /// (kind 10002) relay list has been discovered for the active
  /// identity. A call with an empty list is ignored, so a malformed or
  /// empty relay list event can never leave the app with nowhere to
  /// connect.
  static void useRelays(List<String> urls) {
    if (urls.isEmpty) return;
    _activeRelayUrls = List.of(urls);
  }

  /// Resets the active relay set back to [defaultRelayUrls]. Called when
  /// switching identities (restore), before that identity's own NIP-65
  /// relay list (if any) is looked up and applied — so the lookup itself
  /// always starts from a known-good set rather than whatever the
  /// previous identity happened to leave active.
  static void resetToDefaultRelays() {
    _activeRelayUrls = List.of(defaultRelayUrls);
  }

  /// Publishes [event] to every configured relay in parallel.
  ///
  /// Returns true if at least one relay acknowledged the event (an `OK`
  /// frame with `accepted = true`). Never throws — connection failures,
  /// timeouts, and rejections all just count as "that relay didn't work."
  static Future<bool> publish(
    Event event, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final results = await Future.wait(
      relayUrls.map((url) => _publishToOne(url, event, timeout)),
    );
    return results.any((accepted) => accepted);
  }

  /// Queries every configured relay in parallel and merges the results.
  ///
  /// Returns the union of events found, deduplicated by event id. Returns
  /// an empty list (never throws) if every relay is unreachable — callers
  /// should treat that the same as "nothing found yet," not an error.
  static Future<List<Event>> fetch(
    Filter filter, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final results = await Future.wait(
      relayUrls.map((url) => _fetchFromOne(url, filter, timeout)),
    );
    final byId = <String, Event>{};
    for (final events in results) {
      for (final event in events) {
        byId[event.id] = event;
      }
    }
    return byId.values.toList();
  }

  static Future<bool> _publishToOne(
    String url,
    Event event,
    Duration timeout,
  ) async {
    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.ready.timeout(timeout);

      final completer = Completer<bool>();
      final subscription = channel.stream.listen(
        (data) {
          if (completer.isCompleted) return;
          try {
            final decoded = jsonDecode(data as String);
            if (decoded is List &&
                decoded.length >= 3 &&
                decoded[0] == 'OK' &&
                decoded[1] == event.id) {
              completer.complete(decoded[2] == true);
            }
          } catch (_) {
            // Ignore malformed frames from the relay.
          }
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      channel.sink.add(jsonEncode(['EVENT', event.toMap()]));
      final accepted = await completer.future.timeout(
        timeout,
        onTimeout: () => false,
      );
      await subscription.cancel();
      return accepted;
    } catch (_) {
      return false;
    } finally {
      unawaited(channel?.sink.close());
    }
  }

  static Future<List<Event>> _fetchFromOne(
    String url,
    Filter filter,
    Duration timeout,
  ) async {
    final events = <Event>[];
    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.ready.timeout(timeout);

      final subscriptionId = _randomSubscriptionId();
      final eoseCompleter = Completer<void>();
      final subscription = channel.stream.listen(
        (data) {
          try {
            final message = Message.deserialize(data as String);
            switch (message.messageType) {
              case MessageType.event:
                events.add(message.message as Event);
              case MessageType.eose:
                if (!eoseCompleter.isCompleted) eoseCompleter.complete();
              default:
                break;
            }
          } catch (_) {
            // Ignore malformed or unverifiable frames from the relay.
          }
        },
        onError: (_) {
          if (!eoseCompleter.isCompleted) eoseCompleter.complete();
        },
      );

      channel.sink.add(
        Request(subscriptionId: subscriptionId, filters: [filter]).serialize(),
      );
      await eoseCompleter.future.timeout(timeout, onTimeout: () {});
      await subscription.cancel();
    } catch (_) {
      // Swallow — an unreachable relay just contributes no events.
    } finally {
      unawaited(channel?.sink.close());
    }
    return events;
  }

  static String _randomSubscriptionId() {
    final random = Random();
    return List.generate(16, (_) => random.nextInt(16).toRadixString(16))
        .join();
  }
}
