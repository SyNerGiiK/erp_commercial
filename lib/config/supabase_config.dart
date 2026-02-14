import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // CONFIGURATION
  static const String url = 'https://phfkebkwlhqizgizqlhu.supabase.co';
  static const String anonKey =
      'sb_publishable_Fl4GIlRfNNoSOIgHwj9Dag_OXoI4s-W';

  /// Initialise Supabase avec la configuration optimale pour le Web (PKCE)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        // CRITIQUE POUR LE WEB : PKCE
        authFlowType: AuthFlowType.pkce,
      ),
      debug: kDebugMode,
    );
  }

  /// Accesseur global au client Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// Récupère l'ID de l'utilisateur courant ou lève une exception
  static String get userId {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AuthException(
          'Erreur critique : Tentative d\'accès aux données sans utilisateur connecté.',
          statusCode: '401');
    }
    return user.id;
  }
}
