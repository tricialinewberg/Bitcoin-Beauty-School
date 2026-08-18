import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr.dart';

import 'package:bitcoin_beauty_school/services/nostr_keys.dart';
import 'package:bitcoin_beauty_school/services/nostr_relay_client.dart';

// Covers the deterministic half of NIP-65 support: constructing and
// parsing a kind:10002 event, and the active-relay-set state machine that
// a discovered relay list gets applied to. Actually publishing to /
// fetching from relays is a documented manual check, same as the rest of
// this app's network-dependent flows.
void main() {
  group('RelayList.create / parse', () {
    test('round-trips a relay list, marking every relay read+write', () {
      final identity = deriveIdentityKeys('My blush never goes out of style');
      const urls = [
        'wss://relay.damus.io',
        'wss://nos.lol',
        'wss://relay.nostr.band',
      ];

      final event = RelayList.create(
        relays: [
          for (final url in urls)
            RelayMetadataData(url: url, read: true, write: true),
        ],
        secretKey: identity.secret,
      );

      expect(event.kind, 10002);
      expect(event.pubkey, identity.public);
      expect(event.isValid(), isTrue);
      expect(event.tags, [
        for (final url in urls) ['r', url],
      ]);

      final parsed = RelayList.parse(event);
      expect(parsed.map((r) => r.url).toList(), urls);
      expect(parsed.every((r) => r.read && r.write), isTrue);
    });

    test('preserves read-only and write-only markers', () {
      final identity = deriveIdentityKeys('Glow eternal, secret key');

      final event = RelayList.create(
        relays: const [
          RelayMetadataData(url: 'wss://read-only.example', read: true, write: false),
          RelayMetadataData(url: 'wss://write-only.example', read: false, write: true),
        ],
        secretKey: identity.secret,
      );

      expect(event.tags, [
        ['r', 'wss://read-only.example', 'read'],
        ['r', 'wss://write-only.example', 'write'],
      ]);

      final parsed = RelayList.parse(event);
      expect(parsed[0].read, isTrue);
      expect(parsed[0].write, isFalse);
      expect(parsed[1].read, isFalse);
      expect(parsed[1].write, isTrue);
    });

    test('rejects parsing an event of the wrong kind', () {
      final identity = deriveIdentityKeys('Red lipstick, hidden balance');
      final notARelayList = Event.from(
        kind: 1,
        content: 'just a note',
        secretKey: identity.secret,
      );

      expect(() => RelayList.parse(notARelayList), throwsA(anything));
    });
  });

  group('NostrRelayClient active relay set', () {
    setUp(NostrRelayClient.resetToDefaultRelays);
    tearDown(NostrRelayClient.resetToDefaultRelays);

    test('starts as the default relay set', () {
      expect(NostrRelayClient.relayUrls, NostrRelayClient.defaultRelayUrls);
    });

    test('useRelays switches the active set', () {
      NostrRelayClient.useRelays(['wss://custom-one.example', 'wss://custom-two.example']);

      expect(NostrRelayClient.relayUrls, [
        'wss://custom-one.example',
        'wss://custom-two.example',
      ]);
    });

    test('useRelays with an empty list is ignored, never leaving zero relays', () {
      NostrRelayClient.useRelays(['wss://custom.example']);

      NostrRelayClient.useRelays([]);

      expect(NostrRelayClient.relayUrls, ['wss://custom.example']);
    });

    test('resetToDefaultRelays restores the default set after a switch', () {
      NostrRelayClient.useRelays(['wss://custom.example']);

      NostrRelayClient.resetToDefaultRelays();

      expect(NostrRelayClient.relayUrls, NostrRelayClient.defaultRelayUrls);
    });
  });
}
