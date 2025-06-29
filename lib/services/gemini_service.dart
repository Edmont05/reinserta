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

  static String buildPrompt(List<Map<String, dynamic>> empleados) {
    final empleadosJson = jsonEncode(empleados);
    return '''
You are a JSON-only scoring engine for temporary-job matching.

TASK
-----
For each object in the array **empleados**, compute:

score = (0.45 * location_score)
      + (0.35 * experience_score)
      + (0.20 * reputation_score)

location_score: 1   if distancia_km ≤  2
                0.75 if distancia_km ≤  5
                0.50 if distancia_km ≤ 15
                0.25 otherwise

experience_score: linear scale of trabajos_similares from 0→0 to 10→1  
reputation_score: linear scale of calificacion_promedio (1→0 to 5→1)

Round the final score to an **integer 0-100**.

If a numeric field is missing, assume 0.  
Cap trabajos_similares at 10 and calificacion_promedio at 5.

OUTPUT
------
Return **only** valid JSON that follows this schema (no markdown, no text):

{
  "candidatos": [
    { "uid": "<string>", "score": <integer 0-100> },
    ...
  ]
}

Sort candidatos by score descending.

INPUT
-----
empleados =
$empleadosJson
''';
  }
}