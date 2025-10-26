import 'dart:convert';
import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:xiaozhi/models/chat_model.dart';
import 'package:xiaozhi/services/logger_service.dart';

String serverUrl = dotenv.env['SERVER_URL'] ?? 'http://localhost';
String port = '8080';

Map<String, Uri> apiUriList = {
  'Kimi': Uri.parse('$serverUrl:$port/chat/completions'),
};

Future<Map<String, dynamic>> chatService(ChatRequestModel requestBody) async {
  try {
    final response = await http.post(
      apiUriList['Kimi']!,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      logger.i({'success': true, 'data': responseData}.toString());
      return {'success': true, 'data': responseData};
    } else {
      return {
        'success': false,
        'error': 'HTTP Error: ${response.statusCode}',
        'message': response.body,
      };
    }
  } catch (e) {
    logger.e(e.toString());
    return {
      'success': false,
      'error': 'Exception occurred',
      'message': e.toString(),
    };
  }
}

Stream<ChatSSEModel> chatServiceStream(ChatRequestModel requestBody) async* {
  final client = http.Client();
  try {
    final request = http.Request('POST', apiUriList['Kimi']!);
    final body = requestBody.toJson()..['stream'] = true;
    
    try {
      final List<dynamic> msgs = (body['messages'] as List<dynamic>);
      final filtered = msgs.where((m) {
        final role = (m as Map)['role'];
        final content = (m)['content'];
        return role == 'user' &&
            (content is String) &&
            content.trim().isNotEmpty;
      }).toList();
      body['messages'] = filtered;
    } catch (_) {}
    logger.i('SSE request body: ${jsonEncode(body)}');

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });
    request.body = jsonEncode(body);

    final response = await client.send(request);
    if (response.statusCode != 200) {
      final errText = await response.stream.bytesToString();
      logger.e('SSE HTTP ${response.statusCode}: $errText');
      yield ChatSSEModel(
        id: '',
        delta: '',
        error: 'HTTP ${response.statusCode}: $errText',
      );
      return;
    }

    // 解码
    final decoder = response.stream.transform(utf8.decoder);
    final buffer = StringBuffer();

    await for (final chunk in decoder) {
      buffer.write(chunk);

      final pieces = buffer.toString().split('\n\n');
      buffer.clear();

      if (pieces.isNotEmpty) {
        buffer.write(pieces.removeLast());

        for (final event in pieces) {
          for (final line in event.split('\n')) {
            final trimmed = line.trim();
            if (trimmed.isEmpty || trimmed.startsWith(':')) continue;
            if (!trimmed.startsWith('data:')) continue;

            try {
              final model = ChatSSEModel.fromEventLine(trimmed);
              yield model;
              if (model.done) return;
            } catch (e) {
              logger.e('SSE parse error: $e; line: $trimmed');
              yield ChatSSEModel(id: '', delta: '', error: 'parse_error: $e');
            }
          }
        }
      }
    }
  } catch (e) {
    logger.e('SSE stream exception: $e');
    yield ChatSSEModel(id: '', delta: '', error: e.toString());
  } finally {
    client.close();
  }
}
