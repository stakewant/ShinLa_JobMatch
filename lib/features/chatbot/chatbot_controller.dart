import 'package:flutter/foundation.dart';

import 'chatbot_api.dart';
import 'chatbot_model.dart';

class ChatbotController extends ChangeNotifier {
  final ChatbotApi _api;
  ChatbotController(this._api);

  /// 메시지 히스토리 (로컬에만 저장)
  final List<ChatbotMessage> _messages = [];
  List<ChatbotMessage> get messages => List.unmodifiable(_messages);

  /// 사용 가능한 인텐트
  List<ChatbotIntent> _intents = [];
  List<ChatbotIntent> get intents => List.unmodifiable(_intents);

  /// 로딩 상태
  bool _loading = false;
  bool get loading => _loading;

  /// 봇이 응답 중인지
  bool _botTyping = false;
  bool get botTyping => _botTyping;

  // =========================
  // Intents
  // =========================
  Future<void> loadIntents() async {
    try {
      _intents = await _api.getIntents();
      notifyListeners();
    } catch (e) {
      print('[Chatbot] Failed to load intents: $e');
      rethrow;
    }
  }

  // =========================
  // Messages
  // =========================
  Future<void> sendMessage({
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    // 1. 사용자 메시지 추가
    final userMsg = ChatbotMessage.user(
      content: content.trim(),
    );
    _messages.add(userMsg);
    notifyListeners();

    // 2. 봇 응답 대기
    _botTyping = true;
    notifyListeners();

    try {
      // 3. 서버에 요청
      final response = await _api.sendMessage(
        message: content.trim(),
      );

      // 4. 봇 응답 추가
      final botMsg = ChatbotMessage.bot(
        content: response.reply, // reply 필드 사용
      );
      _messages.add(botMsg);
    } catch (e) {
      // 에러 발생 시 에러 메시지 추가
      final errorMsg = ChatbotMessage.bot(
        content: '죄송합니다. 오류가 발생했습니다: ${e.toString()}',
      );
      _messages.add(errorMsg);
      rethrow;
    } finally {
      _botTyping = false;
      notifyListeners();
    }
  }

  /// 대화 초기화
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  /// 특정 메시지 삭제
  void deleteMessage(String messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}