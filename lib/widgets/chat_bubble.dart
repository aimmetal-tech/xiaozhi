import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:xiaozhi/style/markdown_config.dart';

class ChatBubble extends StatelessWidget {
  final String role;
  final String content;

  const ChatBubble({super.key, required this.role, required this.content});

  bool _looksLikeMarkdown(String s) {
    return s.contains('```') ||
        s.contains('\n') ||
        s.contains('#') ||
        s.contains('* ') ||
        s.contains('- ') ||
        s.contains('](');
  }

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    // 最大宽度
    final maxWidth = isUser ? size.width / 1.6 : size.width / 1.2;
    final Widget content = isUser || !_looksLikeMarkdown(this.content)
        ? SelectableText(
            this.content,
            style: textTheme.bodySmall!.copyWith(fontSize: 16),
          )
        : MarkdownWidget(data: this.content, shrinkWrap: true, config: buildMarkdownConfig(context),);

    final bubble = UnconstrainedBox(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 40, maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser ? Colors.grey[500] : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(padding: const EdgeInsets.all(8), child: content),
        ),
      ),
    );

    final avatar = CircleAvatar(
      radius: 15,
      child: Icon(isUser ? Icons.person : Icons.smart_toy_sharp, size: 15),
    );

    return Padding(
      padding: EdgeInsets.only(top: 32, right: isUser ? 0 : 5),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isUser
            ? [bubble, const SizedBox(width: 10), avatar, SizedBox(width: 10)]
            : [
                const SizedBox(width: 10),
                avatar,
                const SizedBox(width: 10),
                bubble,
              ],
      ),
    );
  }
}
