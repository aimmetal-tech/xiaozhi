import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown.dart';

class ChatBubble extends StatelessWidget {
  final String role;
  final String text;

  const ChatBubble({super.key, required this.role, required this.text});

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    final size = MediaQuery.of(context).size;

    // 最大宽度
    final maxWidth = isUser ? size.width / 1.6 : size.width / 1.35;

    final bubble = Flexible(
      child: Container(
        constraints: BoxConstraints(minHeight: 40, maxWidth: maxWidth),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isUser ? Colors.grey[500] : Colors.tealAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: MarkdownWidget(data: text, shrinkWrap: true),
      ),
    );

    final avatar = CircleAvatar(
      child: Icon(isUser ? Icons.person : Icons.smart_toy_sharp),
    );

    return Padding(
      padding: EdgeInsets.only(top: 32, right: isUser ? 0 : 5),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isUser
            ? [bubble, const SizedBox(width: 20), avatar, SizedBox(width: 20)]
            : [
                const SizedBox(width: 20),
                avatar,
                const SizedBox(width: 20),
                bubble,
              ],
      ),
    );
  }
}
