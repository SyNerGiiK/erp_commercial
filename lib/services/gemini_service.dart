import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Extraire les données d'un ticket de caisse (OCR)
  static Future<Map<String, dynamic>?> extractReceiptData(
      String base64Image) async {
    if (apiKey.isEmpty) {
      developer.log("GEMINI_API_KEY non configurée.");
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Tu es un extracteur de tickets de caisse. Renvoie STRICTEMENT un JSON valide avec les clés 'merchant_name' (String), 'total_amount' (Number), 'tax_amount' (Number) et 'date' (YYYY-MM-DD). N'inclus aucun backtick ou mot supplémentaire."
                },
                {
                  "inlineData": {"mimeType": "image/jpeg", "data": base64Image}
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.1,
            "responseMimeType": "application/json"
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null) {
          return jsonDecode(text);
        }
      } else {
        developer.log(
            "Erreur Gemini API: ${response.statusCode} - ${response.body}");
      }
      return null;
    } catch (e) {
      developer.log("Erreur extractReceiptData", error: e);
      return null;
    }
  }

  /// Générer une structure de devis via RAG (Aitise ton Devis)
  static Future<List<dynamic>?> generateQuoteStructure(
      String userDictation, String catalogJSON) async {
    if (apiKey.isEmpty) {
      developer.log("GEMINI_API_KEY non configurée.");
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Tu es un Économiste de la construction. L'utilisateur dicte des travaux: '$userDictation'.\nCatalogue: $catalogJSON\nTu dois structurer le devis. Règle 1: Organise par sections (cree des lignes 'titre'). Règle 2: Ajoute le matériel ('vente') et la main d'œuvre ('service'). Règle 3: Utilise le catalogue fourni. Règle 4: Si non trouvé, estime le prix au marché et mets 'is_ai_estimated': true. Renvoie STRICTEMENT un tableau JSON avec 'type_ligne' ('titre', 'article'), 'designation', 'type_activite' ('vente', 'service'), 'quantite', 'prix_unitaire', 'is_ai_estimated', 'ordre'."
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.2,
            "responseMimeType": "application/json"
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null) {
          return jsonDecode(text) as List<dynamic>;
        }
      }
      return null;
    } catch (e) {
      developer.log("Erreur generateQuoteStructure", error: e);
      return null;
    }
  }
}
