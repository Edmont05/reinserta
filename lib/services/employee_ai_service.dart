import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reinserta/services/firebase_services.dart';

final Gemini gemini = Gemini.instance;

Future<void> getUltimoHistorialEmpleado(String empleadoId) async {
  final historialSnapshot = await FirebaseFirestore.instance
      .collection('Historial')
      .where('empleado', isEqualTo: empleadoId)
      .limit(100)
      .get();

  if (historialSnapshot.docs.isEmpty) {
    return;
  }
  
  final historialText = historialSnapshot.docs.map((doc) {
    final data = doc.data();
    return '''
      Calificación: ${data['calificacion']}
      Comentario: ${data['comentario']}
      Descripción: ${data['descripcion']}
      Monto: ${data['monto']}
      Profesión: ${data['profesion']}
      Fecha: ${data['salida']?.toDate()}
      ''';
        }).join('\n');

  final prompt = '''
    Eres un sistema experto de recursos humanos encargado de evaluar empleados.
    Analiza el siguiente historial de desempeño del empleado y responde SOLO con un JSON con dos campos: 
    "puntaje" (de 0 a 5, puede usar decimales) y "rango" (un número: 1 para plata, 2 para oro, 3 para platino).
    El análisis debe considerar calificaciones, comentarios y monto de los trabajos.

    Historial del empleado:
    $historialText
    ''';

  final geminiResponse = await gemini.text(prompt);

  try {
    final result = geminiResponse?.output ?? '';
    if (result.isNotEmpty) {
      // Limpia los posibles bloques de código Markdown
      final cleaned = result
          .replaceAll(RegExp(r'```json', caseSensitive: false), '')
          .replaceAll('```', '')
          .trim();

      // Busca el JSON incluso si tiene saltos de línea
      final jsonRegExp = RegExp(r'\{[\s\S]*\}', multiLine: true);
      final match = jsonRegExp.firstMatch(cleaned);

      if (match != null) {
        final jsonString = match.group(0)!;
        final decoded = jsonDecode(jsonString);
        final double puntaje = decoded['puntaje']?.toDouble() ?? 0.0;
        final int rango = decoded['rango'] is int
            ? decoded['rango']
            : int.tryParse(decoded['rango'].toString()) ?? 1;

        // Usa tu método centralizado para actualizar los datos
        await actualizarCalificacionYRangoUsuario(empleadoId, puntaje, rango);

      }
    }
  } catch (e) {
    print('Error al analizar y actualizar rango del empleado: $e');
  }
}