import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../config/supabase_config.dart';
import '../models/facture_model.dart';
import '../models/depense_model.dart';
import '../models/urssaf_model.dart';

abstract class IDashboardRepository {
  Future<List<Facture>> getFacturesPeriod(DateTime start, DateTime end);
  Future<List<Facture>> getAllFacturesYear(int year);
  Future<List<Depense>> getDepensesPeriod(DateTime start, DateTime end);
  Future<UrssafConfig> getUrssafConfig();
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

      return response != null ? UrssafConfig.fromMap(response) : UrssafConfig();
    } catch (e) {
      developer.log("⚠️ Pas de config URSSAF trouvée, utilisation défaut.");
      return UrssafConfig();
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 DashboardRepo Error ($method)", error: error);
    return Exception("Erreur ($method): $error");
  }
}
