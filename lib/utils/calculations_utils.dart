import 'package:decimal/decimal.dart';

class CalculationsUtils {
  /// Calcule un montant de charge URSSAF
  /// Formule : (Base * Taux / 100)
  static Decimal calculateCharges(Decimal base, Decimal taux) {
    if (base == Decimal.zero || taux == Decimal.zero) return Decimal.zero;
    final baseTimesTaux = base * taux;
    final result = baseTimesTaux / Decimal.fromInt(100);
    return result.toDecimal();
  }

  /// Calcule une marge nette
  /// Formule : Vente - Achat - Charges
  static Decimal calculateMargeNette(
      Decimal vente, Decimal achat, Decimal charges) {
    return vente - achat - charges;
  }

  /// Calcule un total de ligne
  /// Formule : Quantité * Prix Unitaire
  static Decimal calculateTotalLigne(Decimal qte, Decimal pu) {
    return qte * pu;
  }

  /// Calcule un montant d'acompte selon un taux
  static Decimal calculateAcompteFromTaux(
      Decimal totalTTC, double tauxPercent) {
    final t = Decimal.parse(tauxPercent.toString());
    final val = (totalTTC * t) / Decimal.fromInt(100);
    return val.toDecimal();
  }

  /// Calcule un taux d'acompte selon un montant
  static double calculateTauxFromMontant(
      Decimal totalTTC, Decimal montantAcompte) {
    if (totalTTC == Decimal.zero) return 0.0;
    final ratio = (montantAcompte / totalTTC).toDouble();
    return ratio * 100;
  }
}
