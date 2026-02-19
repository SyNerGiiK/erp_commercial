import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';

class CotisationDetailCard extends StatefulWidget {
  final Map<String, Decimal> breakdown; // Keys: social, cfp, tfc, liberatoire
  final Decimal total;
  final Map<String, Decimal> repartition; // Keys: maladie, retraite_base, etc.

  const CotisationDetailCard({
    super.key,
    required this.breakdown,
    required this.total,
    this.repartition = const {},
  });

  @override
  State<CotisationDetailCard> createState() => _CotisationDetailCardState();
}

class _CotisationDetailCardState extends State<CotisationDetailCard> {
  bool _showRepartition = false;

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
      'tfc': {
        'label': 'Taxe Frais de Chambre (TFC)',
        'color': Colors.orange,
        'icon': Icons.business
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
                    "Total: ${widget.total.toStringAsFixed(2)} €",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.total == Decimal.zero)
              const Center(child: Text("Aucune cotisation sur la période"))
            else ...[
              ...widget.breakdown.entries
                  .where((e) => e.key != 'total' && e.value > Decimal.zero)
                  .map((entry) {
                final info = displayMap[entry.key];
                if (info == null) return const SizedBox.shrink();

                final percentage =
                    (entry.value.toDouble() / widget.total.toDouble() * 100)
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
                              value: (entry.value.toDouble() /
                                  widget.total.toDouble()),
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

              // --- Sous-répartition expandable (P5) ---
              if (widget.repartition.isNotEmpty) ...[
                const Divider(height: 32),
                _buildRepartitionSection(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRepartitionSection() {
    final repartitionLabels = {
      'maladie': {
        'label': 'Maladie-Maternité',
        'color': const Color(0xFF06B6D4),
        'icon': Icons.local_hospital_outlined,
      },
      'retraite_base': {
        'label': 'Retraite de base',
        'color': const Color(0xFF6366F1),
        'icon': Icons.elderly_outlined,
      },
      'retraite_complementaire': {
        'label': 'Retraite complémentaire',
        'color': const Color(0xFF8B5CF6),
        'icon': Icons.add_circle_outline,
      },
      'invalidite_deces': {
        'label': 'Invalidité-Décès',
        'color': const Color(0xFFF43F5E),
        'icon': Icons.shield_outlined,
      },
      'csg_crds': {
        'label': 'CSG / CRDS',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.receipt_long_outlined,
      },
      'cotisations_bnc': {
        'label': 'Cotisations BNC (forfaitaire)',
        'color': const Color(0xFF10B981),
        'icon': Icons.work_outline,
      },
    };

    final totalRepartition =
        widget.repartition.values.fold(Decimal.zero, (sum, v) => sum + v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showRepartition = !_showRepartition),
          borderRadius: AppTheme.borderRadiusSmall,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
            child: Row(
              children: [
                Icon(
                  _showRepartition ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppTheme.textMedium,
                ),
                const SizedBox(width: AppTheme.spacing8),
                const Text(
                  'Répartition par branche',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textMedium,
                  ),
                ),
                const Spacer(),
                Text(
                  '${totalRepartition.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showRepartition)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: Column(
              children: widget.repartition.entries
                  .where((e) => e.value > Decimal.zero)
                  .map((entry) {
                final info = repartitionLabels[entry.key];
                if (info == null) return const SizedBox.shrink();

                final color = info['color'] as Color;
                final icon = info['icon'] as IconData;
                final pct = totalRepartition > Decimal.zero
                    ? (entry.value.toDouble() /
                        totalRepartition.toDouble() *
                        100)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing4,
                      horizontal: AppTheme.spacing4),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info['label'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            LinearProgressIndicator(
                              value: pct / 100,
                              color: color,
                              backgroundColor: color.withValues(alpha: 0.1),
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      SizedBox(
                        width: 75,
                        child: Text(
                          '${entry.value.toStringAsFixed(2)} €',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 45,
                        child: Text(
                          '${pct.toStringAsFixed(0)}%',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
