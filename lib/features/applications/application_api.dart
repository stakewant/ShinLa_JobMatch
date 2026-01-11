import '../../core/api/dio_client.dart';
import 'application_model.dart';

/// 서버 붙이기 전: 앱 흐름 확인용 Mock API
/// - 실제 서버 연결 시, 아래 메서드들을 Dio 호출로 교체하면 됨.
class ApplicationApi {
  final DioClient _client;
  ApplicationApi(this._client);

  // =========================
  // In-memory store (앱 실행 중 유지)
  // =========================
  static int _seq = 1;
  static final List<ApplicationOut> _store = [];

  // 학생: 요청 보내기
  Future<ApplicationOut> sendRequest({
    required int jobPostId,
    required int companyId,
    required int studentId,
  }) async {
    // 중복 방지: 같은 jobPost에 같은 student가 REJECTED가 아닌 요청이 있으면 기존 반환
    final exists = _store.where((a) =>
    a.jobPostId == jobPostId &&
        a.studentId == studentId &&
        a.status != ApplicationStatus.REJECTED);

    if (exists.isNotEmpty) {
      return exists.first;
    }

    final app = ApplicationOut(
      id: _seq++,
      jobPostId: jobPostId,
      companyId: companyId,
      studentId: studentId,
      status: ApplicationStatus.PENDING,
      createdAt: DateTime.now(),
      roomId: null,
    );
    _store.add(app);
    return app;
  }

  // 회사: 들어온 요청 목록
  Future<List<ApplicationOut>> listIncoming({
    required int companyId,
  }) async {
    final list = _store.where((a) => a.companyId == companyId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // 학생: 내가 보낸 요청 목록
  Future<List<ApplicationOut>> listOutgoing({
    required int studentId,
  }) async {
    final list = _store.where((a) => a.studentId == studentId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // 회사: 수락 (roomId 생성)
  Future<ApplicationOut> accept({
    required int applicationId,
  }) async {
    final idx = _store.indexWhere((a) => a.id == applicationId);
    if (idx < 0) throw Exception('Application not found');

    final current = _store[idx];

    // 수락하면 roomId 생성(임시 규칙)
    final roomId = current.roomId ?? _makeRoomId(current);

    final updated = current.copyWith(
      status: ApplicationStatus.ACCEPTED,
      roomId: roomId,
    );

    _store[idx] = updated;
    return updated;
  }

  // 회사: 거절
  Future<ApplicationOut> reject({
    required int applicationId,
  }) async {
    final idx = _store.indexWhere((a) => a.id == applicationId);
    if (idx < 0) throw Exception('Application not found');

    final current = _store[idx];
    final updated = current.copyWith(status: ApplicationStatus.REJECTED, roomId: null);

    _store[idx] = updated;
    return updated;
  }

  int _makeRoomId(ApplicationOut a) {
    // 충돌 가능성 낮게만: (applicationId * 100000) + jobPostId
    return a.id * 100000 + a.jobPostId;
  }
}
