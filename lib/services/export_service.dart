import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:file_saver/file_saver.dart';

import '../models/facture_model.dart';
import '../models/depense_model.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';

class ExportService {
  /// Génère un export comptable (CSV) et lance le téléchargement
  static Future<void> exportComptabilite(
    List<Facture> factures,
    List<Depense> depenses,
  ) async {
    try {
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
            _formatDecimalCSV(p.montant),
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
          _formatDecimalCSV(d.montant),
        ]);
      }

      await _saveCSV(rowsRecettes, 'recettes');
      await Future.delayed(const Duration(milliseconds: 500));
      await _saveCSV(rowsAchats, 'achats');
    } catch (e) {
      debugPrint("🔴 Erreur Export CSV: $e");
      rethrow;
    }
  }

  /// Export liste des factures avec détails
  static Future<void> exportFactures(List<Facture> factures,
      {bool isTvaApplicable = true}) async {
    try {
      List<List<dynamic>> rows = [];
      rows.add([
        "N° FACTURE",
        "DATE EMISSION",
        "DATE ECHEANCE",
        "OBJET",
        "CLIENT ID",
        "TYPE",
        "STATUT",
        isTvaApplicable ? "TOTAL HT" : "TOTAL",
        if (isTvaApplicable) "TOTAL TVA",
        isTvaApplicable ? "TOTAL TTC" : "TOTAL NET",
        "REMISE %",
        "ACOMPTE",
        "TOTAL REGLE",
        "RESTE A PAYER",
      ]);

      for (var f in factures) {
        final totalRegle =
            f.paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);
        rows.add([
          f.numeroFacture,
          DateFormat('dd/MM/yyyy').format(f.dateEmission),
          DateFormat('dd/MM/yyyy').format(f.dateEcheance),
          f.objet,
          f.clientId,
          f.type,
          f.statut,
          _formatDecimalCSV(f.totalHt),
          if (isTvaApplicable) _formatDecimalCSV(f.totalTva),
          _formatDecimalCSV(f.totalTtc),
          _formatDecimalCSV(f.remiseTaux),
          _formatDecimalCSV(f.acompteDejaRegle),
          _formatDecimalCSV(totalRegle),
          _formatDecimalCSV(f.netAPayer),
        ]);
      }

      await _saveCSV(rows, 'factures');
    } catch (e) {
      debugPrint("🔴 Erreur Export Factures: $e");
      rethrow;
    }
  }

  /// Export liste des devis avec détails
  static Future<void> exportDevis(List<Devis> devisList,
      {bool isTvaApplicable = true}) async {
    try {
      List<List<dynamic>> rows = [];
      rows.add([
        "N° DEVIS",
        "DATE EMISSION",
        "DATE VALIDITE",
        "OBJET",
        "CLIENT ID",
        "STATUT",
        isTvaApplicable ? "TOTAL HT" : "TOTAL",
        if (isTvaApplicable) "TOTAL TVA",
        isTvaApplicable ? "TOTAL TTC" : "TOTAL NET",
        "REMISE %",
        "ACOMPTE",
        "TRANSFORME",
      ]);

      for (var d in devisList) {
        rows.add([
          d.numeroDevis,
          DateFormat('dd/MM/yyyy').format(d.dateEmission),
          DateFormat('dd/MM/yyyy').format(d.dateValidite),
          d.objet,
          d.clientId,
          d.statut,
          _formatDecimalCSV(d.totalHt),
          if (isTvaApplicable) _formatDecimalCSV(d.totalTva),
          _formatDecimalCSV(d.totalTtc),
          _formatDecimalCSV(d.remiseTaux),
          _formatDecimalCSV(d.acompteMontant),
          d.estTransforme ? "OUI" : "NON",
        ]);
      }

      await _saveCSV(rows, 'devis');
    } catch (e) {
      debugPrint("🔴 Erreur Export Devis: $e");
      rethrow;
    }
  }

  /// Export liste des clients
  static Future<void> exportClients(List<Client> clients) async {
    try {
      List<List<dynamic>> rows = [];
      rows.add([
        "NOM",
        "EMAIL",
        "TELEPHONE",
        "ADRESSE",
        "VILLE",
        "CODE POSTAL",
        "TYPE",
      ]);

      for (var c in clients) {
        rows.add([
          c.nomComplet,
          c.email,
          c.telephone,
          c.adresse,
          c.ville,
          c.codePostal,
          c.typeClient,
        ]);
      }

      await _saveCSV(rows, 'clients');
    } catch (e) {
      debugPrint("🔴 Erreur Export Clients: $e");
      rethrow;
    }
  }

  /// Export dépenses seules
  static Future<void> exportDepenses(List<Depense> depenses) async {
    try {
      List<List<dynamic>> rows = [];
      rows.add([
        "DATE",
        "TITRE",
        "CATEGORIE",
        "FOURNISSEUR",
        "MONTANT",
      ]);

      for (var d in depenses) {
        rows.add([
          DateFormat('dd/MM/yyyy').format(d.date),
          d.titre,
          d.categorie,
          d.fournisseur ?? "",
          _formatDecimalCSV(d.montant),
        ]);
      }

      await _saveCSV(rows, 'depenses');
    } catch (e) {
      debugPrint("🔴 Erreur Export Depenses: $e");
      rethrow;
    }
  }

  // --- HELPERS ---

  static String _formatDecimalCSV(Decimal value) {
    return value.toDouble().toStringAsFixed(2).replaceAll('.', ',');
  }

  static Future<void> _saveCSV(List<List<dynamic>> rows, String name) async {
    const converter = ListToCsvConverter(fieldDelimiter: ';');
    String csv = converter.convert(rows);
    final bytes = Uint8List.fromList(utf8.encode('\uFEFF$csv'));
    final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

    await FileSaver.instance.saveFile(
      name: '${name}_$nowStr',
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }
}
