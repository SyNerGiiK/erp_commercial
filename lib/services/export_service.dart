import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart'; // Assure-toi d'avoir flutter pub add file_saver

import '../models/facture_model.dart';
import '../models/depense_model.dart';

class ExportService {
  /// Génère un export comptable (CSV) et lance le téléchargement
  /// Compatible : Web (Téléchargement direct) & Desktop/Mobile
  static Future<void> exportComptabilite(
    List<Facture> factures,
    List<Depense> depenses,
  ) async {
    try {
      // 1. GÉNÉRATION DES DONNÉES

      // A. LIVRE DES RECETTES
      List<List<dynamic>> rowsRecettes = [];
      rowsRecettes.add(["DATE", "REFERENCE", "CLIENT (ID)", "MODE", "MONTANT"]);

      for (var f in factures) {
        for (var p in f.paiements) {
          rowsRecettes.add([
            DateFormat('dd/MM/yyyy').format(p.datePaiement),
            "F-${f.numeroFacture}",
            f.clientId,
            p.typePaiement.toUpperCase(),
            p.montant
                .toDouble()
                .toStringAsFixed(2)
                .replaceAll('.', ','), // Format Excel FR
          ]);
        }
      }

      // B. REGISTRE DES ACHATS
      List<List<dynamic>> rowsAchats = [];
      rowsAchats.add(["DATE", "FOURNISSEUR", "CATEGORIE", "MONTANT"]);

      for (var d in depenses) {
        rowsAchats.add([
          DateFormat('dd/MM/yyyy').format(d.date),
          d.fournisseur ?? "",
          d.categorie.toUpperCase(),
          d.montant.toDouble().toStringAsFixed(2).replaceAll('.', ','),
        ]);
      }

      // C. CONVERSION CSV
      const converter = ListToCsvConverter(fieldDelimiter: ';');
      String csvRecettes = converter.convert(rowsRecettes);
      String csvAchats = converter.convert(rowsAchats);

      // Encode en UTF-8 avec BOM pour Excel
      final bytesRecettes =
          Uint8List.fromList(utf8.encode('\uFEFF$csvRecettes'));
      final bytesAchats = Uint8List.fromList(utf8.encode('\uFEFF$csvAchats'));

      final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

      // 2. SAUVEGARDE (Via FileSaver - Compatible Web/Desktop/Mobile)

      await FileSaver.instance.saveFile(
        name: 'recettes_$nowStr',
        bytes: bytesRecettes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      // Petite pause pour éviter que le navigateur ne bloque le second téléchargement (Popup blocker)
      await Future.delayed(const Duration(milliseconds: 500));

      await FileSaver.instance.saveFile(
        name: 'achats_$nowStr',
        bytes: bytesAchats,
        ext: 'csv',
        mimeType: MimeType.csv,
      );
    } catch (e) {
      debugPrint("🔴 Erreur Export CSV: $e");
      rethrow;
    }
  }
}
