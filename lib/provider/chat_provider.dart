import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xiaozhi/models/chat_model.dart';
import 'package:xiaozhi/services/chat_service.dart';
import 'package:xiaozhi/utils/temp_uuid_generator.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  String? _conversationId;

  @override
  FutureOr<List<MessageModel>> build() {
    return [
      MessageModel(role: 'user', content: '你是小智同学, 一名AI学习助理', messageId: ''),
    ];
  }

  // 发送消息并处理回复
  Future<void> sendMessage(String content) async {
    // 拷贝构建历史对话并将用户消息添加到历史中, 避免state意外篡改
    var history = List<MessageModel>.from(state.value ?? []);
    // 判断是否为新对话
    final isNewConversation = _conversationId == null;
    // 待定临时ID，新对话则为临时ID，否则直接使用会话ID
    final pendingTempId =
        isNewConversation ? generateTempUuid() : _conversationId!;
    // 将消息添加到history队列中
    history.add(
      MessageModel(
        role: 'user',
        content: content,
        messageId: pendingTempId,
      ),
    );
    // 发送时先渲染一次，后面处理sse时还要再渲染
    state = AsyncValue.data(history);

    // 构建请求
    final request = ChatRequestModel(
      messages: history.map((m) => m.toJson()).toList(),
    );
    // 创建缓冲区
    final deltaBuffer = StringBuffer();
    String? assistantMessageId;
    // 处理请求
    await for (final sseModel in chatServiceStream(request)) {
      deltaBuffer.write(sseModel.delta);
      // 如果还没有会话id且响应id不为空 则从响应中获取
      if (assistantMessageId == null && sseModel.id.isNotEmpty) {
        assistantMessageId = sseModel.id;
        if (_conversationId == null) {
          // 赋值给会话id
          _conversationId = assistantMessageId;
          history = history
              .map(
                // 将原先的临时id替换成真正的会话id
                (msg) => msg.messageId == pendingTempId
                    ? MessageModel(
                        role: msg.role,
                        content: msg.content,
                        messageId: assistantMessageId!,
                      )
                    : msg,
              )
              .toList();
          state = AsyncValue.data(history);
        }
      }
      // 创建新引用，触发riverpod界面重建
      final updated = List<MessageModel>.from(history);
      if (updated.isNotEmpty && updated.last.role == 'assistant') {
        updated[updated.length - 1] = MessageModel(
          role: 'assistant',
          content: deltaBuffer.toString(),
          messageId: assistantMessageId ?? '',
        );
      } else {
        updated.add(
          MessageModel(
            role: 'assistant',
            content: deltaBuffer.toString(),
            messageId: assistantMessageId ?? '',
          ),
        );
      }
      state = AsyncValue.data(updated);
    }
  }
}
