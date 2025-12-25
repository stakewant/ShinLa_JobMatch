import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'profile_model.dart';

class ProfileApi {
  final DioClient _client;
  ProfileApi(this._client);

  // GET /api/users/me/student-profile (STUDENT only)
  Future<StudentProfile> getMyStudentProfile() async {
    final res = await _client.dio.get(ApiEndpoints.myStudentProfile);
    return StudentProfile.fromJson(res.data as Map<String, dynamic>);
  }

  // PUT /api/users/me/student-profile (STUDENT only)
  Future<StudentProfile> upsertMyStudentProfile({
    required String name,
    String? school,
    String? major,
    required List<String> skills,
    String? availableTime,
  }) async {
    final res = await _client.dio.put(
      ApiEndpoints.myStudentProfile,
      data: {
        'name': name,
        'school': school,
        'major': major,
        'skills': skills,
        'available_time': availableTime,
      },
    );
    return StudentProfile.fromJson(res.data as Map<String, dynamic>);
  }
}
