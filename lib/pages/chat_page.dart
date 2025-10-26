import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:xiaozhi/models/chat_model.dart';
import 'package:xiaozhi/services/chat_service.dart';
import 'package:xiaozhi/services/conversation_service.dart';
import 'package:xiaozhi/services/logger_service.dart';
import 'package:xiaozhi/style/glow_background.dart';
import 'package:xiaozhi/utils/toast.dart';
import 'package:xiaozhi/widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.initialConversationId});

  final String? initialConversationId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const String _systemPromptContent =
      '你的名字是小智同学，你会根据用户的问题给出合理的回答，你要尽量解决学习问题。当回答用户问题时要使用markdown格式进行回复';

  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<Map<String, String>> _chatHistory = [];
  final ConversationService _convSvc = ConversationService();

  bool _isSending = false;
  bool _scrollScheduled = false;
  final double _autoScrollThreshold = 48;
  StreamSubscription<ChatSSEModel>? _sseSub;
  String? _conversationId;
  String? _firstUserText;
  String _assistantBuffer = '';
  String? _pendingUserMessage;
  bool _pendingMessageStored = false;

  @override
  void initState() {
    super.initState();
    _chatHistory.add({'role': 'system', 'content': _systemPromptContent});
    final initialId = widget.initialConversationId;
    if (initialId != null && initialId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadConversation(initialId);
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sseSub?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollScheduled) return;
    _scrollScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;
      final distance = position.maxScrollExtent - position.pixels;

      if (distance <= _autoScrollThreshold) {
        if (distance < 300) {
          _scrollController.animateTo(
            position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(position.maxScrollExtent);
        }
      }
    });
  }

  String _generateTitle(String text) {
    final trimmed = text.replaceAll('\n', ' ').trim();
    if (trimmed.isEmpty) return '新对话';
    return trimmed.length <= 20 ? trimmed : '${trimmed.substring(0, 20)}…';
  }

  Future<void> _loadConversation(String conversationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastUtil.show(msg: '请先登录');
      return;
    }

    try {
      final messages = await _convSvc.fetchMessages(
        uid: user.uid,
        conversationId: conversationId,
      );
      await _sseSub?.cancel();
      if (!mounted) return;
      setState(() {
        _conversationId = conversationId;
        _isSending = false;
        _assistantBuffer = '';
        _chatHistory
          ..clear()
          ..add({'role': 'system', 'content': _systemPromptContent})
          ..addAll(messages
              .map((m) => {'role': m.role, 'content': m.content}));
      });
      _pendingUserMessage = null;
      _pendingMessageStored = false;
      for (final msg in messages) {
        if (msg.role == 'user' && msg.content.trim().isNotEmpty) {
          _firstUserText = msg.content;
          break;
        }
      }
      _scrollToBottom();
    } catch (e, st) {
      logger.e('加载历史对话失败', error: e, stackTrace: st);
      ToastUtil.show(msg: '加载历史对话失败');
    }
  }

  Future<void> _handleSend() async {
    final content = _textEditingController.text.trim();
    if (content.isEmpty) return;

    _textEditingController.clear();

    _chatHistory.add({'role': 'user', 'content': content});
    _pendingUserMessage = content;
    _pendingMessageStored = false;
    _firstUserText ??= content;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastUtil.show(msg: '未登录，将无法保存对话');
    } else if (_conversationId != null) {
      await _convSvc.addMessage(
        uid: user.uid,
        conversationId: _conversationId!,
        role: 'user',
        content: content,
      );
      _pendingMessageStored = true;
    }

    setState(() {
      _isSending = true;
      _chatHistory.add({'role': 'assistant', 'content': ''});
    });
    _scrollToBottom();

    final requestBody = ChatRequestModel(
      messages: _chatHistory,
      stream: true,
    );

    _assistantBuffer = '';
    _sseSub = chatServiceStream(requestBody).listen(
      (evt) async {
        if (evt.error != null && evt.error!.isNotEmpty) {
          if (!mounted) return;
          logger.e('SSE error: ${evt.error}');
          ToastUtil.show(msg: 'SSE错误: ${evt.error}');
          return;
        }

        if (evt.done) {
          if (!mounted) return;
          setState(() => _isSending = false);
          final user = FirebaseAuth.instance.currentUser;
          if (_conversationId != null && _assistantBuffer.isNotEmpty && user != null) {
            await _convSvc.addMessage(
              uid: user.uid,
              conversationId: _conversationId!,
              role: 'assistant',
              content: _assistantBuffer,
            );
          }
          _assistantBuffer = '';
          _pendingUserMessage = null;
          _pendingMessageStored = false;
          return;
        }

        if (_conversationId == null && evt.id.isNotEmpty) {
          _conversationId = evt.id;
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final title = _generateTitle(_firstUserText ?? _pendingUserMessage ?? '');
            await _convSvc.ensureConversation(
              uid: user.uid,
              conversationId: _conversationId!,
              title: title,
            );
            if (!_pendingMessageStored && _pendingUserMessage != null && _pendingUserMessage!.isNotEmpty) {
              await _convSvc.addMessage(
                uid: user.uid,
                conversationId: _conversationId!,
                role: 'user',
                content: _pendingUserMessage!,
              );
              _pendingMessageStored = true;
            }
          }
        }

        if (evt.delta.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            for (var i = _chatHistory.length - 1; i >= 0; i--) {
              if (_chatHistory[i]['role'] == 'assistant') {
                final previous = _chatHistory[i]['content'] ?? '';
                _chatHistory[i]['content'] = previous + evt.delta;
                break;
              }
            }
            _scrollToBottom();
          });
          _assistantBuffer += evt.delta;
        }
      },
      onError: (error) {
        if (!mounted) return;
        logger.e('SSE subscription error: $error');
        ToastUtil.show(msg: '异常: $error');
        setState(() => _isSending = false);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _isSending = false);
      },
      cancelOnError: true,
    );
  }

  Future<void> _cancelGeneration() async {
    await _sseSub?.cancel();
    setState(() {
      _isSending = false;
    });
    _assistantBuffer = '';
    _pendingUserMessage = null;
    _pendingMessageStored = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GlowBackground(),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final entry = _chatHistory[index];
                      final role = entry['role'];
                      final text = entry['content'] ?? '';
                      if (role == 'system') return const SizedBox.shrink();
                      return ChatBubble(role: role ?? 'assistant', text: text);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                child: Center(
                  child: _isSending
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('小智正在回复消息'),
                            SizedBox(width: 8),
                            SpinKitCircle(color: Colors.black, size: 20),
                          ],
                        )
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        onTapOutside: (_) => _focusNode.unfocus(),
                        controller: _textEditingController,
                        decoration: const InputDecoration(hintText: '向小智提问...'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.lightBlue),
                      ),
                      onPressed: _isSending ? null : _handleSend,
                    ),
                    if (_isSending)
                      IconButton(
                        icon: const Icon(Icons.stop),
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                        ),
                        tooltip: '停止生成',
                        onPressed: _cancelGeneration,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
