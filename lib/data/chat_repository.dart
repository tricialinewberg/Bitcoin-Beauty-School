import 'package:nostr/nostr.dart';

import '../models/chat_message.dart';
import '../services/nostr_relay_client.dart';
import 'identity_repository.dart';

/// Persists Belle chat history as NIP-17 gift-wrapped private direct
/// messages between the user's identity keypair and their per-account
/// Belle keypair (see nostr_keys.dart for why Belle has a derived, not
/// hardcoded, keypair).
///
/// There's no live chat UI wired to this yet — Belle's replies come from
/// an LLM through a backend proxy that isn't built. This is the
/// persistence layer that feature will call into: [sendUserMessage] when
/// the user sends something, [sendBelleReply] once a reply comes back
/// from the backend, and [fetchHistory] to restore the conversation.
class ChatRepository {
  ChatRepository._();

  static final instance = ChatRepository._();

  /// Sends [text] from the user to Belle.
  Future<void> sendUserMessage(String text) async {
    final (identity, belle) = _requireKeys();
    final wrapped = await DirectMessage.create(
      message: text,
      authorSecretKey: identity.secret,
      recipientPubkey: belle.public,
    );
    await NostrRelayClient.publish(wrapped);
  }

  /// Persists [text] as a reply "from Belle" to the user.
  Future<void> sendBelleReply(String text) async {
    final (identity, belle) = _requireKeys();
    final wrapped = await DirectMessage.create(
      message: text,
      authorSecretKey: belle.secret,
      recipientPubkey: identity.public,
    );
    await NostrRelayClient.publish(wrapped);
  }

  /// Fetches and decrypts the full conversation from relays, oldest
  /// first.
  ///
  /// Because the identity and Belle keypairs are both derived from the
  /// same phrase, this client can unwrap gift wraps addressed to either
  /// one — i.e. both sides of the conversation — without the usual NIP-17
  /// send-yourself-a-copy convention.
  Future<List<ChatMessage>> fetchHistory({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final identity = IdentityRepository.instance.keys;
    final belle = IdentityRepository.instance.belleKeys;
    if (identity == null || belle == null) return [];

    final giftWraps = await NostrRelayClient.fetch(
      Filter(
        kinds: [GiftWrap.kindGiftWrap],
        pTags: [identity.public, belle.public],
      ),
      timeout: timeout,
    );

    final messages = <ChatMessage>[];
    for (final giftWrap in giftWraps) {
      final message = await _tryUnwrap(giftWrap, identity, belle);
      if (message != null) messages.add(message);
    }
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  Future<ChatMessage?> _tryUnwrap(
    Event giftWrap,
    Keys identity,
    Keys belle,
  ) async {
    try {
      final rumor = await DirectMessage.parse(
        giftWrap: giftWrap,
        recipientSecretKey: identity.secret,
      );
      return ChatMessage(
        text: rumor.content,
        fromBelle: true,
        sentAt: _rumorSentAt(rumor),
      );
    } catch (_) {
      // Not addressed to the identity key — try Belle's.
    }
    try {
      final rumor = await DirectMessage.parse(
        giftWrap: giftWrap,
        recipientSecretKey: belle.secret,
      );
      return ChatMessage(
        text: rumor.content,
        fromBelle: false,
        sentAt: _rumorSentAt(rumor),
      );
    } catch (_) {
      return null;
    }
  }

  DateTime _rumorSentAt(Event rumor) =>
      DateTime.fromMillisecondsSinceEpoch(rumor.createdAt * 1000);

  (Keys, Keys) _requireKeys() {
    final identity = IdentityRepository.instance.keys;
    final belle = IdentityRepository.instance.belleKeys;
    if (identity == null || belle == null) {
      throw StateError(
        'No active identity — call IdentityRepository.ensureIdentity() first.',
      );
    }
    return (identity, belle);
  }
}
