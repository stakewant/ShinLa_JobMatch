/// =========================
/// Chatbot Response Model (서버 응답)
/// Backend: ChatbotResponse(reply: str, source: str)
/// =========================
class ChatbotResponse {
  final String reply;
  final String source;

  ChatbotResponse({
    required this.reply,
    required this.source,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> j) {
    return ChatbotResponse(
      reply: (j['reply'] as String?) ?? '',
      source: (j['source'] as String?) ?? 'rule_based',
    );
  }
}

/// =========================
/// Chatbot Intent Model
/// Backend: {"name": str, "examples": [str]}
/// =========================
class ChatbotIntent {
  final String name;
  final List<String> examples;

  ChatbotIntent({
    required this.name,
    required this.examples,
  });

  factory ChatbotIntent.fromJson(Map<String, dynamic> j) {
    return ChatbotIntent(
      name: (j['name'] as String?) ?? '',
      examples: (j['examples'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// =========================
/// Local Message Model (로컬 저장용)
/// =========================
enum MessageRole { USER, BOT }

class ChatbotMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  ChatbotMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatbotMessage.user({
    required String content,
  }) {
    return ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.USER,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatbotMessage.bot({
    required String content,
  }) {
    return ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.BOT,
      content: content,
      timestamp: DateTime.now(),
    );
  }
}