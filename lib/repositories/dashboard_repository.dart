import 'dart:developer' as developer;
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/depense_model.dart';
import '../models/urssaf_model.dart';
import '../models/entreprise_model.dart';
import '../core/base_repository.dart';

abstract class IDashboardRepository {
  Future<List<Facture>> getFacturesPeriod(DateTime start, DateTime end);
  Future<List<Facture>> getAllFacturesYear(int year);
  Future<List<Depense>> getDepensesPeriod(DateTime start, DateTime end);
  Future<UrssafConfig> getUrssafConfig();
  Future<ProfilEntreprise?> getProfilEntreprise();
  Future<List<dynamic>> getRecentActivity();
}

class DashboardRepository extends BaseRepository
    implements IDashboardRepository {
  @override
  Future<List<Facture>> getFacturesPeriod(DateTime start, DateTime end) async {
    try {
      final response = await client
          .from('factures')
          .select('*, paiements(*)')
          .eq('user_id', userId)
          .neq('statut', 'brouillon');

      return (response as List).map((e) => Facture.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getFacturesPeriod');
    }
  }

  @override
  Future<List<Facture>> getAllFacturesYear(int year) async {
    return getFacturesPeriod(DateTime(year, 1, 1), DateTime(year, 12, 31));
  }

  @override
  Future<List<Depense>> getDepensesPeriod(DateTime start, DateTime end) async {
    try {
      final response = await client
          .from('depenses')
          .select()
          .eq('user_id', userId)
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String());

      return (response as List).map((e) => Depense.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getDepensesPeriod');
    }
  }

  @override
  Future<UrssafConfig> getUrssafConfig() async {
    try {
      final response = await client
          .from('urssaf_configs')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response != null
          ? UrssafConfig.fromMap(response)
          : UrssafConfig(userId: 'dashboard_mock');
    } catch (e) {
      developer.log("⚠️ DashboardRepo: Pas de config Urssaf", error: e);
      return UrssafConfig(userId: 'dashboard_mock');
    }
  }

  @override
  Future<ProfilEntreprise?> getProfilEntreprise() async {
    try {
      final response = await client
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
      var facturesData = await client
          .from('factures')
          .select('*, paiements(*)')
          .eq('user_id', userId)
          .order('date_emission', ascending: false)
          .limit(5);

      var devisData = await client
          .from('devis')
          .select()
          .eq('user_id', userId)
          .order('date_emission', ascending: false)
          .limit(5);

      final factures =
          (facturesData as List).map((e) => Facture.fromMap(e)).toList();
      final devis = (devisData as List).map((e) => Devis.fromMap(e)).toList();

      final all = <dynamic>[...factures, ...devis];
      all.sort((a, b) {
        DateTime dateA =
            a is Facture ? a.dateEmission : (a as Devis).dateEmission;
        DateTime dateB =
            b is Facture ? b.dateEmission : (b as Devis).dateEmission;
        return dateB.compareTo(dateA);
      });

      return all.take(5).toList();
    } catch (e) {
      developer.log("⚠️ Erreur Recent Activity", error: e);
      return [];
    }
  }
}
