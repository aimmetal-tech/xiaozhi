import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xiaozhi/provider/chat_provider.dart';
import 'package:xiaozhi/style/glow_background.dart';
import 'package:xiaozhi/widgets/chat_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, this.conversationId});
  final String? conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageWithRiverpodState();
}

class _ChatPageWithRiverpodState extends ConsumerState<ChatPage> {
  // 控制器类
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final String? _conversationId = widget.conversationId;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 光晕背景
          const GlowBackground(),
          // 聊天区域
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final chatState = ref.watch(chatProvider);
                      return chatState.when(
                        data: (messages) {
                          return ListView.builder(
                            controller: _scrollController,
                            cacheExtent: 300,
                            itemCount: messages.isNotEmpty
                                ? messages.length - 1
                                : 0,
                            itemBuilder: (context, index) {
                              final msg = messages[index + 1];
                              return ChatBubble(
                                role: msg.role,
                                content: msg.content,
                              );
                            },
                          );
                        },
                        error: (error, stacktrace) {
                          return Center(child: Text(error.toString()));
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 0),
              // 输入区域
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withAlpha(127)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                child: Row(
                  children: [
                    // 输入框
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        onTapOutside: (_) => _focusNode.unfocus(),
                        decoration: InputDecoration(hintText: '向小智提问'),
                      ),
                    ),
                    // 发送按钮
                    IconButton(
                      onPressed: () {
                        final String content = _textEditingController.text;
                        if (content.isNotEmpty) {
                          // 发送消息前先清空输入框并使输入框失焦
                          _textEditingController.clear();
                          _focusNode.unfocus();
                          ref.read(chatProvider.notifier).sendMessage(content);
                        }
                      },
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      ),
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
