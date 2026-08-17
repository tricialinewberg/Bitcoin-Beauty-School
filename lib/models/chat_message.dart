/// A single message in the user's chat history with Belle.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromBelle,
    required this.sentAt,
  });

  final String text;

  /// True if Belle sent this message; false if the user did.
  final bool fromBelle;

  final DateTime sentAt;
}
