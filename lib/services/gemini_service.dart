import 'dart:developer' as developer;
import '../config/supabase_config.dart';

/// Service IA Gemini — tous les appels transitent par l'Edge Function
/// `gemini-proxy` (Supabase) côté serveur. La clé API n'est jamais
/// exposée dans le bundle Flutter.
class GeminiService {
  static const _functionName = 'gemini-proxy';

  // ──────────────────────────────────────────────
  //  Appel Edge Function mutualisé
  // ──────────────────────────────────────────────
  static Future<T?> _invoke<T>(
    String action,
    Map<String, dynamic> payload,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        _functionName,
        body: {'action': action, 'payload': payload},
      );

      if (response.status == 200) {
        final body = response.data as Map<String, dynamic>?;
        if (body != null && body['success'] == true) {
          return parser(body['data']);
        }
        developer.log("[$_functionName/$action] Réponse sans succès : $body");
      } else {
        developer.log("[$_functionName/$action] HTTP ${response.status}");
      }
      return null;
    } catch (e) {
      developer.log("[$_functionName/$action] Erreur", error: e);
      return null;
    }
  }

  // ──────────────────────────────────────────────
  //  OCR — Extraire les données d'un ticket de caisse
  // ──────────────────────────────────────────────
  static Future<Map<String, dynamic>?> extractReceiptData(
      String base64Image) async {
    return _invoke<Map<String, dynamic>>(
      'extractReceipt',
      {'base64Image': base64Image},
      (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  // ──────────────────────────────────────────────
  //  RAG — Générer une structure de devis par dictée
  // ──────────────────────────────────────────────
  static Future<List<dynamic>?> generateQuoteStructure(
      String userDictation, String catalogJSON) async {
    return _invoke<List<dynamic>>(
      'generateQuoteStructure',
      {'userDictation': userDictation, 'catalogJSON': catalogJSON},
      (data) => data as List<dynamic>,
    );
  }
}
