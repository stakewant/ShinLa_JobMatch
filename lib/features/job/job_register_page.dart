import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import 'job_model.dart';

class JobRegisterPage extends StatefulWidget {
  const JobRegisterPage({super.key});

  @override
  State<JobRegisterPage> createState() => _JobRegisterPageState();
}

class _JobRegisterPageState extends State<JobRegisterPage> {
  final _titleCtrl = TextEditingController();
  final _wageCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  JobStatus _status = JobStatus.OPEN;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _wageCtrl.dispose();
    _regionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final scope = AppScope.of(context);
    final me = scope.auth.me;

    if (me == null || me.role != UserRole.COMPANY) {
      UiUtils.snack(context, 'Only COMPANY can create job posts.');
      return;
    }

    final title = _titleCtrl.text.trim();
    final region = _regionCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final wage = UiUtils.tryParseInt(_wageCtrl.text);

    if (title.isEmpty || region.isEmpty) {
      UiUtils.snack(context, 'Title and region are required.');
      return;
    }

    setState(() => _loading = true);
    try {
      await scope.jobs.register(
        title: title,
        wage: wage,
        description: desc,
        region: region,
        status: _status,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register Job Post',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Labeled(label: 'Title', child: TextField(controller: _titleCtrl)),
          const SizedBox(height: 12),
          Labeled(label: 'Region', child: TextField(controller: _regionCtrl)),
          const SizedBox(height: 12),
          Labeled(
            label: 'Wage (optional)',
            child: TextField(controller: _wageCtrl, keyboardType: TextInputType.number),
          ),
          const SizedBox(height: 12),
          Labeled(
            label: 'Status',
            child: DropdownButton<JobStatus>(
              value: _status,
              items: const [
                DropdownMenuItem(value: JobStatus.OPEN, child: Text('OPEN')),
                DropdownMenuItem(value: JobStatus.CLOSED, child: Text('CLOSED')),
              ],
              onChanged: _loading ? null : (v) => setState(() => _status = v ?? JobStatus.OPEN),
            ),
          ),
          const SizedBox(height: 12),
          Labeled(
            label: 'Description',
            child: TextField(
              controller: _descCtrl,
              maxLines: 4,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: _loading ? 'Submitting...' : 'Submit',
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
