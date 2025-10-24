import 'package:flutter/material.dart';
import 'package:xiaozhi/services/credential_service.dart';

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
                    Divider(),
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

class AIChatDrawer extends StatefulWidget {
  const AIChatDrawer({super.key});
  @override
  State<AIChatDrawer> createState() => _AIChatDrawerState();
}

class _AIChatDrawerState extends State<AIChatDrawer> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    ApiKeyStore.async.then((v) {
      if (!mounted) return;
      _controller.text = v ?? '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Kimi API Key'),
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: const InputDecoration(hintText: '输入你的 API Key'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final key = _controller.text.trim();
                    await ApiKeyStore.save(key);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('已保存 API Key')));
                  },
                  child: const Text('保存'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    await ApiKeyStore.clear();
                    if (!context.mounted) return;
                    _controller.clear();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('已清除 API Key')));
                  },
                  child: const Text('清除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
