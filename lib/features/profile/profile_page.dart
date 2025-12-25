import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import 'user_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController(); // comma-separated
  final _availableCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadIfStudent();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _majorCtrl.dispose();
    _skillsCtrl.dispose();
    _availableCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadIfStudent() async {
    final scope = AppScope.of(context);
    final me = scope.auth.me;
    if (me == null) return;

    if (me.role != UserRole.STUDENT) return;

    setState(() => _loading = true);
    try {
      await scope.profile.loadMyStudentProfile();
      final p = scope.profile.myStudentProfile;

      // populate form
      if (p != null) {
        _nameCtrl.text = p.name;
        _schoolCtrl.text = p.school ?? '';
        _majorCtrl.text = p.major ?? '';
        _skillsCtrl.text = p.skills.join(', ');
        _availableCtrl.text = p.availableTime ?? '';
      }
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> _parseSkills(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _saveStudentProfile() async {
    final scope = AppScope.of(context);
    final me = scope.auth.me;

    if (me == null || me.role != UserRole.STUDENT) {
      UiUtils.snack(context, 'Only STUDENT can edit student profile.');
      return;
    }

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      UiUtils.snack(context, 'Name is required.');
      return;
    }

    final school = _schoolCtrl.text.trim();
    final major = _majorCtrl.text.trim();
    final available = _availableCtrl.text.trim();
    final skills = _parseSkills(_skillsCtrl.text);

    setState(() => _loading = true);
    try {
      await scope.profile.saveMyStudentProfile(
        name: name,
        school: school.isEmpty ? null : school,
        major: major.isEmpty ? null : major,
        skills: skills,
        availableTime: available.isEmpty ? null : available,
      );
      if (!mounted) return;
      UiUtils.snack(context, 'Saved.');
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
    final studentProfile = scope.profile.myStudentProfile;

    return AppScaffold(
      title: 'Profile',
      body: me == null
          ? const Center(child: Text('Not signed in.'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: ${me.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Role: ${me.role.name}'),
                  Text('Email: ${me.email ?? "-"}'),
                  Text('Phone: ${me.phone ?? "-"}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          PrimaryButton(
            text: 'View as Page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfilePage(
                    user: me,
                    studentProfile: studentProfile,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          if (me.role == UserRole.STUDENT) ...[
            const Text('Student Profile', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            Labeled(label: 'Name', child: TextField(controller: _nameCtrl)),
            const SizedBox(height: 12),
            Labeled(label: 'School (optional)', child: TextField(controller: _schoolCtrl)),
            const SizedBox(height: 12),
            Labeled(label: 'Major (optional)', child: TextField(controller: _majorCtrl)),
            const SizedBox(height: 12),
            Labeled(
              label: 'Skills (comma-separated)',
              child: TextField(
                controller: _skillsCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Flutter, Python, SQL'),
              ),
            ),
            const SizedBox(height: 12),
            Labeled(
              label: 'Available Time (optional)',
              child: TextField(
                controller: _availableCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Weekdays 18:00~22:00'),
              ),
            ),
            const SizedBox(height: 16),

            PrimaryButton(
              text: _loading ? 'Saving...' : 'Save',
              onPressed: _loading ? null : _saveStudentProfile,
            ),
          ] else ...[
            const Text(
              'No editable profile fields for COMPANY on the current server.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
