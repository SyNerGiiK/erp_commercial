import '../models/facture_model.dart';

/// Service métier qui identifie les factures éligibles à l'archivage automatique.
///
/// Règle : une facture est archivable si :
///  - elle est soldée (netAPayer ≤ 0)
///  - elle n'est pas déjà archivée
///  - son dernier paiement date de plus de [seuilMois] mois (défaut : 12)
class ArchivageService {
  /// Durée en mois après le dernier paiement avant proposition d'archivage.
  static const int seuilMoisDefaut = 12;

  /// Retourne les factures archivables parmi [factures].
  ///
  /// [maintenant] permet l'injection pour les tests.
  static List<Facture> detecterArchivables(
    List<Facture> factures, {
    DateTime? maintenant,
    int seuilMois = seuilMoisDefaut,
  }) {
    final now = maintenant ?? DateTime.now();
    final seuil = DateTime(now.year, now.month - seuilMois, now.day);

    return factures.where((f) {
      // Déjà archivée → pas dans la liste
      if (f.estArchive) return false;

      // Pas soldée → pas archivable
      if (!f.estSoldee) return false;

      // Doit avoir au moins un paiement
      if (f.paiements.isEmpty) return false;

      // Date du dernier paiement
      final dernierPaiement = f.paiements
          .map((p) => p.datePaiement)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      // Archivable si dernier paiement avant le seuil
      return dernierPaiement.isBefore(seuil);
    }).toList();
  }
}
