import 'package:flutter/material.dart';

import '../../data/chat_repository.dart';
import '../../models/chat_message.dart';
import '../../theme/app_colors.dart';
import '../home/home_screen.dart';
import '../home/widgets/app_bottom_nav_bar.dart';
import '../journey/journey_screen.dart';
import '../menu/side_menu.dart';
import '../quiz/quiz_categories_screen.dart';
import 'belle_conversation_screen.dart';

/// A single past conversation, derived for display from the one
/// continuous message history [ChatRepository] stores. There's no
/// separate "session" concept in the underlying NIP-17 data — Belle is one
/// ongoing relationship with the user, not independent threads — so
/// sessions here are a display-only grouping: a new one starts whenever
/// there's a gap of more than [_BelleScreenState._sessionGap] between
/// messages, similar to how messaging apps visually break up a long
/// history by time. Tapping any session opens the same underlying
/// conversation; the grouping is a browsing aid, not a data boundary.
class _ChatSession {
  const _ChatSession({required this.title, required this.lastMessageAt});

  final String title;
  final DateTime lastMessageAt;
}

const _historyPreviewCount = 4;

class BelleScreen extends StatefulWidget {
  const BelleScreen({super.key});

  @override
  State<BelleScreen> createState() => _BelleScreenState();
}

class _BelleScreenState extends State<BelleScreen> {
  static const _sessionGap = Duration(hours: 3);

  List<_ChatSession>? _sessions;
  bool _showAll = false;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final messages = await ChatRepository.instance.fetchHistory();
    final sessions = _groupIntoSessions(messages);
    if (mounted) setState(() => _sessions = sessions);
  }

  List<_ChatSession> _groupIntoSessions(List<ChatMessage> messages) {
    final groups = <List<ChatMessage>>[];
    var current = <ChatMessage>[];

    for (final message in messages) {
      if (current.isNotEmpty &&
          message.sentAt.difference(current.last.sentAt) > _sessionGap) {
        groups.add(current);
        current = [];
      }
      current.add(message);
    }
    if (current.isNotEmpty) groups.add(current);

    return groups.reversed.map((group) {
      final firstUserMessage = group.firstWhere(
        (m) => !m.fromBelle,
        orElse: () => group.first,
      );
      return _ChatSession(
        title: _truncate(firstUserMessage.text),
        lastMessageAt: group.last.sentAt,
      );
    }).toList();
  }

  String _truncate(String text) {
    const maxLength = 48;
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';
  }

  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      case 1:
        return;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QuizCategoriesScreen()),
        );
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const JourneyScreen()),
        );
    }
  }

  void _openConversation() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BelleConversationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sessions = _sessions;

    final visible = sessions == null
        ? null
        : _query.isEmpty
        ? (_showAll ? sessions : sessions.take(_historyPreviewCount).toList())
        : sessions
              .where((s) => s.title.toLowerCase().contains(_query))
              .toList();

    return Scaffold(
      backgroundColor: AppColors.softBabyPink,
      endDrawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.softBabyPink,
        elevation: 0,
        actionsIconTheme: const IconThemeData(color: AppColors.glamPink),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.bitcoinOrange,
        foregroundColor: AppColors.bloomWhite,
        onPressed: _openConversation,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundImage: AssetImage(
                      'assets/images/belle_avatar.png',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Hi, Bestie 👋', style: textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    "I'm Belle! Ready to break down Bitcoin with some "
                    "beauty analogies? Let's get glowing.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedMauve,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.mutedMauve,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('History', style: textTheme.headlineSmall),
                if (_query.isEmpty &&
                    sessions != null &&
                    sessions.length > _historyPreviewCount &&
                    !_showAll)
                  TextButton(
                    onPressed: () => setState(() => _showAll = true),
                    child: const Text('SEE ALL'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (visible == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  _query.isEmpty
                      ? 'No conversations yet — tap the + button to start '
                            'chatting with Belle!'
                      : 'No conversations match your search.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedMauve,
                  ),
                ),
              )
            else
              for (final session in visible) ...[
                _HistoryTile(session: session, onTap: _openConversation),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onTabTap(context, index),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.session, required this.onTap});

  final _ChatSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.bloomWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softBabyPink,
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: AppColors.glamPink,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: textTheme.titleLarge?.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatRelativeTime(session.lastMessageAt),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedMauve,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// A small "2 hours ago" / "Yesterday" / "May 08, 2026" formatter — kept
/// local to this feature rather than pulling in the `intl` package for
/// one formatting need.
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24 && dateTime.day == now.day) {
    return '${difference.inHours}h ago';
  }

  final yesterday = now.subtract(const Duration(days: 1));
  if (dateTime.year == yesterday.year &&
      dateTime.month == yesterday.month &&
      dateTime.day == yesterday.day) {
    return 'Yesterday';
  }

  final month = _monthNames[dateTime.month - 1];
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$month $day, ${dateTime.year}';
}
