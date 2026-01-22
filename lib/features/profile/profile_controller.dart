import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'profile_api.dart';
import 'profile_model.dart';

class ProfileController extends ChangeNotifier {
  final ProfileApi _api;
  ProfileController(this._api);

  StudentProfile? _myStudentProfile;
  StudentProfile? get myStudentProfile => _myStudentProfile;

  // ✅ 데모/캐시: 회사 화면에서 지원자 목록으로 쓸 수 있게 저장
  final Map<int, StudentProfile> _studentCache = {};
  List<StudentProfile> get cachedStudentProfiles =>
      _studentCache.values.toList()
        ..sort((a, b) => a.userId.compareTo(b.userId));

  void _cache(StudentProfile p) {
    _studentCache[p.userId] = p;
  }

  // -----------------------------
  // STUDENT: 내 프로필 로드/저장
  // -----------------------------

  Future<void> loadMyStudentProfile() async {
    final p = await _api.getMyStudentProfile();

    // ✅ 서버가 링크/문서를 아직 안 내려줄 수 있으니, 로컬 상태 유지 병합
    final prev = _myStudentProfile;
    _myStudentProfile = p.copyWith(
      githubUrl: prev?.githubUrl,
      portfolioUrl: prev?.portfolioUrl,
      linkedinUrl: prev?.linkedinUrl,
      notionUrl: prev?.notionUrl,
      documents: prev?.documents,
    );

    if (_myStudentProfile != null) _cache(_myStudentProfile!);
    notifyListeners();
  }

  Future<StudentProfile> saveMyStudentProfile({
    required String name,
    String? school,
    String? major,
    required List<String> skills,
    String? availableTime,

    // (선택) 서버가 링크도 받는 시점이면 여기에 넣어도 됨
    String? githubUrl,
    String? portfolioUrl,
    String? linkedinUrl,
    String? notionUrl,
  }) async {
    final saved = await _api.upsertMyStudentProfile(
      name: name,
      school: school,
      major: major,
      skills: skills,
      availableTime: availableTime,

      githubUrl: githubUrl,
      portfolioUrl: portfolioUrl,
      linkedinUrl: linkedinUrl,
      notionUrl: notionUrl,
    );

    // ✅ 로컬 링크/문서 보존 병합
    final prev = _myStudentProfile;
    _myStudentProfile = saved.copyWith(
      githubUrl: prev?.githubUrl,
      portfolioUrl: prev?.portfolioUrl,
      linkedinUrl: prev?.linkedinUrl,
      notionUrl: prev?.notionUrl,
      documents: prev?.documents,
    );

    if (_myStudentProfile != null) _cache(_myStudentProfile!);
    notifyListeners();
    return _myStudentProfile!;
  }

  // -----------------------------
  // ✅ 앱-only: 링크/문서 로컬 반영
  // -----------------------------

  void setLinksLocal({
    String? githubUrl,
    String? portfolioUrl,
    String? linkedinUrl,
    String? notionUrl,
  }) {
    final p = _myStudentProfile;
    if (p == null) return;

    _myStudentProfile = p.copyWith(
      githubUrl: githubUrl,
      portfolioUrl: portfolioUrl,
      linkedinUrl: linkedinUrl,
      notionUrl: notionUrl,
    );

    _cache(_myStudentProfile!);
    notifyListeners();
  }

  Future<PlatformFile?> pickDocumentFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      withData: false,
    );
    if (res == null || res.files.isEmpty) return null;
    return res.files.single;
  }

  void setLocalDocument({
    required String type, // 'resume' | 'cover_letter'
    required String localPath,
    required String filename,
  }) {
    final p = _myStudentProfile;
    if (p == null) return;

    final docs = [...p.documents];
    final idx = docs.indexWhere((d) => d.type == type);

    final newDoc = StudentDocument(
      type: type,
      localPath: localPath,
      filename: filename,
      url: null,
    );

    if (idx >= 0) {
      docs[idx] = newDoc;
    } else {
      docs.add(newDoc);
    }

    _myStudentProfile = p.copyWith(documents: docs);

    _cache(_myStudentProfile!);
    notifyListeners();
  }

  // -----------------------------
  // COMPANY: 지원자 프로필 조회
  // -----------------------------
  Future<StudentProfile> loadApplicantProfile(int studentId) async {
    final p = await _api.getApplicantProfile(studentId);

    // ✅ 회사가 본 지원자도 캐시에 넣어두면 ApplicantsPage에서도 활용 가능
    _cache(p);
    notifyListeners();
    return p;
  }

  void clear() {
    _myStudentProfile = null;
    _studentCache.clear();
    notifyListeners();
  }
}
