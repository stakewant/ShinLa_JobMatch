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
}
