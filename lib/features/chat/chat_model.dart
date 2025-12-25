class ChatRoomOut {
  final int id;
  final int jobPostId;
  final int companyId;
  final int studentId;

  ChatRoomOut({
    required this.id,
    required this.jobPostId,
    required this.companyId,
    required this.studentId,
  });

  factory ChatRoomOut.fromJson(Map<String, dynamic> j) {
    return ChatRoomOut(
      id: (j['id'] as num).toInt(),
      jobPostId: (j['job_post_id'] as num).toInt(),
      companyId: (j['company_id'] as num).toInt(),
      studentId: (j['student_id'] as num).toInt(),
    );
  }
}

class ChatMessageOut {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String content;

  ChatMessageOut({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
  });

  factory ChatMessageOut.fromJson(Map<String, dynamic> j) {
    return ChatMessageOut(
      id: (j['id'] as num).toInt(),
      chatRoomId: (j['chat_room_id'] as num).toInt(),
      senderId: (j['sender_id'] as num).toInt(),
      content: (j['content'] as String?) ?? '',
    );
  }
}
