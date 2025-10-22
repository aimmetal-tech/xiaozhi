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
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.history),
                      title: Text('历史记录', style: textTheme.bodySmall),
                      onTap: () {},
                    ),
                    Divider()
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('用户信息', style: textTheme.bodySmall),
                onTap: () {},
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
    return Drawer();
  }
}
