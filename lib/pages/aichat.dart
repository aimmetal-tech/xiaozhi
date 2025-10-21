import 'package:flutter/material.dart';
import 'package:xiaozhi/pages/shared/drawer_page.dart';
import 'package:xiaozhi/services/aichat_service.dart';
import 'package:xiaozhi/services/aichat_repository.dart';

class Aichat extends StatefulWidget {
  const Aichat({super.key});

  @override
  State<Aichat> createState() => _AichatState();
}

class _AichatState extends State<Aichat> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIChatService _service = AIChatService();
  final AIChatRepository _repo = AIChatRepository();
  bool _isSending = false;
  String? _conversationId; // 首次回复返回的 id 作为会话ID

  @override
  void initState() {
    super.initState();
    // 添加一条欢迎消息
    _messages.add(
      ChatMessage(
        role: ChatRole.assistant,
        content: '你好！我是小智，有什么我可以帮助你的吗？',
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 发送消息到AI
  void _sendMessage() async {
    String text = _textController.text.trim();
    if (text.isEmpty) return;

    // 添加用户消息到列表
    setState(() {
      _messages.add(
        ChatMessage(role: ChatRole.user, content: text, time: DateTime.now()),
      );
      _textController.clear();
      _isSending = true;
    });

    // 滚动到最新消息
    _scrollToBottom();

    // 发送请求到AI
    try {
      final reply = await _service.send(_messages);

      // 添加AI回复到消息列表
      setState(() {
        _messages.add(reply.message);
        _isSending = false;
      });

      // 初始化会话ID（取首次回复的 id）
      _conversationId ??= reply.id;

      // 持久化会话
      await _repo.upsertConversation(
        Conversation(
          id: _conversationId!,
          messages: _messages,
          updatedAt: DateTime.now(),
          title: null,
        ),
      );

      // 滚动到最新消息
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            role: ChatRole.assistant,
            content: '抱歉，我遇到了一些问题，请稍后再试。',
            time: DateTime.now(),
          ),
        );
        _isSending = false;
      });

      // 滚动到最新消息
      _scrollToBottom();
    }
  }

  // 滚动到消息列表底部
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

  // 构建消息气泡
  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.role == ChatRole.user;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.blue,
              child: Icon(Icons.android, size: 15, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.lightBlue[300] : Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                message.content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 15, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'AI对话',
          style: textTheme.headlineLarge?.copyWith(color: Colors.white),
        ),
      ),
      endDrawer: AIChatDrawer(
        onSelect: (id) async {
          await _loadConversationById(id);
        },
      ),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      body: Column(
        children: [
          Flexible(
            flex: 9,
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100]),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('小智正在输入...'),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: AnimatedPadding(
          duration: Duration(milliseconds: 20),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: '问问小智...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.lightBlue),
                ),
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadConversationById(String id) async {
    final c = await _repo.getConversation(id);
    if (c == null) return;
    setState(() {
      _conversationId = c.id;
      _messages
        ..clear()
        ..addAll(c.messages);
      _isSending = false;
    });
    _scrollToBottom();
  }
}
