import 'package:flutter/material.dart';
import 'package:xiaozhi/pages/shared/drawer_page.dart';

class Aichat extends StatefulWidget {
  const Aichat({super.key});

  @override
  State<Aichat> createState() => _AichatState();
}

class _AichatState extends State<Aichat> {
  bool isUser = true;

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
      endDrawer: AIChatDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50),
                    Column(
                      children: [
                        SizedBox(height: 50),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withAlpha(200),
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Text(
                            '占位$index',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 50),
                  ],
                );
              },
              itemCount: 5,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isUser = !isUser;
              });
            },
            child: Text('AI/User'),
          ),
          SizedBox(height: 50),
          ElevatedButton(onPressed: () {}, child: Text('给DeepSeek发送测试消息')),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
