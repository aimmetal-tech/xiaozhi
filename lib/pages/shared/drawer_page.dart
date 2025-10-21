import 'package:flutter/material.dart';
import 'package:xiaozhi/services/aichat_repository.dart';

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
                      title: Text('占位 $index', style: textTheme.bodyMedium),
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

class AIChatDrawer extends StatefulWidget {
  final void Function(String conversationId)? onSelect;
  const AIChatDrawer({super.key, this.onSelect});

  @override
  State<AIChatDrawer> createState() => _AIChatDrawerState();
}

class _AIChatDrawerState extends State<AIChatDrawer> {
  final _repo = AIChatRepository();
  late Future<List<Conversation>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.listConversations();
  }

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
                child: Text('对话历史', style: textTheme.labelSmall),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<Conversation>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return const Center(child: Text('暂无对话'));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final c = items[index];
                        final title = c.title ?? _deriveTitle(c);
                        return ListTile(
                          title: Text(title, style: textTheme.bodyMedium),
                          subtitle: Text(
                            c.updatedAt.toLocal().toString(),
                            style: textTheme.labelSmall,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onSelect?.call(c.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _deriveTitle(Conversation c) {
    // 取第一条用户消息作为标题
    final firstUser = c.messages.firstWhere(
      (m) => m.role.name == 'user',
      orElse: () => c.messages.isNotEmpty
          ? c.messages.first
          : throw StateError('empty conversation'),
    );
    final txt = firstUser.content.trim();
    return txt.length <= 20 ? txt : '${txt.substring(0, 20)}…';
  }
}
