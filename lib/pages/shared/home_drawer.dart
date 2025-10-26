import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:xiaozhi/routes/route_config.dart';
import 'package:xiaozhi/services/conversation_service.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('历史对话', style: textTheme.titleSmall),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    if (user == null) {
                      return const Center(child: Text('登录以查看历史记录'));
                    }
                    return _ConversationList(uid: user.uid);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final service = ConversationService();

    return StreamBuilder<List<ConversationSummary>>(
      stream: service.userConversationsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('加载失败: ${snapshot.error}'));
        }
        final conversations = snapshot.data ?? const [];
        if (conversations.isEmpty) {
          return const Center(child: Text('暂无历史记录'));
        }
        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (context, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final convo = conversations[index];
            final updated = convo.updatedAt?.toLocal();
            final subtitle = updated != null
                ? '${updated.year}-${updated.month.toString().padLeft(2, '0')}-${updated.day.toString().padLeft(2, '0')} ${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}'
                : '暂无时间';
            return ListTile(
              title: Text(convo.title.isEmpty ? '未命名会话' : convo.title),
              subtitle: Text(subtitle),
              onTap: () {
                if (convo.id.isEmpty) return;
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.pushNamed(
                  AppRouteNames.chatDetail,
                  pathParameters: {'conversationId': convo.id},
                );
              },
            );
          },
        );
      },
    );
  }
}
