import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'chat_model.dart';

class ChatApi {
  final DioClient _client;
  ChatApi(this._client);

  /// GET /api/chat/rooms
  Future<List<ChatRoomOut>> listRooms() async {
    final res = await _client.dio.get(ApiEndpoints.chatRooms);
    final data = (res.data as List? ?? const []);
    return data.map((e) => ChatRoomOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/chat/rooms
  Future<ChatRoomOut> createRoom({
    required int jobPostId,
    required int studentId,
  }) async {
    final res = await _client.dio.post(
      ApiEndpoints.chatRooms,
      data: {
        "job_post_id": jobPostId,
        "student_id": studentId,
      },
    );
    return ChatRoomOut.fromJson(res.data as Map<String, dynamic>);
  }

  /// GET /api/chat/rooms/{roomId}/messages
  Future<List<ChatMessageOut>> listMessages(int roomId) async {
    final res = await _client.dio.get(
      '${ApiEndpoints.chatRooms}/$roomId/messages',
    );
    final data = (res.data as List? ?? const []);
    return data.map((e) => ChatMessageOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/chat/rooms/{roomId}/messages (REST 전송이 필요할 때만)
  Future<ChatMessageOut> sendMessageRest({
    required int roomId,
    required String content,
  }) async {
    final res = await _client.dio.post(
      '${ApiEndpoints.chatRooms}/$roomId/messages',
      data: {"content": content},
    );
    return ChatMessageOut.fromJson(res.data as Map<String, dynamic>);
  }

  /// PUT /api/chat/rooms/{roomId}/read (옵션)
  Future<void> markRead(int roomId) async {
    await _client.dio.put('${ApiEndpoints.chatRooms}/$roomId/read');
  }
}
