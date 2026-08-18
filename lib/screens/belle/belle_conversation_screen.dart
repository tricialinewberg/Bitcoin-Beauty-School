import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/chat_repository.dart';
import '../../models/chat_message.dart';
import '../../services/belle_response_matcher.dart';
import '../../theme/app_colors.dart';
import '../../widgets/detail_app_bar.dart';

/// The actual chat conversation with Belle. Replies come from
/// [BelleResponseMatcher] — a fully offline, scripted keyword match, no
/// network call and no delay — so both the user's message and Belle's
/// reply appear immediately. Persisting to Nostr (via [ChatRepository])
/// happens in the background afterwards, same "local-first, relay sync is
/// best-effort" pattern used throughout this app (see ProgressRepository,
/// IdentityRepository) — a slow or unreachable relay never blocks the chat
/// itself.
class BelleConversationScreen extends StatefulWidget {
  const BelleConversationScreen({super.key});

  @override
  State<BelleConversationScreen> createState() =>
      _BelleConversationScreenState();
}

class _BelleConversationScreenState extends State<BelleConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  List<ChatMessage>? _messages;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final messages = await ChatRepository.instance.fetchHistory();
    if (!mounted) return;
    setState(() => _messages = messages);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    _controller.clear();
    final userMessage = ChatMessage(
      text: text,
      fromBelle: false,
      sentAt: DateTime.now(),
    );
    setState(() {
      _sending = true;
      _messages = [...(_messages ?? []), userMessage];
    });
    _scrollToBottom();

    final matcher = await BelleResponseMatcher.load();
    final reply = matcher.match(text);
    final belleMessage = ChatMessage(
      text: reply.text,
      fromBelle: true,
      sentAt: DateTime.now(),
    );

    if (!mounted) return;
    setState(() {
      _sending = false;
      _messages = [...(_messages ?? []), belleMessage];
    });
    _scrollToBottom();

    // Best-effort, matching the rest of the app's local-first pattern: the
    // chat itself is already fully usable from the in-memory matcher
    // above, so a relay hiccup — or, defensively, no active identity at
    // all — should never surface as a crash here.
    unawaited(ChatRepository.instance.sendUserMessage(text).catchError((_) {}));
    unawaited(
      ChatRepository.instance.sendBelleReply(reply.text).catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messages;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      appBar: const DetailAppBar(title: 'Belle'),
      body: Column(
        children: [
          Expanded(
            child: messages == null
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Ask Belle anything about Bitcoin — wallets, '
                        "blockchain, UTXOs, and more!",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedMauve,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        _MessageBubble(message: messages[index]),
                  ),
          ),
          _Composer(
            controller: _controller,
            onSend: _send,
            enabled: messages != null && !_sending,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isBelle = message.fromBelle;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isBelle ? AppColors.bloomWhite : AppColors.glamPink,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isBelle ? 4 : 20),
          bottomRight: Radius.circular(isBelle ? 20 : 4),
        ),
      ),
      child: Text(
        message.text,
        style: textTheme.bodyLarge?.copyWith(
          color: isBelle ? AppColors.shadowWalletGray : AppColors.bloomWhite,
        ),
      ),
    );

    if (!isBelle) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundImage: AssetImage('assets/images/belle_avatar.png'),
        ),
        const SizedBox(width: 8),
        Flexible(child: bubble),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bloomWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowWalletGray.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: const InputDecoration(
                    hintText: 'Write a message...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: AppColors.bitcoinOrange,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: enabled ? onSend : null,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.bloomWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
