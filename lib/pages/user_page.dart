import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xiaozhi/provider/auth_provider.dart';
import 'package:xiaozhi/routes/route_config.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            authState.when(
              data: (user) {
                final email = user?.email ?? '未登录';
                final avatarChild = user == null
                    ? const Icon(Icons.person)
                    : Text(
                        email.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                return ListTile(
                  leading: CircleAvatar(child: avatarChild),
                  title: Text(email),
                  subtitle: user == null ? const Text('点击登录') : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(AppRouteNames.authLogin);
                  },
                );
              },
              error: (err, stack) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.error)),
                title: const Text('状态加载失败'),
                subtitle: Text(err.toString()),
              ),
              loading: () => const CircularProgressIndicator(),
            ),
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
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
              },
              label: Text('退出登录'),
              icon: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
