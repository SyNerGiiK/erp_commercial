import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../config/supabase_config.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/depense_model.dart';
import '../models/urssaf_model.dart';
import '../models/entreprise_model.dart';

abstract class IDashboardRepository {
  Future<List<Facture>> getFacturesPeriod(DateTime start, DateTime end);
  Future<List<Facture>> getAllFacturesYear(int year);
  Future<List<Depense>> getDepensesPeriod(DateTime start, DateTime end);
  Future<UrssafConfig> getUrssafConfig();
  Future<ProfilEntreprise?> getProfilEntreprise();
  Future<List<dynamic>> getRecentActivity();
}

class DashboardRepository implements IDashboardRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<Facture>> getFacturesPeriod(DateTime start, DateTime end) async {
    try {
      final userId = SupabaseConfig.userId;
      // On prend tout sauf brouillons pour les stats
      final response = await _client
          .from('factures')
          .select('*, paiements(*)')
          .eq('user_id', userId)
          .neq('statut', 'brouillon');

      return (response as List).map((e) => Facture.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getFacturesPeriod');
    }
  }

  @override
  Future<List<Facture>> getAllFacturesYear(int year) async {
    return getFacturesPeriod(DateTime(year, 1, 1), DateTime(year, 12, 31));
  }

  @override
  Future<List<Depense>> getDepensesPeriod(DateTime start, DateTime end) async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('depenses')
          .select()
          .eq('user_id', userId)
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String());

      return (response as List).map((e) => Depense.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getDepensesPeriod');
    }
  }

  @override
  Future<UrssafConfig> getUrssafConfig() async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('urssaf_configs')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response != null
          ? UrssafConfig.fromMap(response)
          : UrssafConfig(userId: 'dashboard_mock'); // Fallback si pas de config
    } catch (e) {
      developer.log("⚠️ DashboardRepo: Pas de config Urssaf", error: e);
      return UrssafConfig(userId: 'dashboard_mock');
    }
  }

  @override
  Future<ProfilEntreprise?> getProfilEntreprise() async {
    try {
      final userId = SupabaseConfig.userId;
      final response = await _client
          .from('entreprises')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response != null ? ProfilEntreprise.fromMap(response) : null;
    } catch (e) {
      developer.log("⚠️ Pas de profil entreprise trouvé.", error: e);
      return null;
    }
  }

  @override
  Future<List<dynamic>> getRecentActivity() async {
    try {
      final userId = SupabaseConfig.userId;

      // Fetch last 5 factures
      var facturesData = await _client
          .from('factures')
          .select('*, paiements(*)')
          .eq('user_id', userId)
          .order('date_emission', ascending: false)
          .limit(5);

      // Fetch last 5 devis
      var devisData = await _client
          .from('devis')
          .select()
          .eq('user_id', userId)
          .order('date_emission', ascending: false)
          .limit(5);

      final factures =
          (facturesData as List).map((e) => Facture.fromMap(e)).toList();
      final devis = (devisData as List).map((e) => Devis.fromMap(e)).toList();

      // Merge and sort
      final all = <dynamic>[...factures, ...devis];
      all.sort((a, b) {
        DateTime dateA =
            a is Facture ? a.dateEmission : (a as Devis).dateEmission;
        DateTime dateB =
            b is Facture ? b.dateEmission : (b as Devis).dateEmission;
        return dateB.compareTo(dateA); // Descending
      });

      return all.take(5).toList();
    } catch (e) {
      developer.log("⚠️ Erreur Recent Activity", error: e);
      return [];
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 DashboardRepo Error ($method)", error: error);
    return Exception("Erreur ($method): $error");
  }
}
