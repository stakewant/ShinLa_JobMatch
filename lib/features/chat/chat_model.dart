/// =========================
/// Chat Room Model
/// =========================
class ChatRoomOut {
  final int id;
  final int jobPostId;
  final int companyId;
  final int? studentId; // ✅ 서버에서 null 가능

  ChatRoomOut({
    required this.id,
    required this.jobPostId,
    required this.companyId,
    this.studentId,
  });

  factory ChatRoomOut.fromJson(Map<String, dynamic> j) {
    return ChatRoomOut(
      id: (j['id'] as num).toInt(),
      jobPostId: (j['job_post_id'] as num).toInt(),
      companyId: (j['company_id'] as num).toInt(),
      studentId: j['student_id'] == null
          ? null
          : (j['student_id'] as num).toInt(),
    );
  }
}

/// =========================
/// Chat Message Model
/// (WebSocket payload 대응)
/// =========================
class ChatMessageOut {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String content;
  final DateTime? createdAt;

  ChatMessageOut({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.createdAt,
  });

  factory ChatMessageOut.fromJson(Map<String, dynamic> j) {
    DateTime? createdAt;
    final raw = j['created_at'];
    if (raw is String) {
      createdAt = DateTime.tryParse(raw);
    }

    return ChatMessageOut(
      id: (j['id'] as num).toInt(),
      chatRoomId: (j['chat_room_id'] as num).toInt(),
      senderId: (j['sender_id'] as num).toInt(),
      content: (j['content'] as String?) ?? '',
      createdAt: createdAt,
    );
  }
}
