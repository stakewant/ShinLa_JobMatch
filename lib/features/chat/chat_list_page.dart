import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refresh();
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

  /// =========================
  /// 채팅방 생성 (JobPostId + StudentId)
  /// =========================
  Future<void> _showCreateRoomDialog() async {
    final scope = AppScope.of(context);
    final me = scope.auth.me;
    if (me == null) return;

    if (me.role != UserRole.COMPANY) {
      UiUtils.snack(context, 'Only COMPANY can create chat rooms.');
      return;
    }

    final jobPostIdCtrl = TextEditingController();
    final studentIdCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Chat Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jobPostIdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Job Post ID',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: studentIdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Student ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final jobPostId = UiUtils.tryParseInt(jobPostIdCtrl.text);
    final studentId = UiUtils.tryParseInt(studentIdCtrl.text);

    if (jobPostId == null || studentId == null) {
      UiUtils.snack(context, 'Please enter valid numeric IDs.');
      return;
    }

    setState(() => _loading = true);
    try {
      final room = await scope.chat.createRoom(
        jobPostId: jobPostId,
        studentId: studentId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(roomId: room.id),
        ),
      );
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
    final rooms = scope.chat.rooms;
    final me = scope.auth.me;

    return AppScaffold(
      title: 'Chats',
      floatingActionButton: (me?.role == UserRole.COMPANY)
          ? FloatingActionButton(
        onPressed: _loading ? null : _showCreateRoomDialog,
        child: const Icon(Icons.add),
      )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  me == null
                      ? 'Not signed in'
                      : 'Signed in as ${me.role.name} (id=${me.id})',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: _loading ? null : _refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (rooms.isEmpty
                ? const Center(child: Text('No chat rooms.'))
                : ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 10),
              itemBuilder: (context, i) {
                final r = rooms[i];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatPage(roomId: r.id),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room #${r.id}',
                            style: const TextStyle(
                                fontWeight:
                                FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                              'Job Post ID: ${r.jobPostId}'),
                          Text(
                              'Company ID: ${r.companyId}'),
                          Text(
                              'Student ID: ${r.studentId}'),
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
  }
}
