import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'profile_model.dart';

/// 회사 지원자 목록(간단 목록용) 모델
class ApplicantSummary {
  final int studentId;
  final String? name;
  final String? school;
  final String? major;

  ApplicantSummary({
    required this.studentId,
    this.name,
    this.school,
    this.major,
  });

  factory ApplicantSummary.fromJson(Map<String, dynamic> j) {
    return ApplicantSummary(
      studentId: (j['student_id'] as num).toInt(),
      name: j['name'] as String?,
      school: j['school'] as String?,
      major: j['major'] as String?,
    );
  }
}

/// 문서 메타(서버 응답용)
class DocumentOut {
  final String type; // 'resume' | 'cover_letter'
  final String? url; // S3/public url 또는 presigned url
  final String? filename;

  DocumentOut({
    required this.type,
    this.url,
    this.filename,
  });

  factory DocumentOut.fromJson(Map<String, dynamic> j) {
    return DocumentOut(
      type: (j['type'] as String?) ?? '',
      url: j['url'] as String?,
      filename: j['filename'] as String?,
    );
  }
}

class ProfileApi {
  final DioClient _client;
  ProfileApi(this._client);

  // -----------------------------
  // STUDENT: My Student Profile
  // -----------------------------

  /// GET /api/users/me/student-profile (STUDENT only)
  Future<StudentProfile> getMyStudentProfile() async {
    final res = await _client.dio.get(ApiEndpoints.myStudentProfile);
    return StudentProfile.fromJson(res.data as Map<String, dynamic>);
  }

  /// PUT /api/users/me/student-profile (STUDENT only)
  /// - 링크 필드도 서버에서 받을 수 있게 미리 포함(서버가 아직 미지원이면 무시/에러 가능)
  Future<StudentProfile> upsertMyStudentProfile({
    required String name,
    String? school,
    String? major,
    required List<String> skills,
    String? availableTime,

    // ✅ 링크(서버 준비되면 저장)
    String? githubUrl,
    String? portfolioUrl,
    String? linkedinUrl,
    String? notionUrl,
  }) async {
    final res = await _client.dio.put(
      ApiEndpoints.myStudentProfile,
      data: {
        'name': name,
        'school': school,
        'major': major,
        'skills': skills,
        'available_time': availableTime,

        // 링크 필드는 서버 도입 시 바로 사용
        'github_url': githubUrl,
        'portfolio_url': portfolioUrl,
        'linkedin_url': linkedinUrl,
        'notion_url': notionUrl,
      },
    );

    return StudentProfile.fromJson(res.data as Map<String, dynamic>);
  }

  // -----------------------------
  // STUDENT: My Documents
  // -----------------------------

  /// GET /api/users/me/student-documents
  Future<List<DocumentOut>> listMyDocuments() async {
    final res = await _client.dio.get(ApiEndpoints.myStudentDocuments);
    final data = res.data;
    if (data is List) {
      return data
          .map((e) => DocumentOut.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <DocumentOut>[];
  }

  /// POST /api/users/me/student-documents (multipart)
  /// fields:
  /// - type: resume | cover_letter
  /// - file: pdf/doc/docx
  Future<DocumentOut> uploadMyDocument({
    required String type,
    required File file,
  }) async {
    final form = FormData.fromMap({
      'type': type,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });

    final res = await _client.dio.post(
      ApiEndpoints.myStudentDocuments,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    return DocumentOut.fromJson(res.data as Map<String, dynamic>);
  }

  // -----------------------------
  // COMPANY: Applicants
  // -----------------------------

  /// GET /api/companies/me/applicants?job_id=123 (optional)
  Future<List<ApplicantSummary>> listMyApplicants({int? jobId}) async {
    final res = await _client.dio.get(
      ApiEndpoints.companyMyApplicants,
      queryParameters: jobId == null ? null : {'job_id': jobId},
    );

    final data = res.data;
    if (data is List) {
      return data
          .map((e) => ApplicantSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <ApplicantSummary>[];
  }

  /// GET /api/companies/me/applicants/{studentId}/profile
  Future<StudentProfile> getApplicantProfile(int studentId) async {
    final res = await _client.dio.get(
      ApiEndpoints.companyApplicantProfile(studentId),
    );
    return StudentProfile.fromJson(res.data as Map<String, dynamic>);
  }

  /// GET /api/companies/me/applicants/{studentId}/documents
  Future<List<DocumentOut>> listApplicantDocuments(int studentId) async {
    final res = await _client.dio.get(
      ApiEndpoints.companyApplicantDocuments(studentId),
    );

    final data = res.data;
    if (data is List) {
      return data
          .map((e) => DocumentOut.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <DocumentOut>[];
  }

  /// GET /api/companies/me/applicants/{studentId}/documents/{type}/download
  /// 서버가 { "url": "..." } 형태로 주는 방식
  Future<String> getApplicantDocumentDownloadUrl({
    required int studentId,
    required String type, // resume | cover_letter
  }) async {
    final res = await _client.dio.get(
      ApiEndpoints.companyApplicantDocumentDownload(studentId, type),
    );
    final data = res.data;
    if (data is Map && data['url'] is String) {
      return data['url'] as String;
    }
    throw Exception('Invalid download url response');
  }
}
