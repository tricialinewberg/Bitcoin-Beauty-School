// Deterministic key derivation from a user's key phrase.
//
// The phrase is not a BIP-39 seed — it's a short, freely chosen or
// suggested beauty-themed phrase. There's no fixed wordlist or checksum
// requirement; any string hashes to a valid keypair. The security bar is
// "reasonably resistant to casual guessing," not brainwallet-grade
// hardening, so a single SHA-256 pass (no key-stretching) is intentional.
//
// Two keypairs are derived from the same phrase using different
// domain-separation prefixes:
// - [deriveIdentityKeys]: the user's real account identity.
// - [deriveBelleKeys]: a per-account counterparty for NIP-17 chat with
//   Belle. Belle isn't a live key-holder, so a single keypair hardcoded
//   in the app would ship its private key in the binary — anyone could
//   compute the NIP-44 shared secret and read "private" messages. Deriving
//   Belle's key from the same phrase instead means only someone who
//   already knows the phrase (i.e. already has full account access) can
//   ever compute that shared secret, and it lets the same client decrypt
//   both sides of the conversation without the usual NIP-17
//   send-a-duplicate-copy-to-yourself convention.

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
/// chat history. See the file-level comment for why this is derived
/// rather than a single hardcoded keypair.
Keys deriveBelleKeys(String phrase) =>
    Keys(_deriveHexSecret(_belleDomain, phrase));
