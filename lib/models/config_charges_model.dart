import 'package:decimal/decimal.dart';

/// Configuration des taux de charges sociales
/// Permet de personnaliser les taux pour le calcul de rentabilité
class ConfigCharges {
  final Decimal tauxUrssaf; // Taux URSSAF en %
  final Decimal tauxRetraite; // Taux cotisations retraite en %
  final Decimal tauxCfpCsg; // Taux CFP + CSG-CRDS en %

  ConfigCharges({
    Decimal? tauxUrssaf,
    Decimal? tauxRetraite,
    Decimal? tauxCfpCsg,
  })  : tauxUrssaf = tauxUrssaf ?? Decimal.parse('22'),
        tauxRetraite = tauxRetraite ?? Decimal.parse('10'),
        tauxCfpCsg = tauxCfpCsg ?? Decimal.parse('8');

  /// Taux total de charges (somme des 3 taux)
  Decimal get tauxTotal => tauxUrssaf + tauxRetraite + tauxCfpCsg;

  /// Calcule le montant total des charges sur un chiffre d'affaires
  Decimal calculerCharges(Decimal chiffreAffaires) {
    // Division returns Rational -> must convert to Decimal
    final chargesRational =
        (chiffreAffaires * tauxTotal) / Decimal.fromInt(100);
    return chargesRational.toDecimal();
  }

  /// Calcule le détail des charges par type
  Map<String, Decimal> calculerDetailCharges(Decimal chiffreAffaires) {
    final urssafRational =
        (chiffreAffaires * tauxUrssaf) / Decimal.fromInt(100);
    final retraiteRational =
        (chiffreAffaires * tauxRetraite) / Decimal.fromInt(100);
    final cfpCsgRational =
        (chiffreAffaires * tauxCfpCsg) / Decimal.fromInt(100);

    return {
      'urssaf': urssafRational.toDecimal(),
      'retraite': retraiteRational.toDecimal(),
      'cfpCsg': cfpCsgRational.toDecimal(),
    };
  }

  // Sérialisation pour stockage local (SharedPreferences)
  factory ConfigCharges.fromMap(Map<String, dynamic> map) {
    return ConfigCharges(
      tauxUrssaf: Decimal.parse((map['taux_urssaf'] ?? 22).toString()),
      tauxRetraite: Decimal.parse((map['taux_retraite'] ?? 10).toString()),
      tauxCfpCsg: Decimal.parse((map['taux_cfp_csg'] ?? 8).toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taux_urssaf': tauxUrssaf.toString(),
      'taux_retraite': tauxRetraite.toString(),
      'taux_cfp_csg': tauxCfpCsg.toString(),
    };
  }

  ConfigCharges copyWith({
    Decimal? tauxUrssaf,
    Decimal? tauxRetraite,
    Decimal? tauxCfpCsg,
  }) {
    return ConfigCharges(
      tauxUrssaf: tauxUrssaf ?? this.tauxUrssaf,
      tauxRetraite: tauxRetraite ?? this.tauxRetraite,
      tauxCfpCsg: tauxCfpCsg ?? this.tauxCfpCsg,
    );
  }
}
