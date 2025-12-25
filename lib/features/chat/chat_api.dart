import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'chat_model.dart';

class ChatApi {
  final DioClient _client;
  ChatApi(this._client);

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

  Future<List<ChatMessageOut>> listMessages(int roomId) async {
    final res = await _client.dio.get('${ApiEndpoints.chatRooms}/$roomId/messages');
    final data = res.data;

    if (data is List) {
      return data
          .map((e) => ChatMessageOut.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response: expected List');
  }

  Future<ChatMessageOut> sendMessage(int roomId, String content) async {
    final res = await _client.dio.post(
      '${ApiEndpoints.chatRooms}/$roomId/messages',
      data: {'content': content},
    );
    return ChatMessageOut.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> markRead(int roomId) async {
    await _client.dio.put('${ApiEndpoints.chatRooms}/$roomId/read');
  }
}
