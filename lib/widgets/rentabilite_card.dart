import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../config/theme.dart';
import '../utils/format_utils.dart'; // Pour le formatage monétaire

enum RentabiliteType { chantier, materiel }

class RentabiliteCard extends StatelessWidget {
  final RentabiliteType type;
  final Decimal ca;
  final Decimal cout;
  final Decimal charges;
  final Decimal solde;
  final Decimal tauxUrssaf;

  const RentabiliteCard({
    super.key,
    required this.type,
    required this.ca,
    required this.cout,
    required this.charges,
    required this.solde,
    required this.tauxUrssaf,
  });

  @override
  Widget build(BuildContext context) {
    final isChantier = type == RentabiliteType.chantier;
    final isPositive = solde >= Decimal.zero;

    // Configuration des couleurs selon le mode
    final Color bgColor = isChantier
        ? AppTheme.primary.withValues(alpha: 0.1)
        : Colors.orange.shade50;
    final Color titleColor = isChantier ? AppTheme.primary : Colors.deepOrange;
    final String titleText =
        isChantier ? "REVENU DU CHANTIER" : "ANALYSE RENTABILITÉ";
    final String subText = isChantier
        ? "Marge nette après impôts (URSSAF ${tauxUrssaf.toDouble()}%)"
        : "Marge brute (Coeff. x?)";

    // Libellé résultat
    final String labelResult = isChantier ? "NET POCHE" : "MARGE BRUTE";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: titleColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titleText,
                      style: TextStyle(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Text(subText,
                      style: TextStyle(
                          color: titleColor.withValues(alpha: 0.7),
                          fontSize: 10)),
                ],
              ),
              // CA TOTAL
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("TOTAL VENTE (HT)", style: TextStyle(fontSize: 9)),
                  Text(
                    FormatUtils.currency(ca),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textDark),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          // Colonne Chiffres
          Row(
            children: [
              // Charges
              _buildDetailColumn("Charges", charges, Colors.red),
              const SizedBox(width: 12),

              // Coût / Achat
              _buildDetailColumn(
                  isChantier ? "Matériel" : "Achat", cout, Colors.grey),
              const SizedBox(width: 12),

              // Résultat Net
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(labelResult,
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.bold)),
                  Text(
                    FormatUtils.currency(solde),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isPositive ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, Decimal amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 9, color: color)),
        Text(
          "- ${FormatUtils.currency(amount)}",
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }
}
