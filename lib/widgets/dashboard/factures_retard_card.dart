import 'package:flutter/material.dart';
import '../../services/relance_service.dart';
import '../../config/theme.dart';

/// Widget dashboard affichant un résumé des factures en retard
/// avec badge de notification.
class FacturesRetardCard extends StatelessWidget {
  final List<RelanceInfo> relances;
  final VoidCallback? onTap;

  const FacturesRetardCard({
    super.key,
    required this.relances,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relances.isEmpty) {
      return _buildEmptyCard();
    }

    // Stats rapides
    final montantTotal = relances.fold(
      0.0,
      (sum, r) => sum + r.resteAPayer.toDouble(),
    );
    final retardMax = relances.first.joursRetard; // déjà trié décroissant

    // Répartition par niveau
    final Map<NiveauRelance, int> parNiveau = {};
    for (var r in relances) {
      parNiveau[r.niveau] = (parNiveau[r.niveau] ?? 0) + 1;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icône avec badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.notification_important_rounded,
                            color: Colors.red.shade700, size: 24),
                      ),
                      if (relances.isNotEmpty)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              relances.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Factures en retard",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade400),
                ],
              ),

              const SizedBox(height: 16),

              // Montant + Retard max
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      "Montant total",
                      "${montantTotal.toStringAsFixed(2)} €",
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetric(
                      "Retard max",
                      "$retardMax jours",
                      Colors.deepOrange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Répartition par niveau (barres)
              _buildNiveauxBar(parNiveau),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: Colors.green.shade600, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Aucune facture en retard",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text("Tous les paiements sont à jour",
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildNiveauxBar(Map<NiveauRelance, int> parNiveau) {
    final total = relances.length;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Répartition",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (parNiveau.containsKey(NiveauRelance.amiable))
                  Expanded(
                    flex: parNiveau[NiveauRelance.amiable]!,
                    child: Container(color: Colors.orange),
                  ),
                if (parNiveau.containsKey(NiveauRelance.ferme))
                  Expanded(
                    flex: parNiveau[NiveauRelance.ferme]!,
                    child: Container(color: Colors.deepOrange),
                  ),
                if (parNiveau.containsKey(NiveauRelance.miseEnDemeure))
                  Expanded(
                    flex: parNiveau[NiveauRelance.miseEnDemeure]!,
                    child: Container(color: Colors.red),
                  ),
                if (parNiveau.containsKey(NiveauRelance.contentieux))
                  Expanded(
                    flex: parNiveau[NiveauRelance.contentieux]!,
                    child: Container(color: Colors.red.shade900),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Légende
        Wrap(
          spacing: 12,
          children: [
            if (parNiveau.containsKey(NiveauRelance.amiable))
              _buildLegend(
                  "Amiable", Colors.orange, parNiveau[NiveauRelance.amiable]!),
            if (parNiveau.containsKey(NiveauRelance.ferme))
              _buildLegend(
                  "Ferme", Colors.deepOrange, parNiveau[NiveauRelance.ferme]!),
            if (parNiveau.containsKey(NiveauRelance.miseEnDemeure))
              _buildLegend("Mise en demeure", Colors.red,
                  parNiveau[NiveauRelance.miseEnDemeure]!),
            if (parNiveau.containsKey(NiveauRelance.contentieux))
              _buildLegend("Contentieux", Colors.red.shade900,
                  parNiveau[NiveauRelance.contentieux]!),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text("$label ($count)",
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
