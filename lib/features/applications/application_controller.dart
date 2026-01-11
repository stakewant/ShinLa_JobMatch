import 'package:flutter/foundation.dart';

import 'application_api.dart';
import 'application_model.dart';

class ApplicationController extends ChangeNotifier {
  final ApplicationApi _api;
  ApplicationController(this._api);

  List<ApplicationOut> _incoming = [];
  List<ApplicationOut> get incoming => _incoming;

  List<ApplicationOut> _outgoing = [];
  List<ApplicationOut> get outgoing => _outgoing;

  bool _loadingIncoming = false;
  bool get loadingIncoming => _loadingIncoming;

  bool _loadingOutgoing = false;
  bool get loadingOutgoing => _loadingOutgoing;

  // =========================
  // Badge counters
  // =========================
  int get pendingIncomingCount =>
      _incoming.where((a) => a.status == ApplicationStatus.PENDING).length;

  int get pendingOutgoingCount =>
      _outgoing.where((a) => a.status == ApplicationStatus.PENDING).length;

  int get acceptedOutgoingCount =>
      _outgoing.where((a) => a.status == ApplicationStatus.ACCEPTED).length;

  /// 학생: 요청 보내기
  Future<void> sendRequest({
    required int studentId,
    required int companyId,
    required int jobPostId,
  }) async {
    await _api.sendRequest(
      jobPostId: jobPostId,
      companyId: companyId,
      studentId: studentId,
    );

    // 학생 목록 즉시 갱신(뱃지 포함)
    await refreshOutgoing(studentId: studentId);
  }

  /// 회사: 들어온 요청 목록
  Future<void> refreshIncoming({
    required int companyId,
  }) async {
    _loadingIncoming = true;
    notifyListeners();
    try {
      _incoming = await _api.listIncoming(companyId: companyId);
    } finally {
      _loadingIncoming = false;
      notifyListeners();
    }
  }

  /// 학생: 내가 보낸 요청 목록
  Future<void> refreshOutgoing({
    required int studentId,
  }) async {
    _loadingOutgoing = true;
    notifyListeners();
    try {
      _outgoing = await _api.listOutgoing(studentId: studentId);
    } finally {
      _loadingOutgoing = false;
      notifyListeners();
    }
  }

  /// 회사: 수락
  Future<ApplicationOut> accept({
    required int applicationId,
  }) async {
    final updated = await _api.accept(applicationId: applicationId);
    return updated;
  }

  /// 회사: 거절
  Future<ApplicationOut> reject({
    required int applicationId,
  }) async {
    final updated = await _api.reject(applicationId: applicationId);
    return updated;
  }
}
