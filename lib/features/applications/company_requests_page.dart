import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import '../chat/chat_page.dart';
import 'application_model.dart';

class CompanyRequestsPage extends StatefulWidget {
  const CompanyRequestsPage({super.key});

  @override
  State<CompanyRequestsPage> createState() => _CompanyRequestsPageState();
}

class _CompanyRequestsPageState extends State<CompanyRequestsPage> {
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
      await scope.applications.refreshIncoming();
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
    if (me.role != UserRole.COMPANY) {
      return const Scaffold(body: Center(child: Text('Company only.')));
    }

    return AnimatedBuilder(
      animation: scope.applications,
      builder: (context, _) {
        final items = scope.applications.incoming;
        final pendingCount = scope.applications.pendingIncomingCount;

        return AppScaffold(
          title: 'Requests (Incoming)',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'pending=$pendingCount',
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
                  separatorBuilder: (_, __) => const Divider(height: 10),
                  itemBuilder: (_, i) {
                    final a = items[i];
                    final isPending =
                        a.status == ApplicationStatus.REQUESTED;

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
                            Text('Student: ${a.studentId}'),
                            Text('Status: ${a.status.name}'),
                            if (a.roomId != null)
                              Text('RoomId: ${a.roomId}'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: !isPending
                                        ? null
                                        : () async {
                                      try {
                                        await scope.applications
                                            .accept(
                                          applicationId: a.id,
                                        );

                                        if (!context.mounted)
                                          return;

                                        // 최신 데이터에서 roomId 찾기
                                        final updated =
                                        scope.applications
                                            .incoming
                                            .firstWhere(
                                              (x) => x.id == a.id,
                                        );

                                        if (updated.roomId == null) {
                                          UiUtils.snack(
                                            context,
                                            'No roomId returned.',
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatPage(
                                              roomId:
                                              updated.roomId!,
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted)
                                          return;
                                        UiUtils.snack(
                                            context, e.toString());
                                      }
                                    },
                                    child: const Text('Accept'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: !isPending
                                        ? null
                                        : () async {
                                      try {
                                        await scope.applications
                                            .reject(
                                          applicationId: a.id,
                                        );

                                        if (!context.mounted)
                                          return;
                                        UiUtils.snack(
                                            context, 'Rejected.');
                                      } catch (e) {
                                        if (!context.mounted)
                                          return;
                                        UiUtils.snack(
                                            context, e.toString());
                                      }
                                    },
                                    child: const Text('Reject'),
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
