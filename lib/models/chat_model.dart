import 'dart:convert';

class ChatRequestModel {
  final String model;
  final List<Map<String, String>> messages;
  final double temperature;
  final bool stream;

  ChatRequestModel({
    this.model = 'kimi-k2-0905-preview',
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

class ChatResponseModel {
  final String id;
  final String content;

  ChatResponseModel({required this.id, required this.content});

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final id = data['id'];
    final choices = data['choices'] as List;
    final message = choices.first['message'];
    final content = message['content'];

    return ChatResponseModel(id: id, content: content);
  }
}

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
