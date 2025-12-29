import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

typedef OnMessage = void Function(Map<String, dynamic> data);

class ChatSocket {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  /// 반드시 ws:// 또는 wss:// + /api 포함
  /// 예: ws://52.79.241.167:8000/api
  final String wsBaseUrl;
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

    final url =
        '$wsBaseUrl/ws/chat/$roomId'
        '?token=${Uri.encodeComponent(accessToken)}';

    try {
      // 혹시 남아있는 연결 정리
      await disconnect();

      print('[WS CONNECT TRY] $url');

      _channel = WebSocketChannel.connect(Uri.parse(url));

      _subscription = _channel!.stream.listen(
            (event) {
          try {
            dynamic decoded;

            if (event is String) {
              decoded = jsonDecode(event);
            } else if (event is List<int>) {
              // 🔥 Android/iOS binary frame 대응
              final text = utf8.decode(event);
              decoded = jsonDecode(text);
            }

            if (decoded is Map<String, dynamic>) {
              onMessage(decoded);
            }
          } catch (e) {
            print('[WS PARSE ERROR] $e');
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
        cancelOnError: true,
      );

      _connected = true;
      print('[WS CONNECTED]');
    } catch (e) {
      _connected = false;
      print('[WS CONNECT FAIL] $e');
    }
  }

  void send(String content) {
    if (!_connected || _channel == null) return;

    _channel!.sink.add(
      jsonEncode({"content": content}),
    );
  }

  Future<void> disconnect() async {
    try {
      await _subscription?.cancel();
      await _channel?.sink.close();
    } catch (_) {}

    _subscription = null;
    _channel = null;
    _connected = false;
  }
}
