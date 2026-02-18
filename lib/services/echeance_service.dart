import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/rappel_model.dart';

/// Service de calcul automatique des échéances fiscales et documentaires
class EcheanceService {
  /// Génère tous les rappels automatiques pour l'année
  static List<Rappel> genererTousRappels({
    required int annee,
    required bool urssafTrimestriel,
    required bool tvaApplicable,
    List<Facture>? factures,
    List<Devis>? devis,
  }) {
    final rappels = <Rappel>[];

    // 1. URSSAF
    rappels.addAll(_genererRappelsUrssaf(annee, urssafTrimestriel));

    // 2. CFE
    rappels.add(_genererRappelCFE(annee));

    // 3. Impôts sur le revenu
    rappels.add(_genererRappelImpots(annee));

    // 4. TVA (si applicable)
    if (tvaApplicable) {
      rappels.addAll(_genererRappelsTVA(annee));
    }

    // 5. Échéances factures
    if (factures != null) {
      rappels.addAll(_genererRappelsFactures(factures));
    }

    // 6. Fin de validité devis
    if (devis != null) {
      rappels.addAll(_genererRappelsDevis(devis));
    }

    return rappels;
  }

  /// Rappels URSSAF (mensuel ou trimestriel)
  static List<Rappel> _genererRappelsUrssaf(int annee, bool trimestriel) {
    final rappels = <Rappel>[];

    if (trimestriel) {
      final trimestres = [
        (label: 'T4 ${annee - 1}', mois: 1, jour: 31),
        (label: 'T1 $annee', mois: 4, jour: 30),
        (label: 'T2 $annee', mois: 7, jour: 31),
        (label: 'T3 $annee', mois: 10, jour: 31),
      ];

      for (final t in trimestres) {
        rappels.add(Rappel(
          titre: 'URSSAF — Déclaration ${t.label}',
          description:
              'Déclarer le CA du trimestre sur autoentrepreneur.urssaf.fr',
          typeRappel: TypeRappel.urssaf,
          dateEcheance: DateTime(annee, t.mois, t.jour),
          priorite: PrioriteRappel.haute,
          estRecurrent: true,
          frequenceRecurrence: 'trimestrielle',
        ));
      }
    } else {
      for (int mois = 1; mois <= 12; mois++) {
        final dernierJour = DateTime(annee, mois + 1, 0).day;
        rappels.add(Rappel(
          titre: 'URSSAF — ${_nomMois(mois)} $annee',
          description:
              'Déclarer le CA de ${_nomMois(mois)} sur autoentrepreneur.urssaf.fr',
          typeRappel: TypeRappel.urssaf,
          dateEcheance:
              DateTime(annee, mois + 1, dernierJour > 28 ? 28 : dernierJour),
          priorite: PrioriteRappel.haute,
          estRecurrent: true,
          frequenceRecurrence: 'mensuelle',
        ));
      }
    }

    return rappels;
  }

  /// Rappel CFE — 15 décembre
  static Rappel _genererRappelCFE(int annee) {
    return Rappel(
      titre: 'CFE $annee — Paiement',
      description:
          'Date limite de paiement de la Cotisation Foncière des Entreprises sur impots.gouv.fr',
      typeRappel: TypeRappel.cfe,
      dateEcheance: DateTime(annee, 12, 15),
      priorite: PrioriteRappel.haute,
      estRecurrent: true,
      frequenceRecurrence: 'annuelle',
    );
  }

  /// Rappel Impôts — début juin
  static Rappel _genererRappelImpots(int annee) {
    return Rappel(
      titre: 'Impôts $annee — Déclaration 2042-C-PRO',
      description:
          'Déclarer les revenus micro-entrepreneur sur impots.gouv.fr (2042-C-PRO)',
      typeRappel: TypeRappel.impots,
      dateEcheance: DateTime(annee, 6, 8),
      priorite: PrioriteRappel.urgente,
      estRecurrent: true,
      frequenceRecurrence: 'annuelle',
    );
  }

  /// Rappels TVA (mensuel ou trimestriel selon régime)
  static List<Rappel> _genererRappelsTVA(int annee) {
    final rappels = <Rappel>[];
    // TVA trimestrielle : CA3 chaque trimestre
    final trimestres = [
      {'label': 'T1', 'mois': 4, 'jour': 24},
      {'label': 'T2', 'mois': 7, 'jour': 24},
      {'label': 'T3', 'mois': 10, 'jour': 24},
      {'label': 'T4', 'mois': 1, 'jour': 24},
    ];

    for (final t in trimestres) {
      final mois = t['mois'] as int;
      final an = mois == 1 ? annee + 1 : annee;
      rappels.add(Rappel(
        titre: 'TVA — Déclaration CA3 ${t['label']} $annee',
        description: 'Déclarer la TVA du trimestre sur impots.gouv.fr',
        typeRappel: TypeRappel.tva,
        dateEcheance: DateTime(an, mois, t['jour'] as int),
        priorite: PrioriteRappel.haute,
        estRecurrent: true,
        frequenceRecurrence: 'trimestrielle',
      ));
    }

    return rappels;
  }

  /// Rappels pour les factures en attente de paiement
  static List<Rappel> _genererRappelsFactures(List<Facture> factures) {
    final rappels = <Rappel>[];

    for (final f in factures) {
      if (f.statut == 'brouillon' || f.estSoldee) continue;
      if (f.typeDocument == 'avoir') continue;

      rappels.add(Rappel(
        titre: 'Échéance — ${f.numeroFacture}',
        description:
            '${f.objet} — Net à payer : ${f.netAPayer.toDouble().toStringAsFixed(2)} €',
        typeRappel: TypeRappel.echeanceFacture,
        dateEcheance: f.dateEcheance,
        priorite: f.dateEcheance.isBefore(DateTime.now())
            ? PrioriteRappel.urgente
            : PrioriteRappel.normale,
        entiteLieeId: f.id,
        entiteLieeType: 'facture',
      ));
    }

    return rappels;
  }

  /// Rappels pour les devis arrivant à expiration
  static List<Rappel> _genererRappelsDevis(List<Devis> devisList) {
    final rappels = <Rappel>[];

    for (final d in devisList) {
      if (d.statut != 'envoye') continue;

      rappels.add(Rappel(
        titre: 'Expiration — ${d.numeroDevis}',
        description:
            '${d.objet} — Devis expire le ${d.dateValidite.day}/${d.dateValidite.month}/${d.dateValidite.year}',
        typeRappel: TypeRappel.finDevis,
        dateEcheance: d.dateValidite,
        priorite: d.dateValidite.difference(DateTime.now()).inDays <= 7
            ? PrioriteRappel.haute
            : PrioriteRappel.normale,
        entiteLieeId: d.id,
        entiteLieeType: 'devis',
      ));
    }

    return rappels;
  }

  static String _nomMois(int mois) {
    const noms = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return noms[mois];
  }
}
