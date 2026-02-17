import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import '../models/facture_model.dart';
import '../models/client_model.dart';

/// Modèle représentant une alerte de relance
class RelanceInfo {
  final Facture facture;
  final Client? client;
  final int joursRetard;
  final Decimal resteAPayer;
  final NiveauRelance niveau;

  RelanceInfo({
    required this.facture,
    this.client,
    required this.joursRetard,
    required this.resteAPayer,
    required this.niveau,
  });

  String get message {
    final formatter = DateFormat('dd/MM/yyyy');
    final echeance = formatter.format(facture.dateEcheance);
    final clientName = client?.nomComplet ?? 'Client inconnu';
    return "Facture ${facture.numeroFacture} - $clientName - "
        "Échéance: $echeance - Retard: $joursRetard jours - "
        "Reste: ${resteAPayer.toDouble().toStringAsFixed(2)}€";
  }
}

enum NiveauRelance {
  amiable, // 1-14 jours
  ferme, // 15-30 jours
  miseEnDemeure, // 31-60 jours
  contentieux, // 60+ jours
}

/// Service de gestion des relances de factures impayées
class RelanceService {
  /// Analyse les factures et retourne les relances à effectuer
  static List<RelanceInfo> analyserRelances(
    List<Facture> factures, {
    List<Client>? clients,
  }) {
    final now = DateTime.now();
    final relances = <RelanceInfo>[];

    for (var f in factures) {
      // Filtrer : uniquement les factures validées/envoyées non archivées
      if (f.statut == 'brouillon' ||
          f.statut == 'payee' ||
          f.statut == 'annulee' ||
          f.estArchive) {
        continue;
      }

      // Calculer le reste à payer
      final totalRegle =
          f.paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);
      final remiseAmount =
          ((f.totalHt * f.remiseTaux) / Decimal.fromInt(100)).toDecimal();
      final netCommercial = f.totalHt - remiseAmount;
      final reste = netCommercial - f.acompteDejaRegle - totalRegle;

      // Ignorer si soldée
      if (reste <= Decimal.parse('0.01')) continue;

      // Vérifier si en retard
      if (f.dateEcheance.isBefore(now)) {
        final joursRetard = now.difference(f.dateEcheance).inDays;

        Client? client;
        if (clients != null) {
          client = clients
              .cast<Client?>()
              .firstWhere((c) => c?.id == f.clientId, orElse: () => null);
        }

        relances.add(RelanceInfo(
          facture: f,
          client: client,
          joursRetard: joursRetard,
          resteAPayer: reste,
          niveau: _determinerNiveau(joursRetard),
        ));
      }
    }

    // Trier par jours de retard décroissant
    relances.sort((a, b) => b.joursRetard.compareTo(a.joursRetard));
    return relances;
  }

  /// Statistiques des relances
  static Map<String, dynamic> getStatistiquesRelances(
      List<RelanceInfo> relances) {
    if (relances.isEmpty) {
      return {
        'total': 0,
        'montantTotal': Decimal.zero,
        'retardMoyen': 0.0,
        'parNiveau': <NiveauRelance, int>{},
      };
    }

    Decimal montantTotal = Decimal.zero;
    int totalJours = 0;
    final parNiveau = <NiveauRelance, int>{};

    for (var r in relances) {
      montantTotal += r.resteAPayer;
      totalJours += r.joursRetard;
      parNiveau[r.niveau] = (parNiveau[r.niveau] ?? 0) + 1;
    }

    return {
      'total': relances.length,
      'montantTotal': montantTotal,
      'retardMoyen': totalJours / relances.length,
      'parNiveau': parNiveau,
    };
  }

  /// Génère le texte d'une relance
  static String genererTexteRelance(RelanceInfo relance) {
    final formatter = DateFormat('dd/MM/yyyy');
    final clientName = relance.client?.nomComplet ?? 'Madame, Monsieur';
    final montant = relance.resteAPayer.toDouble().toStringAsFixed(2);
    final echeance = formatter.format(relance.facture.dateEcheance);
    final aujourdhui = formatter.format(DateTime.now());

    switch (relance.niveau) {
      case NiveauRelance.amiable:
        return "Objet : Rappel de facture ${relance.facture.numeroFacture}\n\n"
            "$clientName,\n\n"
            "Nous nous permettons de vous rappeler que la facture "
            "${relance.facture.numeroFacture} d'un montant de $montant€, "
            "arrivée à échéance le $echeance, reste impayée à ce jour.\n\n"
            "Nous vous remercions de bien vouloir procéder au règlement "
            "dans les plus brefs délais.\n\n"
            "Cordialement";

      case NiveauRelance.ferme:
        return "Objet : Relance - Facture ${relance.facture.numeroFacture} impayée\n\n"
            "$clientName,\n\n"
            "Malgré notre précédent rappel, nous constatons que la facture "
            "${relance.facture.numeroFacture} d'un montant de $montant€, "
            "échue depuis le $echeance, reste impayée.\n\n"
            "Nous vous prions de régulariser cette situation sous 8 jours.\n\n"
            "Cordialement";

      case NiveauRelance.miseEnDemeure:
        return "Objet : MISE EN DEMEURE - Facture ${relance.facture.numeroFacture}\n\n"
            "$clientName,\n\n"
            "Par la présente, nous vous mettons en demeure de régler "
            "la facture ${relance.facture.numeroFacture} d'un montant de $montant€, "
            "échue depuis le $echeance.\n\n"
            "À défaut de règlement sous 15 jours à compter du $aujourdhui, "
            "nous nous réservons le droit d'engager toute procédure de recouvrement.\n\n"
            "Cordialement";

      case NiveauRelance.contentieux:
        return "Objet : DERNIER AVIS AVANT CONTENTIEUX - Facture ${relance.facture.numeroFacture}\n\n"
            "$clientName,\n\n"
            "Malgré nos multiples relances, la facture "
            "${relance.facture.numeroFacture} d'un montant de $montant€ "
            "reste impayée depuis le $echeance.\n\n"
            "Sans régularisation sous 8 jours, nous transmettrons le dossier "
            "à notre service contentieux.\n\n"
            "Cordialement";
    }
  }

  static NiveauRelance _determinerNiveau(int joursRetard) {
    if (joursRetard <= 14) return NiveauRelance.amiable;
    if (joursRetard <= 30) return NiveauRelance.ferme;
    if (joursRetard <= 60) return NiveauRelance.miseEnDemeure;
    return NiveauRelance.contentieux;
  }
}
