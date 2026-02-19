import 'package:decimal/decimal.dart';
import '../models/chiffrage_model.dart';

class CalculationsUtils {
  /// Calcule un montant de charge URSSAF
  /// Formule : (Base * Taux / 100)
  static Decimal calculateCharges(Decimal base, Decimal taux) {
    if (base == Decimal.zero || taux == Decimal.zero) return Decimal.zero;
    final baseTimesTaux = base * taux;
    return (baseTimesTaux / Decimal.fromInt(100)).toDecimal();
  }

  /// Calcule une marge nette
  /// Formule : Vente - Achat - Charges
  static Decimal calculateMargeNette(
      Decimal vente, Decimal achat, Decimal charges) {
    return vente - achat - charges;
  }

  /// Calcule un total de ligne
  /// Formule : Quantité * Prix Unitaire * (Avancement / 100 si situation)
  static Decimal calculateTotalLigne(Decimal qte, Decimal pu,
      {bool isSituation = false, Decimal? avancement}) {
    if (isSituation) {
      final av = avancement ?? Decimal.fromInt(100);
      return ((qte * pu * av) / Decimal.fromInt(100)).toDecimal();
    }
    return qte * pu;
  }

  /// Calcule un montant d'acompte selon un taux (Decimal)
  static Decimal calculateAcompteFromTaux(
      Decimal totalTTC, Decimal tauxPercent) {
    if (totalTTC == Decimal.zero || tauxPercent == Decimal.zero) {
      return Decimal.zero;
    }
    return ((totalTTC * tauxPercent) / Decimal.fromInt(100)).toDecimal();
  }

  /// Calcule un taux d'acompte selon un montant (Retourne Decimal)
  static Decimal calculateTauxFromMontant(
      Decimal totalTTC, Decimal montantAcompte) {
    if (totalTTC == Decimal.zero) return Decimal.zero;
    final ratio = (montantAcompte / totalTTC).toDecimal();
    return ratio * Decimal.fromInt(100);
  }

  /// Calcule le net commercial (HT - remise)
  static Decimal calculateNetCommercial(Decimal totalHt, Decimal remiseTaux) {
    if (remiseTaux == Decimal.zero) return totalHt;
    final remiseMontant =
        ((totalHt * remiseTaux) / Decimal.fromInt(100)).toDecimal();
    return totalHt - remiseMontant;
  }

  /// Calcule le reste à payer d'une facture
  static Decimal calculateResteAPayer({
    required Decimal totalHt,
    required Decimal remiseTaux,
    required Decimal acompteDejaRegle,
    required Decimal totalPaiements,
    Decimal? totalTva,
  }) {
    final net = calculateNetCommercial(totalHt, remiseTaux);
    final ttc = net + (totalTva ?? Decimal.zero);
    return ttc - acompteDejaRegle - totalPaiements;
  }

  /// Calcule le taux de marge en pourcentage
  static Decimal calculateTauxMarge(Decimal vente, Decimal achat) {
    if (vente == Decimal.zero) return Decimal.zero;
    final marge = vente - achat;
    return ((marge * Decimal.fromInt(100)) / vente).toDecimal();
  }

  /// Calcule la TVA totale à partir d'une liste de montants et taux
  static Decimal calculateTotalTva(List<Map<String, Decimal>> lignes) {
    Decimal total = Decimal.zero;
    for (var ligne in lignes) {
      final montant = ligne['montant'] ?? Decimal.zero;
      final taux = ligne['taux'] ?? Decimal.fromInt(20);
      total += calculateCharges(montant, taux);
    }
    return total;
  }

  /// Arrondi un Decimal à N décimales
  static Decimal roundDecimal(Decimal value, int decimals) {
    final factor = Decimal.parse('1${'0' * decimals}');
    return ((value * factor).round() / factor).toDecimal();
  }

  // ========== PROGRESS BILLING — AVANCEMENT INTELLIGENT ==========

