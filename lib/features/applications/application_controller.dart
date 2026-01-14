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
      _incoming.where((a) => a.status == ApplicationStatus.REQUESTED).length;

  int get pendingOutgoingCount =>
      _outgoing.where((a) => a.status == ApplicationStatus.REQUESTED).length;

  int get acceptedOutgoingCount =>
      _outgoing.where((a) => a.status == ApplicationStatus.ACCEPTED).length;

  // =========================
  // 학생: 요청 보내기
  // =========================
  Future<void> sendRequest({
    required int jobPostId,
  }) async {
    await _api.sendRequest(jobPostId: jobPostId);

    // 서버 기준 재조회
    await refreshOutgoing();
  }

  // =========================
  // 회사: 들어온 요청 목록
  // =========================
  Future<void> refreshIncoming() async {
    _loadingIncoming = true;
    notifyListeners();
    try {
      _incoming = await _api.listIncoming();
    } finally {
      _loadingIncoming = false;
      notifyListeners();
    }
  }

  // =========================
  // 학생: 내가 보낸 요청 목록
  // =========================
  Future<void> refreshOutgoing() async {
    _loadingOutgoing = true;
    notifyListeners();
    try {
      _outgoing = await _api.listOutgoing();
    } finally {
      _loadingOutgoing = false;
      notifyListeners();
    }
  }

  // =========================
  // 회사: 수락
  // =========================
  Future<void> accept({
    required int applicationId,
  }) async {
    await _api.accept(applicationId: applicationId);
    await refreshIncoming();
  }

  // =========================
  // 회사: 거절
  // =========================
  Future<void> reject({
    required int applicationId,
  }) async {
    await _api.reject(applicationId: applicationId);
    await refreshIncoming();
  }
}
