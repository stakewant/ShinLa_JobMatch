import 'package:flutter/foundation.dart';
import 'profile_api.dart';
import 'profile_model.dart';

class ProfileController extends ChangeNotifier {
  final ProfileApi _api;
  ProfileController(this._api);

  StudentProfile? _myStudentProfile;
  StudentProfile? get myStudentProfile => _myStudentProfile;

  Future<void> loadMyStudentProfile() async {
    _myStudentProfile = await _api.getMyStudentProfile();
    notifyListeners();
  }

  Future<StudentProfile> saveMyStudentProfile({
    required String name,
    String? school,
    String? major,
    required List<String> skills,
    String? availableTime,
  }) async {
    final saved = await _api.upsertMyStudentProfile(
      name: name,
      school: school,
      major: major,
      skills: skills,
      availableTime: availableTime,
    );
    _myStudentProfile = saved;
    notifyListeners();
    return saved;
  }

  void clear() {
    _myStudentProfile = null;
    notifyListeners();
  }
}
