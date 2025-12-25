import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'auth_model.dart';

class AuthApi {
  final DioClient _client;
  AuthApi(this._client);

  Future<UserOut> signup({
    String? email,
    String? phone,
    required String password,
    required UserRole role,
  }) async {
    final res = await _client.dio.post(
      ApiEndpoints.signup,
      data: {
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.name,
      },
    );
    return UserOut.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TokenResponse> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final res = await _client.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return TokenResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserOut> me() async {
    final res = await _client.dio.get(ApiEndpoints.me);
    return UserOut.fromJson(res.data as Map<String, dynamic>);
  }
}
