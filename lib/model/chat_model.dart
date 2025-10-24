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
// TODO: Complete the ChatMessageModel Class
class ChatMessageModel {
  
}