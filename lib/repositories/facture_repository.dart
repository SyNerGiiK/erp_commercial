import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/facture_model.dart';
import '../models/paiement_model.dart';
import '../config/supabase_config.dart';

abstract class IFactureRepository {
  Future<List<Facture>> getFactures({bool archives = false});
  Future<Facture> createFacture(Facture facture);
  Future<void> updateFacture(Facture facture);
  Future<void> deleteFacture(String id);
  Future<void> updateStatus(String id, String status);
  Future<void> updateArchiveStatus(String id, bool isArchived);
  Future<String> generateNextNumero(int annee);

  // GESTION DES PAIEMENTS
  Future<void> addPaiement(Paiement paiement);
  Future<void> deletePaiement(String id);
}

class FactureRepository implements IFactureRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<Facture>> getFactures({bool archives = false}) async {
    try {
      final userId = SupabaseConfig.userId;

      final response = await _client
          .from('factures')
          .select('*, lignes_factures(*), paiements(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .eq('est_archive', archives)
          .order('created_at', ascending: false)
          .order('ordre', referencedTable: 'lignes_factures', ascending: true);

      return (response as List).map((e) => Facture.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getFactures');
    }
  }

  @override
  Future<Facture> createFacture(Facture facture) async {
    try {
      final userId = SupabaseConfig.userId;
      final data = facture.toMap();
      data['user_id'] = userId;
      data.remove('id'); // L'ID est généré par Supabase

      // 🔍 DEBUG: Log des données envoyées
      print('🟦 DEBUG createFacture - Données envoyées:');
      print(data);

      // 1. Insertion Facture
      final response =
          await _client.from('factures').insert(data).select().single();

      final newFactureId = response['id'];

      // 2. Insertion Lignes & Chiffrage & Paiements
      await _saveChildren(newFactureId, facture, userId, savePaiements: true);

      return Facture.fromMap(response);
    } catch (e) {
      print('🔴 DEBUG createFacture - Erreur complète: $e');
      throw _handleError(e, 'createFacture');
    }
  }

  @override
  Future<void> updateFacture(Facture facture) async {
    if (facture.id == null) return;
    try {
      final data = facture.toMap();
      data.remove('user_id'); // RLS : On ne touche jamais au user_id
      data.remove(
          'numero_facture'); // Sécurité : On ne modifie pas le numéro d'une facture existante

      // 1. Update Facture
      await _client.from('factures').update(data).eq('id', facture.id!);

      // 2. Full Replace des lignes (Suppression puis Réinsertion)
      // Note: On ne supprime PAS les paiements ici pour ne pas perdre l'historique
      await _client
          .from('lignes_factures')
          .delete()
          .eq('facture_id', facture.id!);
      await _client
          .from('lignes_chiffrages')
          .delete()
          .eq('facture_id', facture.id!);

      await _saveChildren(facture.id!, facture, SupabaseConfig.userId,
          savePaiements: false);
    } catch (e) {
      throw _handleError(e, 'updateFacture');
    }
  }

  @override
  Future<void> deleteFacture(String id) async {
    try {
      // Supabase cascade delete gère normalement les enfants,
      // mais on peut le forcer si la FK n'est pas en cascade.
      await _client.from('factures').delete().eq('id', id);
    } catch (e) {
      throw _handleError(e, 'deleteFacture');
    }
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    try {
      await _client.from('factures').update({'statut': status}).eq('id', id);
    } catch (e) {
      throw _handleError(e, 'updateStatus');
    }
  }

  @override
  Future<void> updateArchiveStatus(String id, bool isArchived) async {
    try {
      await _client
          .from('factures')
          .update({'est_archive': isArchived}).eq('id', id);
    } catch (e) {
      throw _handleError(e, 'updateArchiveStatus');
    }
  }

  /// Appelle la fonction stockée PostgreSQL pour garantir l'unicité et la séquence
  @override
  Future<String> generateNextNumero(int annee) async {
    try {
      final userId = SupabaseConfig.userId;
      final params = {
        'p_type_doc': 'facture',
        'p_user_id': userId,
        'p_annee': annee
      };
      // C'EST ICI QUE SUPABASE TRAVAILLE :
      return await _client.rpc('get_next_document_number', params: params);
    } catch (e) {
      throw _handleError(e, 'generateNextNumero');
    }
  }

  // --- PAIEMENTS ---

  @override
  Future<void> addPaiement(Paiement paiement) async {
    try {
      // Pas de RLS "user_id" direct sur la table paiement selon schéma standard,
      // mais on vérifie l'accès via la facture parente si nécessaire.
      // Ici on suppose que la table paiements est liée.
      final data = paiement.toMap();
      data.remove('id');
      await _client.from('paiements').insert(data);

      // Optionnel : Mettre à jour le statut de la facture si tout est payé
      // (Logique souvent gérée par le ViewModel ou un Trigger DB)
    } catch (e) {
      throw _handleError(e, 'addPaiement');
    }
  }

  @override
  Future<void> deletePaiement(String id) async {
    try {
      await _client.from('paiements').delete().eq('id', id);
    } catch (e) {
      throw _handleError(e, 'deletePaiement');
    }
  }

  // --- PRIVATE HELPERS ---

  Future<void> _saveChildren(String factureId, Facture facture, String userId,
      {bool savePaiements = true}) async {
    // Lignes Facture
    if (facture.lignes.isNotEmpty) {
      final lignesData = facture.lignes.asMap().entries.map((entry) {
        final map = entry.value.toMap();
        map['facture_id'] = factureId;
        map['ordre'] = entry.key; // Préservation de l'ordre
        map.remove('id');
        return map;
      }).toList();
      await _client.from('lignes_factures').insert(lignesData);
    }

    // Lignes Chiffrage (Rentabilité)
    if (facture.chiffrage.isNotEmpty) {
      final chiffrageData = facture.chiffrage.map((c) {
        final map = c.toMap();
        map['facture_id'] = factureId;
        map['user_id'] = userId;
        map.remove('id');
        return map;
      }).toList();
      await _client.from('lignes_chiffrages').insert(chiffrageData);
    }

    // Paiements (Seulement à la création pour les acomptes initiaux)
    if (savePaiements && facture.paiements.isNotEmpty) {
      final paiementsData = facture.paiements.map((p) {
        final map = p.toMap();
        map['facture_id'] = factureId;
        map.remove('id');
        return map;
      }).toList();
      await _client.from('paiements').insert(paiementsData);
    }
  }

  Exception _handleError(dynamic error, String context) {
    developer.log("🔴 Erreur Repo Facture ($context)", error: error);
    return Exception("Erreur ($context): $error");
  }
}
