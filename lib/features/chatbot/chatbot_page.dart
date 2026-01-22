import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import 'chatbot_model.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadIntents();
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIntents() async {
    final scope = AppScope.of(context);
    try {
      await scope.chatbot.loadIntents();
    } catch (e) {
      // 인텐트 로드 실패는 무시 (선택사항)
      print('Failed to load intents: $e');
    }
  }

  Future<void> _send() async {
    final scope = AppScope.of(context);
    final text = _msgController.text.trim();

    if (text.isEmpty) return;

    _msgController.clear();

    try {
      await scope.chatbot.sendMessage(content: text);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, 'Failed to send: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final scope = AppScope.of(context);
      scope.chatbot.clearMessages();
      UiUtils.snack(context, 'Chat cleared');
    }
  }

  void _showIntents() {
    final scope = AppScope.of(context);
    final intents = scope.chatbot.intents;

    if (intents.isEmpty) {
      UiUtils.snack(context, 'No intents available');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Available Topics'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: intents.length,
            itemBuilder: (_, i) {
              final intent = intents[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intent.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Examples: ${intent.examples.join(", ")}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final me = scope.auth.me;

    return AnimatedBuilder(
      animation: scope.chatbot,
      builder: (context, _) {
        final messages = scope.chatbot.messages;
        final botTyping = scope.chatbot.botTyping;
        final intents = scope.chatbot.intents;

        // 새 메시지 도착 시 자동 스크롤
        if (messages.isNotEmpty) {
          _scrollToBottom();
        }

        return AppScaffold(
          title: 'AI Assistant',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status bar
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.smart_toy, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rule-based Chatbot',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (intents.isNotEmpty)
                      TextButton.icon(
                        onPressed: _showIntents,
                        icon: Icon(Icons.help_outline, size: 16),
                        label: Text('Topics', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _clearChat,
                      tooltip: 'Clear chat',
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Messages
              Expanded(
                child: messages.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start chatting with AI assistant!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (intents.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Available topics: ${intents.length}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: _showIntents,
                          child: const Text('View Topics'),
                        ),
                      ],
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: messages.length + (botTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    // Typing indicator
                    if (botTyping && i == messages.length) {
                      return _buildTypingIndicator();
                    }

                    final m = messages[i];
                    final isUser = m.role == MessageRole.USER;

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Card(
                          color: isUser
                              ? Colors.blue[50]
                              : Colors.grey[100],
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUser
                                          ? Icons.person
                                          : Icons.smart_toy,
                                      size: 16,
                                      color: isUser
                                          ? Colors.blue
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isUser ? 'You' : 'AI',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isUser
                                            ? Colors.blue
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTime(m.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m.content,
                                  style: const TextStyle(fontSize: 14),
                                ),
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

              // Input area
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    child: OutlinedButton(
                      onPressed: botTyping ? null : _send,
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Card(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                const Text(
                  'AI is typing',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}