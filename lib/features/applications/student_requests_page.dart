import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import '../chat/chat_page.dart';
import 'application_model.dart';

class StudentRequestsPage extends StatefulWidget {
  const StudentRequestsPage({super.key});

  @override
  State<StudentRequestsPage> createState() => _StudentRequestsPageState();
}

class _StudentRequestsPageState extends State<StudentRequestsPage> {
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
    try {
      await scope.applications.refreshOutgoing();
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final me = scope.auth.me;

    if (me == null) {
      return const Scaffold(body: Center(child: Text('Not signed in.')));
    }
    if (me.role != UserRole.STUDENT) {
      return const Scaffold(body: Center(child: Text('Student only.')));
    }

    return AnimatedBuilder(
      animation: scope.applications,
      builder: (context, _) {
        final items = scope.applications.outgoing;
        final pending = scope.applications.pendingOutgoingCount;

        return AppScaffold(
          title: 'My Requests (Outgoing)',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'pending=$pending',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No requests yet.'))
                    : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 10),
                  itemBuilder: (_, i) {
                    final a = items[i];
                    final canChat =
                        a.status == ApplicationStatus.ACCEPTED &&
                            a.roomId != null;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Application #${a.id}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text('JobPost: ${a.jobPostId}'),
                            Text('Company: ${a.companyId}'),
                            Text('Status: ${a.status.name}'),
                            if (a.roomId != null)
                              Text('RoomId: ${a.roomId}'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: canChat
                                        ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatPage(
                                            roomId: a.roomId!,
                                          ),
                                        ),
                                      );
                                    }
                                        : null,
                                    child: const Text('Chat'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
