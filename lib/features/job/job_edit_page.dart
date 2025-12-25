import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import 'job_model.dart';

class JobEditPage extends StatefulWidget {
  final JobPostOut job;
  const JobEditPage({super.key, required this.job});

  @override
  State<JobEditPage> createState() => _JobEditPageState();
}

class _JobEditPageState extends State<JobEditPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _wageCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _descCtrl;

  late JobStatus _status;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.job.title);
    _wageCtrl = TextEditingController(text: widget.job.wage?.toString() ?? '');
    _regionCtrl = TextEditingController(text: widget.job.region);
    _descCtrl = TextEditingController(text: widget.job.description);
    _status = widget.job.status;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _wageCtrl.dispose();
    _regionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final scope = AppScope.of(context);
    final me = scope.auth.me;

    if (me == null || me.role != UserRole.COMPANY) {
      UiUtils.snack(context, 'Only COMPANY can edit job posts.');
      return;
    }
    if (me.id != widget.job.companyId) {
      UiUtils.snack(context, 'You can only edit your own posts.');
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
      await scope.jobs.edit(
        widget.job.id,
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

  Future<void> _addImageUrl() async {
    final scope = AppScope.of(context);
    final urlCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Image URL'),
        content: TextField(
          controller: urlCtrl,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );

    if (ok != true) return;

    final url = urlCtrl.text.trim();
    if (url.isEmpty) {
      UiUtils.snack(context, 'URL is required.');
      return;
    }

    setState(() => _loading = true);
    try {
      await scope.jobs.addImage(widget.job.id, url);
      if (!mounted) return;
      UiUtils.snack(context, 'Image added.');
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
      title: 'Edit Job Post',
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
            child: TextField(controller: _descCtrl, maxLines: 4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: _loading ? 'Saving...' : 'Save',
                  onPressed: _loading ? null : _save,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  text: _loading ? '...' : 'Add Image URL',
                  onPressed: _loading ? null : _addImageUrl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
