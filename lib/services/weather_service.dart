import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class WeatherService {
  // Optionnel : la clé API peut être définie dans le .env (ex: OWM_API_KEY)
  static String get apiKey => dotenv.env['OWM_API_KEY'] ?? '';

  /// Récupère la météo actuelle pour une ville donnée via OpenWeatherMap
  static Future<Map<String, dynamic>?> getCurrentWeather(
      {String city = 'Paris'}) async {
    if (apiKey.isEmpty) {
      developer.log("OWM_API_KEY non configurée pour la météo.");
      return null;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=fr'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        developer.log("Erreur OpenWeatherMap: ${response.statusCode}");
      }
    } catch (e) {
      developer.log("Erreur getCurrentWeather", error: e);
    }
    return null;
  }
}
