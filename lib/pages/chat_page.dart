import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:xiaozhi/models/chat_model.dart';
import 'package:xiaozhi/pages/shared/drawer_page.dart';
import 'package:xiaozhi/services/chat_service.dart';
import 'package:xiaozhi/services/logger_service.dart';
import 'package:xiaozhi/utils/toast.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isUser = true;
  bool isSending = false;
  // 定义控制器，文本编辑控制器和滚动控制器
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> chatHistory = [];

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;
  Size get screenSize => MediaQuery.of(context).size;

  final FocusNode _focusNode = FocusNode();

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

  Widget userChatBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                minHeight: 40,
                maxWidth: screenSize.width / 1.6,
              ),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(8),
              ),
              child: MarkdownWidget(data: text, shrinkWrap: true),
            ),
          ),
          const SizedBox(width: 20),
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget aiChatBubble(String text) {
    // 与背景色同色
    return Padding(
      padding: const EdgeInsets.only(top: 32, right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20),
          CircleAvatar(child: Icon(Icons.smart_toy_sharp)),
          SizedBox(width: 20),
          Flexible(
            child: Container(
              constraints: BoxConstraints(minHeight: 40, maxWidth: screenSize.width / 1.35),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.tealAccent,
              ),
              child: MarkdownWidget(data: text, shrinkWrap: true),
            ),
          ),
        ],
      ),
    );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'AI对话',
          style: textTheme.headlineLarge?.copyWith(color: Colors.white),
        ),
      ),
      endDrawer: AIChatDrawer(),
      drawerEdgeDragWidth: screenSize.width,
      body: Column(
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
                  return role == 'user'
                      ? userChatBubble(text)
                      : aiChatBubble(text);
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
                  onPressed: isSending
                      ? null
                      : () async {
                          String content = _textEditingController.text.trim();
                          // 如果输入框为空不做反应
                          if (content.isEmpty) return;
                          // 设置状态为正在发送，并将数据添加到历史记录
                          setState(() => isSending = true);
                          chatHistory.add({'role': 'user', 'content': content});
                          // 清空输入框
                          _textEditingController.clear();
                          try {
                            final requestBody = ChatRequestModel(
                              messages: chatHistory,
                            );
                            final responseJson = await chatService(requestBody);
                            // 如果回应标识为不成功
                            if (responseJson['success'] != true) {
                              /* 
                                在异步函数内判断上下文Widget是否已经销毁 (dispose)
                                因为接下来可能要用到context
                              */
                              if (!context.mounted) return;
                              ToastUtil.show(
                                msg: '请求失败 ${responseJson['error'] ?? '未知错误'}',
                              );
                              setState(() => isSending = false);
                              return;
                            }
                            // 如果回应标识为成功
                            final responseModel = ChatResponseModel.fromJson(
                              responseJson,
                            );

                            chatHistory.add({
                              'role': 'assistant',
                              'content': responseModel.content,
                            });

                            setState(() {
                              isSending = false;
                              _scrollToBottom();
                            });
                          } catch (e) {
                            if (!context.mounted) return;
                            logger.e(e.toString());
                            ToastUtil.show(msg: '异常: $e');
                            setState(() => isSending = false);
                          }
                        },
                  icon: Icon(Icons.arrow_upward),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.lightBlue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
