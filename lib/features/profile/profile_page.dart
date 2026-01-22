import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import 'user_profile_page.dart';
import 'profile_model.dart';
import 'applicant_page.dart';


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

  // ✅ 추가: 링크 입력
  final _githubCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _notionCtrl = TextEditingController();

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

    _githubCtrl.dispose();
    _portfolioCtrl.dispose();
    _linkedinCtrl.dispose();
    _notionCtrl.dispose();

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

      if (p != null) {
        _nameCtrl.text = p.name;
        _schoolCtrl.text = p.school ?? '';
        _majorCtrl.text = p.major ?? '';
        _skillsCtrl.text = p.skills.join(', ');
        _availableCtrl.text = p.availableTime ?? '';

        _githubCtrl.text = p.githubUrl ?? '';
        _portfolioCtrl.text = p.portfolioUrl ?? '';
        _linkedinCtrl.text = p.linkedinUrl ?? '';
        _notionCtrl.text = p.notionUrl ?? '';
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

  String? _normalizeUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return null;
    // 기본적인 방어: http/https 아니면 null 처리(원하면 자동으로 https:// 붙이는 정책도 가능)
    final uri = Uri.tryParse(v);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return v;
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

    final github = _normalizeUrl(_githubCtrl.text);
    final portfolio = _normalizeUrl(_portfolioCtrl.text);
    final linkedin = _normalizeUrl(_linkedinCtrl.text);
    final notion = _normalizeUrl(_notionCtrl.text);

    // 링크가 잘못된 경우(스킴 없음 등) 사용자 안내
    // (원하면 더 엄격하게 검증 가능)
    bool anyInvalid = false;
    if (_githubCtrl.text.trim().isNotEmpty && github == null) anyInvalid = true;
    if (_portfolioCtrl.text.trim().isNotEmpty && portfolio == null) anyInvalid = true;
    if (_linkedinCtrl.text.trim().isNotEmpty && linkedin == null) anyInvalid = true;
    if (_notionCtrl.text.trim().isNotEmpty && notion == null) anyInvalid = true;

    if (anyInvalid) {
      UiUtils.snack(context, 'Please enter valid URLs starting with http/https.');
      return;
    }

    setState(() => _loading = true);
    try {
      // ✅ 서버 저장(기존 필드)
      await scope.profile.saveMyStudentProfile(
        name: name,
        school: school.isEmpty ? null : school,
        major: major.isEmpty ? null : major,
        skills: skills,
        availableTime: available.isEmpty ? null : available,
      );

      // ✅ 앱 상태에 링크 반영(서버 붙기 전 단계)
      scope.profile.setLinksLocal(
        githubUrl: github,
        portfolioUrl: portfolio,
        linkedinUrl: linkedin,
        notionUrl: notion,
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

  StudentDocument? _findDoc(StudentProfile? p, String type) {
    if (p == null) return null;
    for (final d in p.documents) {
      if (d.type == type) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final me = scope.auth.me;
    final studentProfile = scope.profile.myStudentProfile;

    final resume = _findDoc(studentProfile, 'resume');
    final cover = _findDoc(studentProfile, 'cover_letter');

    return AppScaffold(
      title: 'Profile',
      body: me == null
          ? const Center(child: Text('Not signed in.'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User ID: ${me.id}',
                        style:
                        const TextStyle(fontWeight: FontWeight.w700)),
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
              const Text('Student Profile',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              Labeled(label: 'Name', child: TextField(controller: _nameCtrl)),
              const SizedBox(height: 12),
              Labeled(
                  label: 'School (optional)',
                  child: TextField(controller: _schoolCtrl)),
              const SizedBox(height: 12),
              Labeled(
                  label: 'Major (optional)',
                  child: TextField(controller: _majorCtrl)),
              const SizedBox(height: 12),
              Labeled(
                label: 'Skills (comma-separated)',
                child: TextField(
                  controller: _skillsCtrl,
                  decoration: const InputDecoration(
                      hintText: 'e.g. Flutter, Python, SQL'),
                ),
              ),
              const SizedBox(height: 12),
              Labeled(
                label: 'Available Time (optional)',
                child: TextField(
                  controller: _availableCtrl,
                  decoration: const InputDecoration(
                      hintText: 'e.g. Weekdays 18:00~22:00'),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Links',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              Labeled(
                  label: 'GitHub URL (http/https)',
                  child: TextField(controller: _githubCtrl)),
              const SizedBox(height: 12),
              Labeled(
                  label: 'Portfolio URL (http/https)',
                  child: TextField(controller: _portfolioCtrl)),
              const SizedBox(height: 12),
              Labeled(
                  label: 'LinkedIn URL (http/https)',
                  child: TextField(controller: _linkedinCtrl)),
              const SizedBox(height: 12),
              Labeled(
                  label: 'Notion URL (http/https)',
                  child: TextField(controller: _notionCtrl)),

              const SizedBox(height: 16),
              const Text('Documents (select only)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Select Resume',
                      onPressed: _loading
                          ? null
                          : () async {
                        final file =
                        await scope.profile.pickDocumentFile();
                        if (file == null || file.path == null) return;

                        scope.profile.setLocalDocument(
                          type: 'resume',
                          localPath: file.path!,
                          filename: file.name,
                        );
                        if (!mounted) return;
                        UiUtils.snack(context,
                            'Resume selected (not uploaded yet).');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Select Cover Letter',
                      onPressed: _loading
                          ? null
                          : () async {
                        final file =
                        await scope.profile.pickDocumentFile();
                        if (file == null || file.path == null) return;

                        scope.profile.setLocalDocument(
                          type: 'cover_letter',
                          localPath: file.path!,
                          filename: file.name,
                        );
                        if (!mounted) return;
                        UiUtils.snack(context,
                            'Cover letter selected (not uploaded yet).');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Resume: ${resume?.filename ?? "-"}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Cover: ${cover?.filename ?? "-"}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 6),
              const Text(
                'Note: Files are only selected on device. Upload will be added after server API is ready.',
                style: TextStyle(fontSize: 11),
              ),

              const SizedBox(height: 16),
              PrimaryButton(
                text: _loading ? 'Saving...' : 'Save',
                onPressed: _loading ? null : _saveStudentProfile,
              ),
            ] else ...[
              const Text(
                'Company Menu',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                text: 'View Applicants (Demo)',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ApplicantsPage()),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Applicants list is demo based on cached student profiles.\n'
                    'After backend is ready, this will show real applicants.',
                style: TextStyle(fontSize: 12),
              ),
            ],

            // 추가 여백 (맨 아래 공간 확보)
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}