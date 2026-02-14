import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_model.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../config/supabase_config.dart';

class GlobalSearchResults {
  final List<Client> clients;
  final List<Facture> factures;
  final List<Devis> devis;

  GlobalSearchResults({
    this.clients = const [],
    this.factures = const [],
    this.devis = const [],
  });
}

abstract class IGlobalSearchRepository {
  Future<GlobalSearchResults> searchAll(String query);
}

class GlobalSearchRepository implements IGlobalSearchRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<GlobalSearchResults> searchAll(String query) async {
    try {
      final userId = SupabaseConfig.userId;
      final sanitizedQuery = "%${query.trim()}%";

      // Requêtes optimisées "or" avec "ilike" (Case Insensitive)
      // Note: Supabase requiert une syntaxe spécifique pour le OR sur plusieurs colonnes

      final clientFuture = _client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .or('nom_complet.ilike.$sanitizedQuery,ville.ilike.$sanitizedQuery,email.ilike.$sanitizedQuery')
          .limit(5);

      final factureFuture = _client
          .from('factures')
          .select('*, lignes_factures(*), paiements(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .or('numero_facture.ilike.$sanitizedQuery,objet.ilike.$sanitizedQuery')
          .limit(5);

      final devisFuture = _client
          .from('devis')
          .select('*, lignes_devis(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .or('numero_devis.ilike.$sanitizedQuery,objet.ilike.$sanitizedQuery')
          .limit(5);

      final results =
          await Future.wait([clientFuture, factureFuture, devisFuture]);

      return GlobalSearchResults(
        clients: (results[0] as List).map((e) => Client.fromMap(e)).toList(),
        factures: (results[1] as List).map((e) => Facture.fromMap(e)).toList(),
        devis: (results[2] as List).map((e) => Devis.fromMap(e)).toList(),
      );
    } catch (e) {
      // En cas d'erreur de syntaxe de recherche, on retourne vide
      return GlobalSearchResults();
    }
  }
}
