import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'job_model.dart';

class JobApi {
  final DioClient _client;
  JobApi(this._client);

  // GET /api/job-posts?region=...&status=OPEN|CLOSED
  Future<List<JobPostOut>> list({String? region, JobStatus? status}) async {
    final res = await _client.dio.get(
      ApiEndpoints.jobPosts,
      queryParameters: {
        if (region != null && region.trim().isNotEmpty) 'region': region.trim(),
        if (status != null) 'status': status.name,
      },
    );

    final data = res.data;
    if (data is List) {
      return data.map((e) => JobPostOut.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Unexpected response: expected List');
  }

  // GET /api/job-posts/{id}
  Future<JobPostOut> detail(int id) async {
    final res = await _client.dio.get('${ApiEndpoints.jobPosts}/$id');
    return JobPostOut.fromJson(res.data as Map<String, dynamic>);
  }

  // POST /api/job-posts
  Future<JobPostOut> create({
    required String title,
    required int? wage,
    required String description,
    required String region,
    required JobStatus status,
  }) async {
    final res = await _client.dio.post(
      ApiEndpoints.jobPosts,
      data: {
        'title': title,
        'wage': wage,
        'description': description,
        'region': region,
        'status': status.name,
      },
    );
    return JobPostOut.fromJson(res.data as Map<String, dynamic>);
  }

  // PUT /api/job-posts/{id}
  Future<JobPostOut> update(
      int id, {
        String? title,
        int? wage,
        String? description,
        String? region,
        JobStatus? status,
        bool? isDeleted,
      }) async {
    final res = await _client.dio.put(
      '${ApiEndpoints.jobPosts}/$id',
      data: {
        if (title != null) 'title': title,
        if (wage != null) 'wage': wage,
        if (description != null) 'description': description,
        if (region != null) 'region': region,
        if (status != null) 'status': status.name,
        if (isDeleted != null) 'is_deleted': isDeleted,
      },
    );
    return JobPostOut.fromJson(res.data as Map<String, dynamic>);
  }

  // POST /api/job-posts/{id}/images
  Future<JobImageOut> addImage(int jobPostId, String imageUrl) async {
    final res = await _client.dio.post(
      '${ApiEndpoints.jobPosts}/$jobPostId/images',
      data: {'image_url': imageUrl},
    );
    return JobImageOut.fromJson(res.data as Map<String, dynamic>);
  }
}