  /// Calcule l'avancement d'une ligne de devis à partir de ses coûts enfants.
  ///
  /// Formule : (Valeur Réalisée / Prix Total LigneDevis) × 100
  ///
  /// La "Valeur Réalisée" est la somme des valeurs réalisées de chaque LigneChiffrage
  /// liée à cette ligne de devis :
  /// - Matériel : `est_achete ? prixVenteInterne : 0`
  /// - Main d'œuvre : `prixVenteInterne × (avancementMo / 100)`
  ///
  /// Retourne un pourcentage 0–100 arrondi à 1 décimale.
  /// Si aucun chiffrage, retourne Decimal.zero.
  static Decimal calculateLigneDevisAvancement({
    required List<LigneChiffrage> chiffrageEnfants,
    required Decimal prixTotalLigneDevis,
  }) {
    if (chiffrageEnfants.isEmpty || prixTotalLigneDevis <= Decimal.zero) {
      return Decimal.zero;
    }

    Decimal valeurRealisee = Decimal.zero;
    for (final c in chiffrageEnfants) {
      valeurRealisee += c.valeurRealisee;
    }

    if (valeurRealisee <= Decimal.zero) return Decimal.zero;

    // Avancement = (valeurRealisée / prixTotal) × 100
    final avancement =
        ((valeurRealisee * Decimal.fromInt(100)) / prixTotalLigneDevis)
            .toDecimal(scaleOnInfinitePrecision: 10);

    // Cap à 100% maximum
    if (avancement > Decimal.fromInt(100)) return Decimal.fromInt(100);

    return roundDecimal(avancement, 1);
  }

  /// Calcule l'avancement global d'un devis (toutes lignes confondues) en mode Global.
  ///
  /// Formule : Σ(valeurRealisée de chaque chiffrage) / Σ(prixVenteInterne total) × 100
  ///
  /// Cette approche pondérée évite les biais quand les lignes ont des poids différents.
  static Decimal calculateDevisAvancementGlobal({
    required List<LigneChiffrage> tousChiffrages,
  }) {
    if (tousChiffrages.isEmpty) return Decimal.zero;

    Decimal totalPrixVenteInterne = Decimal.zero;
    Decimal totalValeurRealisee = Decimal.zero;

    for (final c in tousChiffrages) {
      totalPrixVenteInterne += c.prixVenteInterne;
      totalValeurRealisee += c.valeurRealisee;
    }

    if (totalPrixVenteInterne <= Decimal.zero) return Decimal.zero;

    final avancement =
        ((totalValeurRealisee * Decimal.fromInt(100)) / totalPrixVenteInterne)
            .toDecimal(scaleOnInfinitePrecision: 10);

    if (avancement > Decimal.fromInt(100)) return Decimal.fromInt(100);

    return roundDecimal(avancement, 1);
  }

  /// Pour une liste de lignes de devis, calcule l'avancement de chacune
  /// à partir du chiffrage groupé par `linkedLigneDevisId`.
  ///
  /// Retourne une Map<String, Decimal> : ligneDevisId → avancement (0–100)
  static Map<String, Decimal> calculateAllLignesAvancement({
    required List<dynamic> lignesDevis,
    required List<LigneChiffrage> tousChiffrages,
  }) {
    final result = <String, Decimal>{};

    // Grouper les chiffrages par ligneDevisId
    final grouped = <String, List<LigneChiffrage>>{};
    for (final c in tousChiffrages) {
      if (c.linkedLigneDevisId != null) {
        grouped.putIfAbsent(c.linkedLigneDevisId!, () => []).add(c);
      }
    }

    for (final ligne in lignesDevis) {
      final ligneId = ligne.id as String?;
      if (ligneId == null) continue;

      // Ignorer les lignes non-chiffrables
      final type = ligne.type as String;
      if (['titre', 'sous-titre', 'texte', 'saut_page'].contains(type)) {
        continue;
      }

      final enfants = grouped[ligneId] ?? [];
      final prixTotal =
          (ligne.quantite as Decimal) * (ligne.prixUnitaire as Decimal);

      result[ligneId] = calculateLigneDevisAvancement(
        chiffrageEnfants: enfants,
        prixTotalLigneDevis: prixTotal,
      );
    }

    return result;
  }

  /// Calcule le total brut des travaux à date pour une facture de situation.
  /// Pour chaque ligne : prixUnitaire × quantité × (avancement / 100)
  static Decimal calculateTotalBrutTravauxADate(List<dynamic> lignesFacture) {
    Decimal total = Decimal.zero;
    for (final l in lignesFacture) {
      final type = l.type as String;
      if (['titre', 'sous-titre', 'texte', 'saut_page'].contains(type)) {
        continue;
      }
      total += l.totalLigne as Decimal;
    }
    return total;
  }

