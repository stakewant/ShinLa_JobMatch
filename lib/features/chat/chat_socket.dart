import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

typedef OnMessage = void Function(Map<String, dynamic> data);

class ChatSocket {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final String wsBaseUrl; // 예: ws://host:8000  또는 wss://host
  final String accessToken;
  final int roomId;
  final OnMessage onMessage;

  bool _connected = false;

  ChatSocket({
    required this.wsBaseUrl,
    required this.accessToken,
    required this.roomId,
    required this.onMessage,
  });

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_connected) return;

    // 반드시 /api 포함된 baseUrl 사용
    // 최종 형태: ws://host:8000/api/ws/chat/{roomId}?token=...
    final url =
        '$wsBaseUrl/ws/chat/$roomId?token=${Uri.encodeComponent(accessToken)}';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _subscription = _channel!.stream.listen(
            (event) {
          final decoded = jsonDecode(event as String);
          if (decoded is Map<String, dynamic>) {
            onMessage(decoded);
          }
        },
        onError: (error) {
          _connected = false;
          print('[WS ERROR] $error');
        },
        onDone: () {
          _connected = false;
          print('[WS CLOSED]');
        },
      );

      //  스트림 리스너 붙은 뒤에 connected 처리
      _connected = true;
      print('[WS CONNECTED] $url');
    } catch (e) {
      _connected = false;
      print('[WS CONNECT FAIL] $e');
    }
  }

  void send(String content) {
    if (!_connected || _channel == null) return;

    // 서버가 receive_json() 후 data["content"]를 읽음
    _channel!.sink.add(jsonEncode({"content": content}));
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
    _connected = false;
  }
}
