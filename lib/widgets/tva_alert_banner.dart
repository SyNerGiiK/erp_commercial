import 'package:flutter/material.dart';
import '../services/tva_service.dart';

/// Bannière d'alerte TVA réutilisable dans les steppers et le dashboard.
///
/// Affiche un message contextuel selon le [BilanTva] :
/// - Vert si franchise en base
/// - Orange si approche du seuil
/// - Rouge si seuil dépassé
class TvaAlertBanner extends StatelessWidget {
  final BilanTva bilan;

  /// Si true, affiche toujours la bannière (même en franchise).
  /// Si false (défaut), n'affiche que si une alerte est requise.
  final bool showAlways;

  const TvaAlertBanner({
    super.key,
    required this.bilan,
    this.showAlways = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAlways && !bilan.requiresAlert) return const SizedBox.shrink();

    final Color bgColor;
    final Color borderColor;
    final IconData icon;
    final String title;

    switch (bilan.statutGlobal) {
      case StatutTva.enFranchise:
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        icon = Icons.check_circle_outline;
        title = 'Franchise TVA';
      case StatutTva.approcheSeuil:
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade400;
        icon = Icons.warning_amber_rounded;
        title = 'Approche seuil TVA';
      case StatutTva.seuilBaseDepasse:
        bgColor = Colors.orange.shade100;
        borderColor = Colors.deepOrange;
        icon = Icons.notification_important;
        title = 'Seuil TVA de base dépassé';
      case StatutTva.seuilMajoreDepasse:
        bgColor = Colors.red.shade50;
        borderColor = Colors.red;
        icon = Icons.error;
        title = 'SEUIL TVA MAJORÉ DÉPASSÉ';
    }

    final messages = bilan.alertMessages;
    if (messages.isEmpty && !showAlways) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: borderColor,
                  ),
                ),
              ),
            ],
          ),
          if (messages.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...messages.map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    msg,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                )),
          ],
          if (bilan.forceTvaImmediate) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ La TVA doit être appliquée immédiatement sur ce document.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
