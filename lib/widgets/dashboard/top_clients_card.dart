// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Widget dashboard « Top Clients » — style Aurora 2030 glass.
class TopClientsCard extends StatelessWidget {
  final List<Map<String, dynamic>> clients;
  final VoidCallback? onTap;

  const TopClientsCard({super.key, required this.clients, this.onTap});

  @override
  Widget build(BuildContext context) {
    final display = clients.take(5).toList();

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
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.people_outline_rounded,
                      color: AppTheme.accent, size: 18),
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Text(
                    'Top Clients',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing12),

            if (display.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aucun encaissement',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              )
            else
              ...List.generate(display.length, (i) {
                final c = display[i];
                final dynamic caValue = c['ca'];
                final double ca =
                    caValue is double ? caValue : (caValue?.toDouble() ?? 0.0);
                final maxCa = display.first['ca'] is double
                    ? display.first['ca'] as double
                    : (display.first['ca']?.toDouble() ?? 1.0);
                final pct = maxCa > 0 ? ca / maxCa : 0.0;
                final colors = [
                  AppTheme.accent,
                  AppTheme.primary,
                  AppTheme.secondary,
                  AppTheme.highlight,
                  AppTheme.info,
                ];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Rang
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color:
                              colors[i % colors.length].withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors[i % colors.length],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['label']?.toString() ?? 'Client',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: pct.clamp(0.0, 1.0),
                                backgroundColor: Colors.grey.shade200,
                                color: colors[i % colors.length],
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${ca.toStringAsFixed(0)} €',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
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
}
