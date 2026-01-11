import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _refresh();
    });
  }

  Future<void> _refresh() async {
    final scope = AppScope.of(context);
    setState(() => _loading = true);
    try {
      await scope.chat.refreshRooms();
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return AnimatedBuilder(
      animation: scope.chat,
      builder: (context, _) {
        final rooms = scope.chat.rooms;

        return AppScaffold(
          title: 'Chats',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rooms: ${rooms.length} | Unread: ${scope.chat.totalUnread}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: _loading && rooms.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : (rooms.isEmpty
                    ? const Center(child: Text('No chat rooms.'))
                    : ListView.separated(
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => const Divider(height: 10),
                  itemBuilder: (_, i) {
                    final r = rooms[i];
                    final unread = scope.chat.unreadCount(r.id);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatPage(roomId: r.id)),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Room #${r.id}',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('jobPostId: ${r.jobPostId}'),
                                    Text('companyId: ${r.companyId} / studentId: ${r.studentId}'),
                                  ],
                                ),
                              ),
                              if (unread > 0) _Badge(count: unread),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count >= 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
