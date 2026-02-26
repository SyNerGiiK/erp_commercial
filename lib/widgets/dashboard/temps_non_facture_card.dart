// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';

/// Mini-card dashboard affichant le temps facturable non encore facturé.
class TempsNonFactureCard extends StatelessWidget {
  final int totalMinutes;
  final Decimal montantFacturable;
  final String dureeFormatee;
  final int nbEntrees;
  final VoidCallback? onTap;

  const TempsNonFactureCard({
    super.key,
    required this.totalMinutes,
    required this.montantFacturable,
    required this.dureeFormatee,
    required this.nbEntrees,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    color: AppTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.timer_outlined,
                      color: AppTheme.secondary, size: 18),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Text(
                    'Temps à facturer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing16),

            if (nbEntrees == 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tout est facturé ✓',
                  style: TextStyle(fontSize: 12, color: AppTheme.accent),
                ),
              )
            else ...[
              // Durée totale
              Row(
                children: [
                  Text(
                    dureeFormatee,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.secondary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$nbEntrees entrée${nbEntrees > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing8),
              // Montant facturable
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.euro_rounded, size: 14, color: AppTheme.accent),
                    SizedBox(width: 4),
                    Text(
                      '${montantFacturable.toDouble().toStringAsFixed(0)} € facturables',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
