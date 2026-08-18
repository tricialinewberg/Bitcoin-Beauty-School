// Deterministic key derivation from a user's key phrase.
//
// The phrase is not a BIP-39 seed — it's a short, freely chosen or
// suggested beauty-themed phrase. There's no fixed wordlist or checksum
// requirement; any string hashes to a valid keypair. The security bar is
// "reasonably resistant to casual guessing," not brainwallet-grade
// hardening, so a single SHA-256 pass (no key-stretching) is intentional.
//
// Two keypairs are derived from the same phrase using different
// domain-separation prefixes — [deriveIdentityKeys] for the user's real
// account, [deriveBelleKeys] for the NIP-17 Belle-chat counterparty. See
// the doc comment on [deriveBelleKeys] for why the latter is derived
// rather than a single shared keypair — that's a deliberate architecture
// decision, not an implementation detail, and is worth reading before
// touching anything that depends on it (chat send/receive, key rotation,
// etc).

import 'dart:convert';

import 'package:crypto/crypto.dart';
// nostr.dart re-exports its own internal `sha256` helper, which collides
// with package:crypto's `sha256`. We only want the latter here.
import 'package:nostr/nostr.dart' hide sha256;

const _identityDomain = 'bbs:identity:v1:';
const _belleDomain = 'bbs:belle:v1:';

String _deriveHexSecret(String domain, String phrase) {
  final digest = sha256.convert(utf8.encode('$domain$phrase'));
  return digest.toString();
}

/// Derives the user's real Nostr identity keypair from their key phrase.
/// The same phrase always produces the same keypair.
Keys deriveIdentityKeys(String phrase) =>
    Keys(_deriveHexSecret(_identityDomain, phrase));

/// Derives the per-account "Belle" counterparty keypair used for NIP-17
/// chat history.
///
/// **Why not a single hardcoded Belle keypair?** NIP-17 is designed for
/// two independent parties who each keep their own private key secret.
/// Belle isn't an independent party — she's a persona inside this app,
/// with no server-side identity of her own. If every install shared one
/// hardcoded "Belle" keypair, that keypair's private key would ship
/// inside the app binary on every device. NIP-44's confidentiality comes
/// from an ECDH shared secret that either side can compute from *their
/// own* secret key and the *other side's* public key — so a private key
/// that ships in the APK isn't actually private, and anyone who
/// extracted it could compute the same shared secret as the real user
/// and read every "private" conversation on the network. The gift-wrap
/// layer (NIP-59) would still hide the metadata from casual relay
/// observers, but the content itself would be an open book.
///
/// **What this does instead:** derives Belle's keypair from the *same*
/// phrase as the user's own identity ([deriveIdentityKeys]), just under
/// a different domain-separation prefix. Nothing is shared across
/// installs or hardcoded anywhere — computing this keypair requires the
/// user's own phrase, which is exactly the same information required to
/// compute their real identity key.
///
/// **The resulting property, and why it matters:** this is not a real
/// second party on the Nostr network. "Belle" here is a second
/// deterministic identity the user's own client derives from its own
/// secret, so that chat history can be shaped as NIP-17 events (with
/// their gift-wrap privacy properties against outside observers) without
/// requiring a live counterparty to hold a key. It's a self-conversation
/// pattern wearing NIP-17's clothes, not a conversation with an
/// independent Belle identity — anyone who has the phrase can already
/// derive both keypairs and read both sides, by design (it's also what
/// lets the user's own client decrypt both sides without the usual NIP-17
/// send-yourself-a-duplicate-copy convention). If Belle ever becomes a
/// live networked identity of her own (e.g. a real server-held keypair
/// replying autonomously), this function — and the trust model it
/// implies — needs to be revisited, not just extended.
Keys deriveBelleKeys(String phrase) =>
    Keys(_deriveHexSecret(_belleDomain, phrase));
