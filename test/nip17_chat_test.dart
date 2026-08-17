import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr.dart';

import 'package:bitcoin_beauty_school/services/nostr_keys.dart';

// Exercises the NIP-17 gift-wrap/unwrap round trip used by ChatRepository,
// without touching the network. Covers both directions (user -> Belle and
// Belle -> user) and confirms the derived-Belle-keypair design actually
// holds: only someone holding the same phrase (i.e. both derived secrets)
// can read either side.
void main() {
  test('a message from the user to Belle unwraps with Belle\'s key, not '
      "the user's", () async {
    const phrase = 'Glow eternal, secret key';
    final user = deriveIdentityKeys(phrase);
    final belle = deriveBelleKeys(phrase);

    final giftWrap = await DirectMessage.create(
      message: 'What even is a UTXO?',
      authorSecretKey: user.secret,
      recipientPubkey: belle.public,
    );

    expect(giftWrap.kind, GiftWrap.kindGiftWrap);

    final rumor = await DirectMessage.parse(
      giftWrap: giftWrap,
      recipientSecretKey: belle.secret,
    );
    expect(rumor.content, 'What even is a UTXO?');
    expect(rumor.pubkey, user.public);

    await expectLater(
      DirectMessage.parse(giftWrap: giftWrap, recipientSecretKey: user.secret),
      throwsA(anything),
    );
  });

  test("a reply from Belle to the user unwraps with the user's key, not "
      "Belle's", () async {
    const phrase = 'My blush never goes out of style';
    final user = deriveIdentityKeys(phrase);
    final belle = deriveBelleKeys(phrase);

    final giftWrap = await DirectMessage.create(
      message: "It's an unspent transaction output — a chunk of bitcoin "
          "you own that hasn't been spent yet 💅",
      authorSecretKey: belle.secret,
      recipientPubkey: user.public,
    );

    final rumor = await DirectMessage.parse(
      giftWrap: giftWrap,
      recipientSecretKey: user.secret,
    );
    expect(rumor.pubkey, belle.public);
    expect(rumor.content, contains('unspent transaction output'));

    await expectLater(
      DirectMessage.parse(
        giftWrap: giftWrap,
        recipientSecretKey: belle.secret,
      ),
      throwsA(anything),
    );
  });

  test('someone who only derives from a different phrase cannot unwrap '
      'either side', () async {
    const phrase = 'Red lipstick, hidden balance';
    final user = deriveIdentityKeys(phrase);
    final belle = deriveBelleKeys(phrase);
    final stranger = deriveIdentityKeys('Soft power, sharp focus');

    final giftWrap = await DirectMessage.create(
      message: 'this is private',
      authorSecretKey: user.secret,
      recipientPubkey: belle.public,
    );

    await expectLater(
      DirectMessage.parse(
        giftWrap: giftWrap,
        recipientSecretKey: stranger.secret,
      ),
      throwsA(anything),
    );
  });
}
