import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiAnalysisResult {
  final String prioridad;
  final String justificacion;

  GeminiAnalysisResult({required this.prioridad, required this.justificacion});
}

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY no configurada en el archivo .env');
    }
    
    // Usamos gemini-flash-latest para estar siempre en la versión más rápida y actualizada
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
    );
  }

  Future<GeminiAnalysisResult> analyzeReportPriority(String description, String imagePath) async {
    try {
      final imageBytes = kIsWeb 
        ? null
        : await File(imagePath).readAsBytes();

      if (imageBytes == null && !kIsWeb) {
         return GeminiAnalysisResult(prioridad: 'Media', justificacion: 'No se pudo leer la imagen.');
      }

      final prompt = TextPart('''
Eres un experto evaluando reportes ciudadanos de problemas urbanos (baches, luminarias, basura, etc).
Te voy a dar una imagen y una descripción.
Necesito que evalúes la gravedad real del problema y le asignes una prioridad estricta y objetiva: "Baja", "Media" o "Alta".
Los ciudadanos suelen exagerar, así que básate más en la evidencia visual de la imagen.

Descripción del ciudadano: "$description"

Responde ÚNICAMENTE con un JSON válido usando el siguiente formato exacto:
{
  "prioridad": "Baja|Media|Alta",
  "justificacion": "Breve explicación de 1 o 2 oraciones del por qué de tu decisión basada en la imagen."
}
''');

      final parts = <Part>[prompt];
      if (imageBytes != null) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }

      final response = await _model.generateContent([
        Content.multi(parts)
      ]);

      final text = response.text ?? '{}';
      
      // Limpiar texto en caso de que Gemini devuelva markdown como ```json ... ```
      String cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanText);

      String prioridadFinal = jsonResponse['prioridad'] ?? 'Media';
      if (prioridadFinal != 'Baja' && prioridadFinal != 'Media' && prioridadFinal != 'Alta') {
        prioridadFinal = 'Media';
      }

      return GeminiAnalysisResult(
        prioridad: prioridadFinal,
        justificacion: jsonResponse['justificacion'] ?? 'Sin justificación de IA.',
      );

    } catch (e) {
      print('Error en GeminiService: $e');
      return GeminiAnalysisResult(
        prioridad: 'Media',
        justificacion: 'Fallo al analizar con IA: $e',
      );
    }
  }
}
