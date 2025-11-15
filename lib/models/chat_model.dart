import 'dart:convert';

// 请求模型
class ChatRequestModel {
  final String model;
  final List<Map<String, String>> messages;
  final double temperature;
  final bool stream;

  ChatRequestModel({
    this.model = 'qwen/qwen-plus',
    required this.messages,
    this.temperature = 0.6,
    this.stream = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'stream': stream,
    };
  }
}

// SSE响应模型
class ChatSSEModel {
  final String id;
  final String delta;
  final bool done;
  final String? error;

  ChatSSEModel({
    required this.id,
    required this.delta,
    this.done = false,
    this.error,
  });

  factory ChatSSEModel.fromEventLine(String line) {
    final payload = line.startsWith('data:')
        ? line.substring(5).trim()
        : line.trim();

    if (payload == '[DONE]') {
      return ChatSSEModel(id: '', delta: '', done: true);
    }

    final Map<String, dynamic> json = jsonDecode(payload);

    final id = (json['id'] ?? json['data']?['id'] ?? '') as String;
    final delta =
        (json['choices']?[0]?['delta']?['content'] ??
                json['choices']?[0]?['message']?['content'] ??
                json['data']?['content'] ??
                '')
            as String? ??
        '';

    return ChatSSEModel(id: id, delta: delta);
  }
}

// 消息存储模型
class MessageModel {
  final String? messageId;
  final String role;
  final String content;

  MessageModel({
    required this.role,
    required this.content,
    required this.messageId,
  });
  Map<String, String> toJson() {
    return {'role': role, 'content': content, 'messageId': ?messageId};
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      role: json['role'],
      content: json['content'],
      messageId: json['messageId'],
    );
  }
}
