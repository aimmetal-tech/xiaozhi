import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:xiaozhi/utils/toast.dart';

MarkdownConfig buildMarkdownConfig(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  Widget tableWrapHorizontalScroll(Widget child) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        primary: false,
        scrollDirection: Axis.horizontal,
        child: child,
      ),
    );
  }

  return MarkdownConfig(
    configs: [
      PConfig(textStyle: const TextStyle(fontSize: 16, height: 1.6)),
      H1Config(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      H2Config(
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      H3Config(
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      // 行内代码
      CodeConfig(
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Misans',
          backgroundColor: Color.fromARGB(255, 226, 227, 235),
        ),
      ),
      // 代码块
      PreConfig(
        textStyle: const TextStyle(fontSize: 13, fontFamily: 'JetBrainsMono'),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        wrapper: (child, code, language) {
          return Stack(
            children: [
              child,
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ToastUtil.show(msg: '已复制到剪切板');
                  },
                ),
              ),
            ],
          );
        },
      ),
      // 表格
      TableConfig(
        headerStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyStyle: TextStyle(fontSize: 14),
        wrapper: tableWrapHorizontalScroll,
      ),
      // 链接
      LinkConfig(style: TextStyle(color: colorScheme.primary)),
    ],
  );
}
