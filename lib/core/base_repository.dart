import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Classe de base pour tous les Repositories
/// Fournit la gestion standardisée des erreurs et helpers CRUD
abstract class BaseRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Accès au client Supabase
  SupabaseClient get client => _client;

  /// Récupère l'ID utilisateur courant
  String get userId => SupabaseConfig.userId;

  /// Gestion standardisée des erreurs
  ///
  /// [error] : L'erreur à logger
  /// [method] : Nom de la méthode où l'erreur s'est produite
  /// [customMessage] : Message personnalisé (optionnel)
  Exception handleError(Object error, String method, [String? customMessage]) {
    final repoName = runtimeType.toString();
    developer.log(
      "🔴 $repoName Error ($method)",
      error: error,
    );

    final message = customMessage ?? "Erreur ($method): $error";
    return Exception(message);
  }

  /// Prépare les données pour insertion
  /// - Ajoute user_id
  /// - Retire id (généré par Supabase)
  /// - Retire les listes imbriquées
  Map<String, dynamic> prepareForInsert(
    Map<String, dynamic> data, {
    List<String> nestedFields = const [],
  }) {
    final prepared = Map<String, dynamic>.from(data);
    prepared['user_id'] = userId;
    prepared.remove('id');

    for (final field in nestedFields) {
      prepared.remove(field);
    }

    return prepared;
  }

  /// Prépare les données pour update
  /// - Retire user_id (RLS policy)
  /// - Retire id (ne doit jamais être modifié)
  /// - Retire les listes imbriquées
  Map<String, dynamic> prepareForUpdate(
    Map<String, dynamic> data, {
    List<String> nestedFields = const [],
    List<String> protectedFields = const [],
  }) {
    final prepared = Map<String, dynamic>.from(data);
    prepared.remove('user_id');
    prepared.remove('id');

    for (final field in nestedFields) {
      prepared.remove(field);
    }

    for (final field in protectedFields) {
      prepared.remove(field);
    }

    return prepared;
  }
}
