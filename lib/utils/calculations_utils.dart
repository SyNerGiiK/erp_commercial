import 'package:decimal/decimal.dart';

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
}
