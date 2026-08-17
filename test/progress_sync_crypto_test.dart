import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr.dart';

import 'package:bitcoin_beauty_school/data/user_progress.dart';
import 'package:bitcoin_beauty_school/services/nostr_keys.dart';

// Exercises the exact NIP-44 + NIP-78 construction ProgressRepository uses
// internally (kind 30078, self-encrypted, 'd'-tagged), without touching the
// network — this is the deterministic, always-testable half of the sync
// path. The relay round trip itself is documented as a manual check.
const _dTag = 'bitcoin-beauty-school:progress:v1';
const _kind = 30078;

void main() {
  test('NIP-44 self-encryption round-trips a UserProgress snapshot', () async {
    final identity = deriveIdentityKeys('Velvet touch, iron grip');
    final progress = UserProgress.fresh();
    final plaintext = jsonEncode(progress.toJson());

    final encrypted = await Encryption.encrypt(
      plaintext: plaintext,
      senderSecretKey: identity.secret,
      recipientPubkey: identity.public,
    );

    expect(encrypted, isNot(contains('level')));

    final decrypted = await Encryption.decrypt(
      payload: encrypted,
      recipientSecretKey: identity.secret,
      senderPubkey: identity.public,
    );

    expect(decrypted, plaintext);
    expect(
      UserProgress.fromJson(jsonDecode(decrypted) as Map<String, dynamic>)
          .toJson(),
      progress.toJson(),
    );
  });

  test('the constructed NIP-78 event is valid, addressable, and decrypts '
      'back to the original progress', () async {
    final identity = deriveIdentityKeys('Red lipstick, hidden balance');
    const progress = UserProgress(
      level: 4,
      xpCurrent: 320,
      xpTarget: 500,
      currentStreak: 5,
      bestStreak: 12,
      streakStates: [],
      quizzesCompleted: 9,
      categoriesMastered: '3/5',
      unlockedBadgeCount: 4,
    );

    final encrypted = await Encryption.encrypt(
      plaintext: jsonEncode(progress.toJson()),
      senderSecretKey: identity.secret,
      recipientPubkey: identity.public,
    );

    final event = Event.from(
      kind: _kind,
      content: encrypted,
      secretKey: identity.secret,
      tags: [
        ['d', _dTag],
      ],
    );

    expect(event.kind, _kind);
    expect(event.pubkey, identity.public);
    expect(event.tags, [
      ['d', _dTag],
    ]);
    expect(event.isValid(), isTrue);

    final decrypted = await Encryption.decrypt(
      payload: event.content,
      recipientSecretKey: identity.secret,
      senderPubkey: identity.public,
    );
    expect(
      UserProgress.fromJson(jsonDecode(decrypted) as Map<String, dynamic>)
          .toJson(),
      progress.toJson(),
    );
  });

  test('a different identity cannot decrypt the event', () async {
    final owner = deriveIdentityKeys('Soft power, sharp focus');
    final stranger = deriveIdentityKeys('My blush never goes out of style');

    final encrypted = await Encryption.encrypt(
      plaintext: jsonEncode(UserProgress.fresh().toJson()),
      senderSecretKey: owner.secret,
      recipientPubkey: owner.public,
    );

    await expectLater(
      Encryption.decrypt(
        payload: encrypted,
        recipientSecretKey: stranger.secret,
        senderPubkey: owner.public,
      ),
      throwsA(anything),
    );
  });
}
