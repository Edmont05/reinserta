import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyAerBmfGD7pIfkuzTCsb2Q6jLlpaFs3X8U';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> generateContent(String prompt) async {
    final url = Uri.parse('$_endpoint?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
      return text ?? 'Sin respuesta generada.';
    } else {
      throw Exception('Gemini error ${response.statusCode}: ${response.body}');
    }
  }
}
