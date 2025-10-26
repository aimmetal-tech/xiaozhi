import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:xiaozhi/models/chat_model.dart';
import 'package:xiaozhi/services/chat_service.dart';
import 'package:xiaozhi/services/logger_service.dart';
import 'package:xiaozhi/style/glow_background.dart';
import 'package:xiaozhi/utils/toast.dart';
import 'package:xiaozhi/widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isUser = true;
  bool isSending = false;
  bool _scrollScheduled = false;
  final double _autoScrollThreshold = 48;
  StreamSubscription<ChatSSEModel>? _sseSub;

  // 定义控制器，文本编辑控制器和滚动控制器
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> chatHistory = [];

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;
  Size get screenSize => MediaQuery.of(context).size;

  final FocusNode _focusNode = FocusNode();

  void _scrollToBottom() {
    if (_scrollScheduled) return;
    _scrollScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (!_scrollController.hasClients) return;

      final pos = _scrollController.position;
      final distance = pos.maxScrollExtent - pos.pixels;

      if (distance <= _autoScrollThreshold) {
        if (distance < 300) {
          _scrollController.animateTo(
            pos.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(pos.maxScrollExtent);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    chatHistory.add({
      'role': 'system',
      'content':
          '你的名字是小智同学，你会根据用户的问题提出合理的解答，你尤其擅长解决学习问题。当回答用户问题时要用markdown格式进行回答',
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sseSub?.cancel();
    super.dispose();
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
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final role = chatHistory[index]['role'];
                      final text = chatHistory[index]['content'] ?? '';
                      if (role == 'system') return const SizedBox.shrink();
                      return ChatBubble(role: role ?? 'assistant', text: text);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 30, // 按需调大到和圆圈尺寸+边距一致
                child: Center(
                  child: isSending
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('小智正在回应消息'),
                            SpinKitCircle(color: Colors.black, size: 20),
                          ],
                        )
                      : null, // 不发送时占位但不渲染内容
                ),
              ),

              /// 输入框
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        onTapOutside: (_) => _focusNode.unfocus(),
                        controller: _textEditingController,
                        decoration: InputDecoration(hintText: '问问小智...'),
                      ),
                    ),
                    // 发送消息
                    IconButton(
                      icon: Icon(Icons.arrow_upward),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Colors.lightBlue,
                        ),
                      ),
                      onPressed: isSending
                          ? null
                          : () async {
                              try {
                                final content = _textEditingController.text
                                    .trim();
                                if (content.isEmpty) return;
                                // 将用户消息加入历史并清空输入
                                chatHistory.add({
                                  'role': 'user',
                                  'content': content,
                                });
                                _textEditingController.clear();
                                final requestBody = ChatRequestModel(
                                  messages: chatHistory,
                                  stream: true, // 开启流式
                                );

                                // 先插入一条 AI 占位消息
                                setState(() {
                                  isSending = true;
                                  chatHistory.add({
                                    'role': 'assistant',
                                    'content': '',
                                  });
                                });

                                _sseSub = chatServiceStream(requestBody).listen(
                                  (evt) {
                                    if (evt.error != null &&
                                        evt.error!.isNotEmpty) {
                                      if (!context.mounted) return;
                                      logger.e(
                                        'SSE error from stream: ${evt.error!}',
                                      );
                                      ToastUtil.show(
                                        msg: 'SSE错误: ${evt.error}',
                                      );
                                      return;
                                    }
                                    if (evt.done) {
                                      if (!context.mounted) return;
                                      setState(() => isSending = false);
                                      return;
                                    }
                                    if (evt.delta.isNotEmpty) {
                                      setState(() {
                                        // 找到最后一条 assistant 消息，增量拼接
                                        for (
                                          int i = chatHistory.length - 1;
                                          i >= 0;
                                          i--
                                        ) {
                                          if (chatHistory[i]['role'] ==
                                              'assistant') {
                                            final prev =
                                                chatHistory[i]['content'] ?? '';
                                            chatHistory[i]['content'] =
                                                prev + evt.delta;
                                            break;
                                          }
                                        }
                                        _scrollToBottom();
                                      });
                                    }
                                  },
                                  onError: (e) {
                                    if (!context.mounted) return;
                                    logger.e('SSE subscription error: $e');
                                    ToastUtil.show(msg: '异常: $e');
                                    setState(() => isSending = false);
                                  },
                                  onDone: () {
                                    if (!context.mounted) return;
                                    setState(() => isSending = false);
                                  },
                                  cancelOnError: true,
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                logger.e(e.toString());
                                ToastUtil.show(msg: '异常: $e');
                                setState(() => isSending = false);
                              }
                            },
                    ),
                    if (isSending)
                      IconButton(
                        icon: const Icon(Icons.stop),
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Colors.redAccent,
                          ),
                        ),
                        tooltip: '停止生成',
                        onPressed: () async {
                          await _sseSub?.cancel();
                          setState(() => isSending = false);
                        },
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
