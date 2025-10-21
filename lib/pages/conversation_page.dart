import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:xiaozhi/pages/shared/drawer_page.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  bool isUser = false;
  final TextEditingController _textEditingController = TextEditingController();

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
                  onPressed: () {
                    // TODO: Send Message to AI
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
