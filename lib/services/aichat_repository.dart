import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiaozhi/services/aichat_service.dart';

const String _storeKey = 'aichat_conversations';

class Conversation {
  final String id;
  final List<ChatMessage> messages;
  final DateTime updatedAt;
  final String? title;

  Conversation({
    required this.id,
    required this.messages,
    required this.updatedAt,
    this.title,
  });

  Conversation copyWith({
    List<ChatMessage>? messages,
    DateTime? updatedAt,
    String? title,
  }) {
    return Conversation(
      id: id,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'updatedAt': updatedAt.toIso8601String(),
    'title': title,
    'messages': messages
        .map(
          (m) => {
            'role': m.role.name,
            'content': m.content,
            'time': m.time.toIso8601String(),
          },
        )
        .toList(),
  };

  static Conversation fromJson(Map<String, dynamic> json) {
    final msgs = (json['messages'] as List<dynamic>)
        .map(
          (e) => ChatMessage(
            role: (e['role'] == 'user') ? ChatRole.user : ChatRole.assistant,
            content: e['content'] as String,
            time: DateTime.parse(e['time'] as String),
          ),
        )
        .toList();
    return Conversation(
      id: json['id'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String?,
      messages: msgs,
    );
  }
}

class AIChatRepository {
  Future<List<Conversation>> listConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> arr = jsonDecode(raw) as List<dynamic>;
    final list = arr
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
    // 按更新时间倒序
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<Conversation?> getConversation(String id) async {
    final list = await listConversations();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertConversation(Conversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await listConversations();
    final idx = list.indexWhere((c) => c.id == conversation.id);
    if (idx >= 0) {
      list[idx] = conversation;
    } else {
      list.add(conversation);
    }
    final raw = jsonEncode(list.map((c) => c.toJson()).toList());
    await prefs.setString(_storeKey, raw);
  }
}
