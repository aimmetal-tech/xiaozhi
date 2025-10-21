import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:xiaozhi/services/logger.dart';

/// 对话角色
enum ChatRole { user, assistant }

extension ChatRoleApi on ChatRole {
  String get apiValue => this == ChatRole.user ? 'user' : 'assistant';
}

/// 单条消息模型
class ChatMessage {
  final ChatRole role;
  final String content;
  final DateTime time;

  ChatMessage({required this.role, required this.content, required this.time});

  Map<String, String> toApiMap() => {'role': role.apiValue, 'content': content};
}

/// 统一的聊天异常
class AIChatException implements Exception {
  final String code;
  final String message;
  AIChatException(this.code, this.message);

  @override
  String toString() => 'AIChatException($code): $message';
}

/// AI 聊天服务
class AIChatService {
  final String baseUrl;
  final String? apiKey;
  final http.Client _client;

  AIChatService({String? baseUrl, String? apiKey, http.Client? client})
    : baseUrl = baseUrl ?? 'https://api.moonshot.cn/v1/chat/completions',
      apiKey = apiKey ?? dotenv.env['KIMI_API_KEY'],
      _client = client ?? http.Client();

  Future<AIReply> send(
    List<ChatMessage> history, {
    String model = 'kimi-k2-0905-preview',
    double temperature = 0.3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw AIChatException('no_api_key', '缺少 KIMI_API_KEY 配置');
    }

    final body = jsonEncode({
      'model': model,
      'messages': history.map((m) => m.toApiMap()).toList(),
      'temperature': temperature,
    });

    logger.d('AIChat request: $body');

    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(timeout);
    } catch (e) {
      logger.w('HTTP error: $e');
      throw AIChatException('network_error', '网络请求失败，请稍后重试');
    }

    if (response.statusCode != 200) {
      logger.w('Request failed: ${response.statusCode} ${response.body}');
      throw AIChatException('http_${response.statusCode}', '服务响应异常，请稍后再试');
    }

    logger.d('AIChat response: ${response.body}');

    try {
      final parsed = _parseAIResponse(response.body);
      final message = ChatMessage(
        role: ChatRole.assistant,
        content: parsed.content,
        time: DateTime.now(),
      );
      return AIReply(id: parsed.id, message: message);
    } catch (e) {
      logger.e('解析响应失败: $e');
      throw AIChatException('parse_error', '解析服务响应失败');
    }
  }

  _ParsedResponse _parseAIResponse(String responseBody) {
    final Map<String, dynamic> data = jsonDecode(responseBody);
    final String id = data['id'] as String;
    final List<dynamic> choices = data['choices'] as List<dynamic>;
    final Map<String, dynamic> message =
        choices.first['message'] as Map<String, dynamic>;
    final String content = message['content'] as String;
    return _ParsedResponse(id: id, content: content);
  }
}

class _ParsedResponse {
  final String id;
  final String content;
  _ParsedResponse({required this.id, required this.content});
}

class AIReply {
  final String id; // 用作会话UUID（首次回复采纳）
  final ChatMessage message;
  AIReply({required this.id, required this.message});
}
