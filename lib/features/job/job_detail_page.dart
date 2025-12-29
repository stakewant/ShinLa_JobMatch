import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import '../chat/chat_list_page.dart';
import '../chat/chat_page.dart';
import 'job_edit_page.dart';
import 'job_model.dart';

class JobDetailPage extends StatefulWidget {
  final int jobId;
  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool _loading = false;
  JobPostOut? _job;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    final scope = AppScope.of(context);
    setState(() => _loading = true);
    try {
      _job = await scope.jobs.detail(widget.jobId);
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goEdit(JobPostOut job) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobEditPage(job: job)),
    );
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final me = scope.auth.me;
    final job = _job;

    final isMine = job != null &&
        me != null &&
        me.role == UserRole.COMPANY &&
        me.id == job.companyId;

    return AppScaffold(
      title: 'Job Detail',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (job == null
          ? const Center(child: Text('Job not found.'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Region: ${job.region}'),
                  Text('Wage: ${job.wage ?? '-'}'),
                  Text('Status: ${job.status.name}'),
                  const SizedBox(height: 10),
                  const Text(
                    'Description',
                    style:
                    TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(job.description.isEmpty
                      ? '-'
                      : job.description),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (job.images.isNotEmpty) ...[
            const Text(
              'Images',
              style:
              TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: job.images.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 10),
                itemBuilder: (_, i) {
                  final img = job.images[i];
                  return Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(12),
                      child: Text(img.imageUrl),
                    ),
                  );
                },
              ),
            ),
          ] else
            const Spacer(),

          const SizedBox(height: 12),

          if (isMine)
            PrimaryButton(
              text: 'Edit Post',
              onPressed: () => _goEdit(job),
            ),

          const SizedBox(height: 10),

          /// =========================
          /// 채팅 버튼
          /// =========================
          if (me != null && me.role == UserRole.COMPANY)
            PrimaryButton(
              text: 'Start Chat',
              onPressed: () async {
                final studentIdCtrl =
                TextEditingController();

                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text(
                        'Create Chat Room'),
                    content: TextField(
                      controller: studentIdCtrl,
                      keyboardType:
                      TextInputType.number,
                      decoration:
                      const InputDecoration(
                        labelText: 'Student ID',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(
                                context, false),
                        child:
                        const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(
                                context, true),
                        child:
                        const Text('Create'),
                      ),
                    ],
                  ),
                );

                if (ok != true) return;

                final studentId =
                UiUtils.tryParseInt(
                    studentIdCtrl.text);
                if (studentId == null) {
                  UiUtils.snack(context,
                      'Invalid Student ID');
                  return;
                }

                try {
                  final room =
                  await scope.chat.createRoom(
                    jobPostId: job.id,
                    studentId: studentId,
                  );

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                          roomId: room.id),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  UiUtils.snack(
                      context, e.toString());
                }
              },
            )
          else
            PrimaryButton(
              text: 'Go to Chats',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const ChatListPage(),
                  ),
                );
              },
            ),
        ],
      )),
    );
  }
}
