import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import 'job_detail_page.dart';
import 'job_register_page.dart';
import 'job_model.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  bool _loading = false;

  final _regionCtrl = TextEditingController();
  JobStatus? _status; // null = all

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted)
      {
        return;
      }
      _refresh();
    });
  }

  @override
  void dispose() {
    _regionCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final scope = AppScope.of(context);

    setState(() => _loading = true);
    try {
      await scope.jobs.refresh(
        region: _regionCtrl.text.trim().isEmpty ? null : _regionCtrl.text.trim(),
        status: _status,
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
    final me = scope.auth.me;
    final items = scope.jobs.items.where((e) => !e.isDeleted).toList();

    final canCreate = me != null && me.role == UserRole.COMPANY;

    return AppScaffold(
      title: 'Jobs',
      floatingActionButton: canCreate
          ? FloatingActionButton(
        onPressed: _loading
            ? null
            : () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JobRegisterPage()),
          );
          if (!mounted) return;
          await _refresh();
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _regionCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Filter by region (optional)',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<JobStatus?>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: null, child: Text('ALL')),
                  DropdownMenuItem(value: JobStatus.OPEN, child: Text('OPEN')),
                  DropdownMenuItem(value: JobStatus.CLOSED, child: Text('CLOSED')),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
              IconButton(
                onPressed: _loading ? null : _refresh,
                icon: const Icon(Icons.search),
                tooltip: 'Search',
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (items.isEmpty
                ? const Center(child: Text('No job posts.'))
                : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 10),
              itemBuilder: (context, i) {
                final p = items[i];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => JobDetailPage(jobId: p.id)),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text('Region: ${p.region}'),
                          Text('Wage: ${p.wage ?? '-'}'),
                          Text('Status: ${p.status.name}'),
                          Text('Company ID: ${p.companyId}'),
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
