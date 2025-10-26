import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(leading: CircleAvatar(), title: Text('用户')),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Column(children: [Icon(Icons.star), Text('收藏')]),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Column(
                          children: [Icon(Icons.history), Text('搜题记录')],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Column(children: [Icon(Icons.folder), Text('资料')]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(title: Text('设置')),
                    ListTile(title: Text('设置')),
                    ListTile(title: Text('设置')),
                    ListTile(title: Text('设置')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
