import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

class CotisationDetailCard extends StatelessWidget {
  final Map<String, Decimal> breakdown; // Keys: social, cfp, liberatoire
  final Decimal total;

  const CotisationDetailCard({
    super.key,
    required this.breakdown,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    // Mapping des labels pour l'affichage
    final displayMap = {
      'social': {
        'label': 'Cotisations Sociales (Base)',
        'color': Colors.blue,
        'icon': Icons.security
      },
      'cfp': {
        'label': 'Formation Pro (CFP)',
        'color': Colors.purple,
        'icon': Icons.school
      },
      'liberatoire': {
        'label': 'Impôt Libératoire',
        'color': Colors.green,
        'icon': Icons.account_balance_wallet
      },
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transparence URSSAF",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Total: ${total.toStringAsFixed(2)} €",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (total == Decimal.zero)
              const Center(child: Text("Aucune cotisation sur la période"))
            else
              ...breakdown.entries
                  .where((e) => e.key != 'total' && e.value > Decimal.zero)
                  .map((entry) {
                final info = displayMap[entry.key];
                if (info == null) return const SizedBox.shrink();

                final percentage =
                    (entry.value.toDouble() / total.toDouble() * 100)
                        .toStringAsFixed(1);
                final color = info['color'] as Color;
                final icon = info['icon'] as IconData;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info['label'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            LinearProgressIndicator(
                              value:
                                  (entry.value.toDouble() / total.toDouble()),
                              color: color,
                              backgroundColor: color.withValues(alpha: 0.1),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${entry.value.toStringAsFixed(2)} €",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text("$percentage%",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ],
                      )
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
