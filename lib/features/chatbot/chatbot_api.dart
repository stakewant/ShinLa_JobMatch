import '../../core/api/dio_client.dart';
import '../../core/api/api_endpoints.dart';
import 'chatbot_model.dart';

class ChatbotApi {
  final DioClient _client;
  ChatbotApi(this._client);

  /// POST /api/chatbot/chat - 챗봇에게 메시지 전송
  /// Backend: ChatbotRequest(message: str)
  Future<ChatbotResponse> sendMessage({
    required String message,
  }) async {
    final res = await _client.dio.post(
      ApiEndpoints.chatbotChat,
      data: {
        "message": message,
      },
    );
    return ChatbotResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// GET /api/chatbot/intents - 사용 가능한 인텐트 목록
  Future<List<ChatbotIntent>> getIntents() async {
    final res = await _client.dio.get(ApiEndpoints.chatbotIntents);

    // 응답이 List인 경우
    if (res.data is List) {
      return (res.data as List)
          .map((e) => ChatbotIntent.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 응답이 {"intents": [...]} 형태인 경우
    if (res.data is Map && res.data['intents'] != null) {
      return (res.data['intents'] as List)
          .map((e) => ChatbotIntent.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}