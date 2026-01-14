import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'application_model.dart';

class ApplicationApi {
  final DioClient _client;
  ApplicationApi(this._client);

  /// 학생: 요청 보내기
  Future<ApplicationOut> sendRequest({
    required int jobPostId,
  }) async {
    print('POST ${ApiEndpoints.applications}');
    print('BODY: { job_post_id: $jobPostId }');

    final res = await _client.dio.post(
      ApiEndpoints.applications,
      data: {
        "job_post_id": jobPostId,
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    print('STATUS: ${res.statusCode}');
    print('RESPONSE: ${res.data}');

    return ApplicationOut.fromJson(res.data);
  }


  /// 회사: 들어온 요청 목록
  Future<List<ApplicationOut>> listIncoming({String? status}) async {
    final res = await _client.dio.get(
      ApiEndpoints.applications,
      queryParameters: status != null ? {"status": status} : null,
    );

    return (res.data as List)
        .map((e) => ApplicationOut.fromJson(e))
        .toList();
  }

  /// 학생: 내가 보낸 요청 목록
  Future<List<ApplicationOut>> listOutgoing() async {
    final res = await _client.dio.get(
      '${ApiEndpoints.applications}/me',
    );

    return (res.data as List)
        .map((e) => ApplicationOut.fromJson(e))
        .toList();
  }

  /// 회사: 수락
  Future<void> accept({required int applicationId}) async {
    await _client.dio.post(
      '${ApiEndpoints.applications}/$applicationId/accept',
    );
  }

  /// 회사: 거절
  Future<void> reject({required int applicationId}) async {
    await _client.dio.post(
      '${ApiEndpoints.applications}/$applicationId/reject',
    );
  }
}
