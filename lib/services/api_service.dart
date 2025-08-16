import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class ApiService {
  final EnvConfig _envConfig = EnvConfig();
  
  /// OpenAI API 호출 예시
  Future<Map<String, dynamic>> callOpenAI({
    required String prompt,
    String model = 'gpt-3.5-turbo',
  }) async {
    if (!_envConfig.isInitialized) {
      throw Exception('환경 변수가 초기화되지 않았습니다.');
    }
    
    final apiKey = _envConfig.openaiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('OpenAI API 키가 설정되지 않았습니다.');
    }
    
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 1000,
    });
    
    try {
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API 호출 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API 호출 중 오류 발생: $e');
    }
  }
  
  /// Anthropic API 호출 예시
  Future<Map<String, dynamic>> callAnthropic({
    required String prompt,
    String model = 'claude-3-sonnet-20240229',
  }) async {
    if (!_envConfig.isInitialized) {
      throw Exception('환경 변수가 초기화되지 않았습니다.');
    }
    
    final apiKey = _envConfig.anthropicApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Anthropic API 키가 설정되지 않았습니다.');
    }
    
    final url = Uri.parse('https://api.anthropic.com/v1/messages');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    };
    
    final body = jsonEncode({
      'model': model,
      'max_tokens': 1000,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
    });
    
    try {
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API 호출 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API 호출 중 오류 발생: $e');
    }
  }
  
  /// Google API 호출 예시
  Future<Map<String, dynamic>> callGoogleAPI({
    required String endpoint,
    Map<String, dynamic>? params,
  }) async {
    if (!_envConfig.isInitialized) {
      throw Exception('환경 변수가 초기화되지 않았습니다.');
    }
    
    final apiKey = _envConfig.googleApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Google API 키가 설정되지 않았습니다.');
    }
    
    final baseUrl = _envConfig.apiBaseUrl;
    final url = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: {
        'key': apiKey,
        ...?params,
      },
    );
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API 호출 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API 호출 중 오류 발생: $e');
    }
  }
}
