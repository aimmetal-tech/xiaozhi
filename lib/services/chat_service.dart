import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:xiaozhi/model/chat_model.dart';
import 'package:xiaozhi/services/credential_service.dart';

Map<String, Uri> apiUriList = {
  'Kimi': Uri.parse('https://api.moonshot.cn/v1/chat/completions'),
};

Map<String, String> buildHeaders(String apiKey) => {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $apiKey',
};

// TODO: Service of Sending Message to AI
Future<Map<String, dynamic>> chatService(ChatRequestModel requestBody) async {
  try {
    final apiKey = ApiKeyStore.sync ?? '';
    if (apiKey.isEmpty) {
      return {
        'success': false,
        'error': 'Missing API key',
        'message': '请在设置中填写 API Key',
      };
    }
    final response = await http.post(
      apiUriList['Kimi']!,
      headers: buildHeaders(apiKey),
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      log({'success': true, 'data': responseData}.toString());
      return {'success': true, 'data': responseData};
    } else {
      return {
        'success': false,
        'error': 'HTTP Error: ${response.statusCode}',
        'message': response.body,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Exception occurred',
      'message': e.toString(),
    };
  }
}
