class ApiEndpoints {
  /// =========================
  /// Base URLs
  /// =========================

  // REST API (FastAPI)
  static const String baseUrl = 'http://15.164.85.176:8000/api';

  // WebSocket (FastAPI)
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
  static const String jobPosts = '/job-posts';

  static String jobPostDetail(String jobPostId) => '/job-posts/$jobPostId';
  static String jobPostImages(String jobPostId) => '/job-posts/$jobPostId/images';

  /// =========================
  /// Chat (REST)
  /// =========================
  static const String chatRooms = '/chat/rooms';
  static String chatRoomDetail(String roomId) => '/chat/rooms/$roomId';

  /// =========================
  /// Chat (WebSocket)
  /// =========================
  static String chatWebSocket(String roomId) => '/ws/chat/$roomId';

  /// =========================
  /// Applications (Chat Requests)
  /// =========================
  static const String applications = '/applications';
  static const String companyApplications = '/applications';
  static const String myApplications = '/applications/me';
  static String applicationAccept(String id) => '/applications/$id/accept';
  static String applicationReject(String id) => '/applications/$id/reject';

  /// =========================
  /// Chatbot (AI Assistant)
  /// =========================
  static const String chatbotChat = '/chatbot/chat';
  static const String chatbotIntents = '/chatbot/intents';

  // ✅ 학생 문서 (⚠ /api 제거)
  static const String myStudentDocuments = '/users/me/student-documents';

  // ✅ 회사 지원자 목록 (⚠ /api 제거)
  static const String companyMyApplicants = '/companies/me/applicants';

  // ✅ 회사 지원자 프로필 (⚠ /api 제거)
  static String companyApplicantProfile(int studentId) =>
      '/companies/me/applicants/$studentId/profile';

  // ✅ 회사 지원자 문서 목록 (⚠ /api 제거)
  static String companyApplicantDocuments(int studentId) =>
      '/companies/me/applicants/$studentId/documents';

  // ✅ 회사 지원자 문서 다운로드 URL (⚠ /api 제거)
  static String companyApplicantDocumentDownload(int studentId, String type) =>
      '/companies/me/applicants/$studentId/documents/$type/download';
}
