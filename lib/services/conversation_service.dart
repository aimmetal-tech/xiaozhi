import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xiaozhi/services/logger_service.dart';

typedef FirestoreTask = Future<void> Function();
// 带有重试的运行
Future<void> _runWithRetry(FirestoreTask task, {int maxRetry = 3}) async {
  int attempt = 0;
  while (true) {
    try {
      await task();
      return;
    } on FirebaseException catch (e) {
      attempt += 1;
      final canRetry =
          attempt <= maxRetry && (e.code == 'unavailable' || e.code == 'deadline-exceeded');
      logger.w('Firestore 操作失败 (attempt=$attempt, code=${e.code})', error: e);
      if (!canRetry) rethrow;
      final backoff = Duration(milliseconds: 400 * attempt);
      await Future.delayed(backoff);
    }
  }
}
// 会话标题模型
class ConversationSummary {
  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // 构造函数
  ConversationSummary({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
  });
  // 工厂函数-从数据库中获取
  factory ConversationSummary.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final created = data['createdAt'];
    final updated = data['updatedAt'];
    return ConversationSummary(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      createdAt: created is Timestamp ? created.toDate() : null,
      updatedAt: updated is Timestamp ? updated.toDate() : null,
    );
  }
}
// 单条消息模型
class ConversationMessage {
  final String role;
  final String content;

  ConversationMessage({required this.role, required this.content});
  // 工厂函数-从数据库获取
  factory ConversationMessage.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ConversationMessage(
      role: (data['role'] as String?) ?? 'assistant',
      content: (data['content'] as String?) ?? '',
    );
  }
}

class ConversationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // 根据用户id和会话id获取对应的对话引用
  DocumentReference<Map<String, dynamic>> conversationRef(
    String uid,
    String conversationId,
  ) {
    return _db.collection('users').doc(uid).collection('conversations').doc(conversationId);
  }
  // 确保会话存在，若不存在则创建它
  Future<void> ensureConversation({
    required String uid,
    required String conversationId,
    required String title,
  }) async {
    final ref = conversationRef(uid, conversationId);
    final snap = await ref.get();
    if (!snap.exists) {
      await _runWithRetry(() async {
        await ref.set({
          'title': title,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    }
  }
  // 填补标题
  Future<void> updateTitleIfEmpty({
    required String uid,
    required String conversationId,
    required String title,
  }) async {
    final ref = conversationRef(uid, conversationId);
    final snap = await ref.get();
    if (snap.exists) {
      final data = snap.data() ?? {};
      if ((data['title'] as String?) == null || (data['title'] as String?)!.isEmpty) {
        await _runWithRetry(() async {
          await ref.update({'title': title, 'updatedAt': FieldValue.serverTimestamp()});
        });
      }
    } else {
      await ensureConversation(uid: uid, conversationId: conversationId, title: title);
    }
  }
  // 添加Message
  Future<void> addMessage({
    required String uid,
    required String conversationId,
    required String role,
    required String content,
  }) async {
    final ref = conversationRef(uid, conversationId).collection('messages').doc();
    await _runWithRetry(() async {
      await ref.set({
        'role': role,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await conversationRef(uid, conversationId)
          .update({'updatedAt': FieldValue.serverTimestamp()});
    });
  }
  // 更新会话-数据流
  Stream<List<ConversationSummary>> userConversationsStream(String uid) {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .orderBy('updatedAt', descending: true);

    return ref.snapshots().map(
          (snap) => snap.docs
              .map(ConversationSummary.fromSnapshot)
              .toList(),
        );
  }
  // 加载某个会话的所有内容
  Future<List<ConversationMessage>> fetchMessages({
    required String uid,
    required String conversationId,
  }) async {
    try {
      final snapshot = await conversationRef(uid, conversationId)
          .collection('messages')
          .orderBy('createdAt')
          .get();
      return snapshot.docs
          .map(ConversationMessage.fromSnapshot)
          .toList();
    } on FirebaseException catch (e) {
      logger.e('加载会话消息失败', error: e);
      rethrow;
    }
  }
}
