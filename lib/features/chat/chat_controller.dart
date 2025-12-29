import 'package:flutter/foundation.dart';

import '../../core/api/api_endpoints.dart';
import 'chat_api.dart';
import 'chat_model.dart';
import 'chat_socket.dart';

class ChatController extends ChangeNotifier {
  final ChatApi _api;
  ChatController(this._api);

  /// =========================
  /// 채팅방 목록
  /// =========================
  List<ChatRoomOut> _rooms = [];
  List<ChatRoomOut> get rooms => _rooms;

  /// =========================
  /// 메시지 상태
  /// roomId -> messages
  /// =========================
  final Map<int, List<ChatMessageOut>> _messagesByRoom = {};

  List<ChatMessageOut> messages(int roomId) =>
      _messagesByRoom[roomId] ?? const [];

  /// =========================
  /// WebSocket 관리
  /// roomId -> socket
  /// =========================
  final Map<int, ChatSocket> _sockets = {};

  /// =========================
  /// 채팅방 목록 갱신 (REST)
  /// =========================
  Future<void> refreshRooms() async {
    _rooms = await _api.listRooms();
    notifyListeners();
  }

  /// =========================
  /// 채팅방 생성 (REST)
  /// =========================
  Future<ChatRoomOut> createRoom({
    required int jobPostId,
    required int studentId,
  }) async {
    final room = await _api.createRoom(
      jobPostId: jobPostId,
      studentId: studentId,
    );
    await refreshRooms();
    return room;
  }

  /// =========================
  /// WebSocket 연결
  /// =========================
  Future<void> connectSocket({
    required int roomId,
    required String accessToken,
  }) async {
    if (_sockets.containsKey(roomId)) return;

    final socket = ChatSocket(
      wsBaseUrl: ApiEndpoints.wsBaseUrl, // ✅ 여기 핵심
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

  /// =========================
  /// WebSocket 해제
  /// =========================
  Future<void> disconnectSocket(int roomId) async {
    final socket = _sockets.remove(roomId);
    await socket?.disconnect();
  }

  /// =========================
  /// 메시지 전송 (WebSocket)
  /// =========================
  void sendMessage(int roomId, String content) {
    _sockets[roomId]?.send(content);
  }

  /// =========================
  /// 메시지 수신 처리
  /// =========================
  void _onWsMessage(int roomId, Map<String, dynamic> payload) {
    final msg = ChatMessageOut.fromJson(payload);

    _messagesByRoom.putIfAbsent(roomId, () => []);

    final exists =
    _messagesByRoom[roomId]!.any((m) => m.id == msg.id);
    if (exists) return;

    _messagesByRoom[roomId]!.add(msg);
    notifyListeners();
  }

  /// =========================
  /// 전체 소켓 정리
  /// =========================
  Future<void> disposeAllSockets() async {
    for (final socket in _sockets.values) {
      await socket.disconnect();
    }
    _sockets.clear();
  }
}
