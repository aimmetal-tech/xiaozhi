import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                child: Text('日期标识', style: textTheme.labelSmall),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '占位 $index',
                        style: textTheme.bodyMedium,
                      ),
                      onTap: () {},
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('用户信息', style: textTheme.bodySmall),
                onTap: () {
                  // 处理用户信息点击
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AIChatDrawer extends StatelessWidget {
  const AIChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      
    );
  }
}