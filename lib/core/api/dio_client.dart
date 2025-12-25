import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class DioClient {
  final Dio _dio;
  String? _accessToken;

  DioClient()
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final t = _accessToken;
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
          handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setAccessToken(String? token) {
    _accessToken = token;
  }
}
