import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'chat_model.dart';

class ChatApi {
  final DioClient _client;
  ChatApi(this._client);

  /// =========================
  /// 채팅방 생성
  /// POST /api/chat/rooms
  /// BODY:
  /// {
  ///   "job_post_id": number,
  ///   "student_id": number
  /// }
  /// =========================
  Future<ChatRoomOut> createRoom({
    required int jobPostId,
    required int studentId,
  }) async {
    final res = await _client.dio.post(
      ApiEndpoints.chatRooms,
      data: {
        'job_post_id': jobPostId,
        'student_id': studentId,
      },
    );

    return ChatRoomOut.fromJson(res.data as Map<String, dynamic>);
  }

  /// =========================
  /// 내 채팅방 목록
  /// GET /api/chat/rooms
  /// =========================
  Future<List<ChatRoomOut>> listRooms() async {
    final res = await _client.dio.get(ApiEndpoints.chatRooms);
    final data = res.data;

    if (data is List) {
      return data
          .map((e) => ChatRoomOut.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response: expected List');
  }

// ❌ 아래 기능들은 서버에 없음
// - listMessages
// - sendMessage
// - markRead
//
// 메시지 송수신은 WebSocket(ChatSocket)으로만 처리해야 함
}
