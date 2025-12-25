import 'package:flutter/foundation.dart';
import 'chat_api.dart';
import 'chat_model.dart';

class ChatController extends ChangeNotifier {
  final ChatApi _api;
  ChatController(this._api);

  List<ChatRoomOut> _rooms = [];
  List<ChatRoomOut> get rooms => _rooms;

  final Map<int, List<ChatMessageOut>> _messagesByRoom = {};
  List<ChatMessageOut> messages(int roomId) => _messagesByRoom[roomId] ?? const [];

  Future<void> refreshRooms() async {
    _rooms = await _api.listRooms();
    notifyListeners();
  }

  Future<ChatRoomOut> createRoom({
    required int jobPostId,
    required int studentId,
  }) async {
    final room = await _api.createRoom(jobPostId: jobPostId, studentId: studentId);
    await refreshRooms();
    return room;
  }

  Future<void> refreshMessages(int roomId) async {
    _messagesByRoom[roomId] = await _api.listMessages(roomId);
    notifyListeners();
  }

  Future<void> send(int roomId, String content) async {
    await _api.sendMessage(roomId, content);
    await refreshMessages(roomId);
  }

  Future<void> read(int roomId) async {
    await _api.markRead(roomId);
  }
}
