import 'package:flutter/foundation.dart';

import 'chat_api.dart';
import 'chat_model.dart';
import 'chat_socket.dart';
import '../../core/api/api_endpoints.dart';

class ChatController extends ChangeNotifier {
  final ChatApi _api;
  ChatController(this._api);

  /// 채팅방 목록
  List<ChatRoomOut> _rooms = [];
  List<ChatRoomOut> get rooms => _rooms;

  /// roomId -> messages
  final Map<int, List<ChatMessageOut>> _messagesByRoom = {};
  List<ChatMessageOut> messages(int roomId) => _messagesByRoom[roomId] ?? const [];

  /// WebSocket: roomId -> socket
  final Map<int, ChatSocket> _sockets = {};

  /// unread: roomId -> count
  final Map<int, int> _unreadByRoom = {};
  Map<int, int> get unreadByRoom => Map.unmodifiable(_unreadByRoom);

  int unreadCount(int roomId) => _unreadByRoom[roomId] ?? 0;
  int get totalUnread => _unreadByRoom.values.fold<int>(0, (a, b) => a + b);

  /// 현재 열려있는 채팅방(여기서는 unread 증가시키지 않음)
  int? _activeRoomId;
  int? get activeRoomId => _activeRoomId;

  // =========================
  // REST
  // =========================
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

  /// 기존 REST 폴백: 메시지 로딩(필요하면 사용)
  Future<void> refreshMessages(int roomId) async {
    final list = await _api.listMessages(roomId);
    _messagesByRoom[roomId] = list;
    notifyListeners();
  }

  // =========================
  // WebSocket
  // =========================
  Future<void> connectSocket({
    required int roomId,
    required String accessToken,
  }) async {
    if (_sockets.containsKey(roomId)) return;

    final socket = ChatSocket(
      wsBaseUrl: ApiEndpoints.wsBaseUrl,
      accessToken: accessToken,
      roomId: roomId,
      onMessage: (data) {
        if (data['type'] == 'message') {
          _onWsMessage(roomId, data);
        }
      },
    );

    _sockets[roomId] = socket;
    await socket.connect();
  }

  Future<void> disconnectSocket(int roomId) async {
    final socket = _sockets.remove(roomId);
    await socket?.disconnect();
  }

  void sendMessage(int roomId, String content) {
    _sockets[roomId]?.send(content);
  }

  void enterRoom(int roomId) {
    _activeRoomId = roomId;
    _unreadByRoom[roomId] = 0;
    notifyListeners();
  }

  void leaveRoom(int roomId) {
    if (_activeRoomId == roomId) {
      _activeRoomId = null;
      notifyListeners();
    }
  }

  void clearUnreadAll() {
    _unreadByRoom.clear();
    notifyListeners();
  }

  void _onWsMessage(int roomId, Map<String, dynamic> payload) {
    final msg = ChatMessageOut.fromJson(payload);

    _messagesByRoom.putIfAbsent(roomId, () => []);
    final exists = _messagesByRoom[roomId]!.any((m) => m.id == msg.id);
    if (!exists) {
      _messagesByRoom[roomId]!.add(msg);
    }

    // activeRoom이 아니면 unread 증가
    if (_activeRoomId != roomId) {
      _unreadByRoom[roomId] = (_unreadByRoom[roomId] ?? 0) + 1;
    }

    notifyListeners();
  }

  Future<void> disposeAllSockets() async {
    for (final socket in _sockets.values) {
      await socket.disconnect();
    }
    _sockets.clear();
  }
}
