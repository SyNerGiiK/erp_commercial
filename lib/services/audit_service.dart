import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Service de log d'audit pour les actions utilisateur côté client.
///
/// Les triggers SQL couvrent déjà les INSERT/UPDATE/DELETE sur factures/devis/paiements.
/// Ce service couvre les actions métier supplémentaires : envoi d'email, relance, etc.
class AuditService {
  static SupabaseClient get _client => SupabaseConfig.client;
  static String get _userId => SupabaseConfig.userId;

  /// Log un envoi d'email (facture ou devis)
  static Future<void> logEnvoiEmail({
    required String tableName,
    required String recordId,
    required String destinataire,
    String? numeroDocument,
  }) async {
    await _insertLog(
      tableName: tableName,
      recordId: recordId,
      action: 'EMAIL_SENT',
      metadata: {
        'destinataire': destinataire,
        if (numeroDocument != null) 'numero_document': numeroDocument,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log un envoi de relance
  static Future<void> logRelance({
    required String factureId,
    required String niveauRelance,
    required String destinataire,
    String? numeroFacture,
    int? joursRetard,
    double? montantImpaye,
  }) async {
    await _insertLog(
      tableName: 'factures',
      recordId: factureId,
      action: 'RELANCE_SENT',
      metadata: {
        'niveau_relance': niveauRelance,
        'destinataire': destinataire,
        if (numeroFacture != null) 'numero_facture': numeroFacture,
        if (joursRetard != null) 'jours_retard': joursRetard,
        if (montantImpaye != null) 'montant_impaye': montantImpaye,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Insertion générique dans audit_logs
  static Future<void> _insertLog({
    required String tableName,
    required String recordId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _client.from('audit_logs').insert({
        'user_id': _userId,
        'table_name': tableName,
        'record_id': recordId,
        'action': action,
        'metadata': metadata ?? {},
      });
    } catch (e) {
      // Ne pas bloquer l'utilisateur si le log échoue
      developer.log("⚠️ AuditService: Échec log ($action)", error: e);
    }
  }
}
