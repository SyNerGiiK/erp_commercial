import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_repository.dart';

/// Classe abstraite pour les repositories de documents (Devis, Factures)
/// Fournit les fonctionnalités communes : signature, numérotation
abstract class DocumentRepository extends BaseRepository {
  /// Nom de la table du document
  String get tableName;

  /// Nom du préfixe pour le compteur (ex: 'DEV', 'FAC')
  String get numeroPrefix;

  /// Type de document pour le compteur (ex: 'devis', 'facture')
  String get documentType;

  /// Upload une signature pour un document
  ///
  /// [documentId] : ID du document
  /// [bytes] : Données de l'image de signature
  ///
  /// Retourne l'URL publique de la signature
  Future<String> uploadSignature(String documentId, Uint8List bytes) async {
    try {
      final path = '$userId/$tableName/$documentId/signature.png';

      await client.storage.from('documents').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );

      return client.storage.from('documents').getPublicUrl(path);
    } catch (e) {
      throw handleError(e, 'uploadSignature');
    }
  }

  /// Génère le prochain numéro de document pour l'année
  /// Format: PREFIX-YYYY-NNNN (ex: DEV-2026-0042)
  ///
  /// [annee] : Année pour le numéro
  ///
  /// Retourne le numéro généré
  Future<String> generateNextNumero(int annee) async {
    try {
      // 1. Tente de récupérer le compteur existant
      final existing = await client
          .from('compteurs_documents')
          .select('valeur_actuelle')
          .eq('user_id', userId)
          .eq('annee', annee)
          .eq('type_document', documentType)
          .maybeSingle();

      int nextValue;

      if (existing == null) {
        // 2. Créer un nouveau compteur
        nextValue = 1;
        await client.from('compteurs_documents').insert({
          'user_id': userId,
          'annee': annee,
          'type_document': documentType,
          'valeur_actuelle': nextValue,
        });
      } else {
        // 3. Incrémenter le compteur existant
        nextValue = (existing['valeur_actuelle'] as int) + 1;
        await client
            .from('compteurs_documents')
            .update({'valeur_actuelle': nextValue})
            .eq('user_id', userId)
            .eq('annee', annee)
            .eq('type_document', documentType);
      }

      // 4. Formater le numéro
      return '$numeroPrefix-$annee-${nextValue.toString().padLeft(4, '0')}';
    } catch (e) {
      throw handleError(
        e,
        'generateNextNumero',
        'Erreur lors de la génération du numéro',
      );
    }
  }

  /// Supprime toutes les lignes enfants d'un document
  ///
  /// [documentId] : ID du document parent
  /// [childTables] : Liste des tables enfants à nettoyer
  /// [foreignKeyName] : Nom de la clé étrangère (ex: 'devis_id', 'facture_id')
  Future<void> deleteChildLines(
    String documentId,
    List<String> childTables,
    String foreignKeyName,
  ) async {
    try {
      for (final table in childTables) {
        await client.from(table).delete().eq(foreignKeyName, documentId);
      }
    } catch (e) {
      throw handleError(e, 'deleteChildLines');
    }
  }
}
