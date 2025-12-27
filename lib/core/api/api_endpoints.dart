class ApiEndpoints {
  static const String baseUrl = 'http://52.79.241.167:8000/api'; // 실서버 연결 시 변경

  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';

  // Users
  static const String me = '/users/me';
  static const String myStudentProfile = '/users/me/student-profile';

  // Jobs
  static const String jobs = '/jobs';
  static String jobDetail(String id) => '/jobs/$id';

  // Job Posts
  static const String jobPosts = '/job-posts';

  // Chat
  static const String chatRooms = '/chat/rooms';
  static String chatRoomDetail(String id) => '/chats/rooms/$id';

  // Profile
  static const String profile = '/profile';
  static String profileById(String userId) => '/profile/$userId';
}
