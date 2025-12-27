import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';

class ChatPage extends StatefulWidget {
  final int roomId;
  const ChatPage({super.key, required this.roomId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final scope = AppScope.of(context);
    setState(() => _loading = true);
    try {
      await scope.chat.refreshMessages(widget.roomId);
      await scope.chat.read(widget.roomId);
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final scope = AppScope.of(context);

    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);
    try {
      await scope.chat.send(widget.roomId, text);
      _msgController.clear();
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final me = scope.auth.me;
    final messages = scope.chat.messages(widget.roomId);

    return AppScaffold(
      title: 'Chat Room #${widget.roomId}',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  me == null ? 'Not signed in' : 'Me: ${me.role.name} (id=${me.id})',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final isMine = me != null && m.senderId == me.id;

                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text('Sender: ${m.senderId}', style: const TextStyle(fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(m.content),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _loading ? null : _send(),
                  decoration: const InputDecoration(hintText: 'Type a message...'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: OutlinedButton(
                  onPressed: _loading ? null : _send,
                  child: Text(_loading ? '...' : 'Send'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
