import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:xiaozhi/pages/shared/drawer_page.dart';
import 'package:xiaozhi/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isUser = true;
  final TextEditingController _textEditingController = TextEditingController();
  final List<Map<String, String>> chatHistory = [];

  Widget userChatBubble(BuildContext context, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 20, 16),
          padding: Vx.m8,
          width: MediaQuery.of(context).size.width / 3,
          decoration: BoxDecoration(
            color: Colors.grey[500],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        CircleAvatar(child: Icon(Icons.person)),
        SizedBox(width: 20),
      ],
    );
  }

  Widget aiChatBubble(BuildContext context, String text) {
    // 与背景色同色
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 20),
        CircleAvatar(child: Icon(Icons.smart_toy_sharp)),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 20, 16),
          padding: Vx.m8,
          width: MediaQuery.of(context).size.width / 3,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: SelectableText(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String text = '示例文字';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'AI对话',
          style: textTheme.headlineLarge?.copyWith(color: Colors.white),
        ),
      ),
      endDrawer: AIChatDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return isUser
                      ? userChatBubble(context, text)
                      : aiChatBubble(context, text);
                },
                itemCount: 5,
              ),
            ),
          ),

          /// 输入框
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(hintText: '问问小智...'),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    // TODO: Send Message to AI
                    String content = _textEditingController.text;
                    chatHistory.add({
                      'role': 'user',
                      'content': content
                    });
                    Map<String, dynamic> requestBody = {
                      'model': 'kimi-k2-0905-preview',
                      'temperature': 0.6,
                      'messages': chatHistory
                    };
                    dynamic response = await chatService(requestBody);
                    log(response.toString());
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
