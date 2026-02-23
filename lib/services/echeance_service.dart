import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/rappel_model.dart';
import '../models/enums/entreprise_enums.dart';

/// Service de calcul automatique des échéances fiscales et documentaires
class EcheanceService {
  /// Génère tous les rappels automatiques pour l'année
  static List<Rappel> genererTousRappels({
    required int annee,
    required TypeEntreprise typeEntreprise,
    required bool urssafTrimestriel,
    required bool tvaApplicable,
    List<Facture>? factures,
    List<Devis>? devis,
  }) {
    final rappels = <Rappel>[];

    // 1. URSSAF
    rappels
        .addAll(genererRappelsUrssaf(annee, typeEntreprise, urssafTrimestriel));

    // 2. CFE
    rappels.add(genererRappelCFE(annee));

    // 3. Impôts sur le revenu/IS
    rappels.add(genererRappelImpots(annee, typeEntreprise));

    // 4. TVA (si applicable)
    if (tvaApplicable) {
      rappels.addAll(genererRappelsTVA(annee));
    }

    // 5. Échéances factures
    if (factures != null) {
      rappels.addAll(genererRappelsFactures(factures));
    }

    // 6. Fin de validité devis
    if (devis != null) {
      rappels.addAll(genererRappelsDevis(devis));
    }

    return rappels;
  }

  /// Rappels URSSAF (mensuel ou trimestriel)
  static List<Rappel> genererRappelsUrssaf(
      int annee, TypeEntreprise typeEntreprise, bool trimestriel) {
    final rappels = <Rappel>[];
    final isMicro = typeEntreprise == TypeEntreprise.microEntrepreneur;
    final urlDecl = isMicro ? 'autoentrepreneur.urssaf.fr' : 'urssaf.fr';
    final titrePrefix = isMicro ? 'URSSAF Micro' : 'URSSAF Indépendant';

    if (trimestriel) {
      // Pour les TNS hors micro, l'échéancier peut être différent, mais on simplifie ici
      // avec les dates standards trimestrielles URSSAF.
      final dates = [
        DateTime(annee, 2, 1), // T4 année précédente → 31 janv
        DateTime(annee, 5, 1), // T1 → 30 avril
        DateTime(annee, 8, 1), // T2 → 31 juillet
        DateTime(annee, 11, 1), // T3 → 31 octobre
      ];
      final labels = [
        'T4 ${annee - 1}',
        'T1 $annee',
        'T2 $annee',
        'T3 $annee',
      ];

      for (int i = 0; i < dates.length; i++) {
        final echeance = dates[i].subtract(const Duration(days: 1));
        rappels.add(Rappel(
          titre: '$titrePrefix — Déclaration ${labels[i]}',
          description:
              'Déclarer sur $urlDecl avant le ${echeance.day}/${echeance.month}/$annee',
          typeRappel: TypeRappel.urssaf,
          dateEcheance: echeance,
          priorite: PrioriteRappel.haute,
          estRecurrent: true,
          frequenceRecurrence: 'trimestrielle',
        ));
      }
    } else {
      // Mensuel : M+1
      for (int mois = 1; mois <= 12; mois++) {
        final dernierJour = DateTime(annee, mois + 1, 0).day;
        final limiteAjustee = isMicro
            ? (dernierJour > 28 ? 28 : dernierJour)
            : 5; // TNS paient souvent le 5 ou 20
        final echeance = DateTime(annee, mois + 1, limiteAjustee);
        rappels.add(Rappel(
          titre: '$titrePrefix — ${_nomMois(mois)} $annee',
          description: 'Déclarer/Payer pour ${_nomMois(mois)} sur $urlDecl',
          typeRappel: TypeRappel.urssaf,
          dateEcheance: echeance,
          priorite: PrioriteRappel.haute,
          estRecurrent: true,
          frequenceRecurrence: 'mensuelle',
        ));
      }
    }

    return rappels;
  }

  /// Rappel CFE — 15 décembre
  static Rappel genererRappelCFE(int annee) {
    return Rappel(
      titre: 'CFE $annee — Paiement',
      description:
          'Date limite de paiement CFE (Cotisation Foncière des Entreprises) sur impots.gouv.fr',
      typeRappel: TypeRappel.cfe,
      dateEcheance: DateTime(annee, 12, 15),
      priorite: PrioriteRappel.haute,
      estRecurrent: true,
      frequenceRecurrence: 'annuelle',
    );
  }

  /// Rappel Impôts — variable selon type entreprise
  static Rappel genererRappelImpots(int annee, TypeEntreprise typeEntreprise) {
    final isIS = typeEntreprise == TypeEntreprise.sas ||
        typeEntreprise == TypeEntreprise.sasu;
    final isMicro = typeEntreprise == TypeEntreprise.microEntrepreneur;

    if (isIS) {
      return Rappel(
        titre: 'Solde IS $annee (Impôt Sociétés)',
        description:
            'Paiement du solde de l\'Impôt sur les Sociétés sur impots.gouv.fr',
        typeRappel: TypeRappel.impots,
        dateEcheance: DateTime(annee, 5, 15),
        priorite: PrioriteRappel.urgente,
        estRecurrent: true,
        frequenceRecurrence: 'annuelle',
      );
    } else {
      return Rappel(
        titre: 'Impôts IR $annee — Déclaration',
        description: isMicro
            ? 'Déclarer les revenus micro-entrepreneur (2042-C-PRO) sur impots.gouv.fr'
            : 'Déclaration de revenus professionnels sur impots.gouv.fr',
        typeRappel: TypeRappel.impots,
        dateEcheance: DateTime(annee, 6, 8),
        priorite: PrioriteRappel.urgente,
        estRecurrent: true,
        frequenceRecurrence: 'annuelle',
      );
    }
  }

  /// Rappels TVA (trimestrielle)
  static List<Rappel> genererRappelsTVA(int annee) {
    final rappels = <Rappel>[];
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
  static List<Rappel> genererRappelsFactures(List<Facture> factures) {
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
  static List<Rappel> genererRappelsDevis(List<Devis> devisList) {
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