  /// Génère les lignes de déduction à partir des factures précédentes
  /// liées au même devis source.
  ///
  /// Retourne une liste de maps {description, montant} prêtes pour le PDF.
  static List<Map<String, dynamic>> generateDeductionLines({
    required List<dynamic> facturesPrecedentes,
  }) {
    final deductions = <Map<String, dynamic>>[];

    for (final f in facturesPrecedentes) {
      final type = f.type as String;
      final numero = f.numeroFacture as String;
      final totalTtc = f.totalTtc as Decimal;

      String label;
      if (type == 'acompte') {
        label = "Déduction Facture d'Acompte $numero";
      } else if (type == 'situation') {
        label = "Déduction Situation précédente $numero";
      } else {
        label = "Déduction $numero";
      }

      deductions.add({
        'description': label,
        'montant': totalTtc,
      });
    }

    return deductions;
  }

  // ========== VENTILATION URSSAF BIC/BNC ==========

  /// Résultat de ventilation URSSAF par catégorie de CA
  /// Sépare le CA d'un devis en bases Vente (BIC), Prestation BIC et Prestation BNC
  /// selon le typeActivite de chaque ligne.
  ///
  /// Convention typeActivite :
  ///   'vente' → BIC Vente (achat/revente, taux micro 12.3%)
  ///   'prestation_bic' ou 'service_bic' → BIC Prestation (artisan, taux 21.2%)
  ///   'service' ou 'prestation_bnc' → BNC Prestation (libéral, taux 24.6%)
  ///
  /// Pour l'activité mixte artisan : 'vente' pour la fourniture, 'service' (BIC par défaut)
  /// Pour le mapping réel, on utilise isBncDefault pour piloter le comportement
  /// par défaut quand typeActivite == 'service'.
  static VentilationUrssaf ventilerCA({
    required List<dynamic> lignes,
    required Decimal remiseTaux,
    bool isBncDefault = false,
  }) {
    Decimal caVente = Decimal.zero;
    Decimal caPrestaBIC = Decimal.zero;
    Decimal caPrestaBNC = Decimal.zero;

    for (final ligne in lignes) {
      // Ignorer les lignes non-chiffrables (titres, sous-titres, textes, saut_page)
      final type = ligne.type as String;
      if (['titre', 'sous-titre', 'texte', 'saut_page'].contains(type)) {
        continue;
      }

      final montant = ligne.totalLigne as Decimal;
      final typeActivite = (ligne.typeActivite as String?) ?? 'service';

      switch (typeActivite) {
        case 'vente':
        case 'achat_revente':
          caVente += montant;
          break;
        case 'prestation_bic':
        case 'service_bic':
          caPrestaBIC += montant;
          break;
        case 'prestation_bnc':
        case 'service_bnc':
          caPrestaBNC += montant;
          break;
        case 'service':
        default:
          // Par défaut, 'service' est classé en BIC (artisan) sauf si isBncDefault
          if (isBncDefault) {
            caPrestaBNC += montant;
          } else {
            caPrestaBIC += montant;
          }
          break;
      }
    }

    // Appliquer la remise proportionnellement
    final totalBrut = caVente + caPrestaBIC + caPrestaBNC;
    if (totalBrut > Decimal.zero && remiseTaux > Decimal.zero) {
      final coefRemise =
          Decimal.one - (remiseTaux / Decimal.fromInt(100)).toDecimal();

      caVente = caVente * coefRemise;
      caPrestaBIC = caPrestaBIC * coefRemise;
      caPrestaBNC = caPrestaBNC * coefRemise;
    }

    return VentilationUrssaf(
      caVente: caVente,
      caPrestaBIC: caPrestaBIC,
      caPrestaBNC: caPrestaBNC,
    );
  }
}

/// Résultat de la ventilation d'un CA de devis par catégorie URSSAF.
class VentilationUrssaf {
  final Decimal caVente;
  final Decimal caPrestaBIC;
  final Decimal caPrestaBNC;

  const VentilationUrssaf({
    required this.caVente,
    required this.caPrestaBIC,
    required this.caPrestaBNC,
  });

  Decimal get total => caVente + caPrestaBIC + caPrestaBNC;

  /// Indique si la ventilation est mixte (plusieurs catégories)
  bool get isMixte =>
      [
        caVente > Decimal.zero,
        caPrestaBIC > Decimal.zero,
        caPrestaBNC > Decimal.zero
      ].where((b) => b).length >
      1;
}
