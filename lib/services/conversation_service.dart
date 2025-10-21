import 'dart:convert';

import 'package:http/http.dart' as http;

Map<String, dynamic> apiUrlList = {
  'Kimi': 'https://api.moonshot.cn/v1/chat/completions',
};

String apiKey = 'xxx';

Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $apiKey',
};

// TODO: Service of Sending Message to AI
Future<Map<String, dynamic>> conversationService(
  Map<String, dynamic> requestBody,
) async {
  try {
    final response = await http.post(
      apiUrlList['Kimi'],
      headers: headers,
      body: requestBody,
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
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
