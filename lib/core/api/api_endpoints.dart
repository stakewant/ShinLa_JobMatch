class ApiEndpoints {
  /// =========================
  /// Base URLs
  /// =========================

  // REST API (FastAPI)
  static const String baseUrl = 'http://15.164.85.176:8000/api';

  // WebSocket (FastAPI)
  // ws:// 또는 wss:// (HTTPS면 wss)
  static const String wsBaseUrl = 'ws://15.164.85.176:8000/api';

  /// =========================
  /// Auth
  /// =========================
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';

  /// =========================
  /// Users
  /// =========================
  static const String me = '/users/me';
  static const String myStudentProfile = '/users/me/student-profile';

  /// =========================
  /// Job Posts
  /// =========================
  // Swagger 기준: /api/job-posts
  static const String jobPosts = '/job-posts';

  // GET /api/job-posts/{job_post_id}
  static String jobPostDetail(String jobPostId) =>
      '/job-posts/$jobPostId';

  // POST /api/job-posts/{job_post_id}/images
  static String jobPostImages(String jobPostId) =>
      '/job-posts/$jobPostId/images';

  /// =========================
  /// Chat (REST)
  /// =========================
  // GET  /api/chat/rooms
  // POST /api/chat/rooms
  static const String chatRooms = '/chat/rooms';

  // (현재 서버에는 상세 조회 API 없음 → placeholder)
  // 필요하면 서버에 추가 후 사용
  static String chatRoomDetail(String roomId) =>
      '/chat/rooms/$roomId';

  /// =========================
  /// Chat (WebSocket)
  /// =========================
  // ws://host:8000/api/ws/chat/{roomId}?token=...
  static String chatWebSocket(String roomId) =>
      '/ws/chat/$roomId';

  /// =========================
  /// Applications (Requests)
  /// =========================

  // 학생: 요청 보내기
  static const String applications = '/applications';

  // 회사: 들어온 요청 목록 (예: /applications/incoming?status=PENDING)
  static const String applicationsIncoming = '/applications/incoming';

  // 학생: 내가 보낸 요청 목록
  static const String applicationsOutgoing = '/applications/outgoing';

  // 회사: 수락/거절
  static String applicationAccept(String id) => '/applications/$id/accept';
  static String applicationReject(String id) => '/applications/$id/reject';

}
