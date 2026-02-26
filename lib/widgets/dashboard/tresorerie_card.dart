// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';

/// KPI Card de trésorerie prévisionnelle pour le dashboard.
///
/// Affiche les encaissements attendus sur 3 mois avec barres horizontales.
class TresorerieCard extends StatelessWidget {
  final Decimal tresoreriePrev;
  final Map<String, Decimal> encaissementsParMois;
  final int nbFacturesImpayees;
  final VoidCallback? onTap;

  const TresorerieCard({
    super.key,
    required this.tresoreriePrev,
    required this.encaissementsParMois,
    required this.nbFacturesImpayees,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = encaissementsParMois.entries.toList();
    final maxVal = entries.isEmpty
        ? 1.0
        : entries
            .map((e) => e.value.toDouble())
            .reduce((a, b) => a > b ? a : b);
    final maxForBar = maxVal > 0 ? maxVal : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGlassBright,
          borderRadius: AppTheme.borderRadiusMedium,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color: AppTheme.info, size: 18),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Text(
                    'Trésorerie prévue',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Text(
                  '$nbFacturesImpayees fact.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),

            // Total
            Text(
              '${tresoreriePrev.toDouble().toStringAsFixed(0)} €',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.info,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'encaissements attendus',
              style: TextStyle(fontSize: 11, color: AppTheme.textLight),
            ),
            SizedBox(height: AppTheme.spacing12),

            // Barres par mois
            ...entries.map((entry) {
              final monthLabel = _formatMonthKey(entry.key);
              final value = entry.value.toDouble();
              final pct = value / maxForBar;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        monthLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          backgroundColor: AppTheme.surfaceVariant,
                          color: AppTheme.info.withValues(
                              alpha: 0.5 + (pct * 0.5).clamp(0.0, 0.5)),
                          minHeight: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 55,
                      child: Text(
                        '${value.toStringAsFixed(0)} €',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatMonthKey(String key) {
    try {
      final parts = key.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('MMM', 'fr_FR').format(date).toUpperCase();
    } catch (_) {
      return key;
    }
  }
}
