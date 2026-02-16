import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../models/urssaf_model.dart';
import '../../models/enums/entreprise_enums.dart';

class PlafondsCard extends StatelessWidget {
  final Decimal caVente;
  final Decimal caPrestaBIC;
  final Decimal caPrestaBNC;
  final TypeEntreprise type;
  final UrssafConfig config;

  const PlafondsCard({
    super.key,
    required this.caVente,
    required this.caPrestaBIC,
    required this.caPrestaBNC,
    required this.type,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final caVente = this.caVente; // Use the class member
    final caService = caPrestaBIC + caPrestaBNC; // Use class members

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sécurité Plafonds 2026",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 1. Plafond Micro Vente
            _buildGauge(
              context,
              "Plafond Micro Vente",
              caVente,
              config.plafondCaMicroVente,
              Colors.purple,
            ),
            const SizedBox(height: 16),

            // 2. Plafond Micro Service
            _buildGauge(
              context,
              "Plafond Micro Service",
              caService,
              config.plafondCaMicroService,
              Colors.purpleAccent,
            ),
            const SizedBox(height: 16),

            // 3. Franchise TVA Base
            _buildGauge(
              context,
              "Franchise TVA (Base)",
              caVente + caService, // Total turnover for global threshold
              config.seuilTvaMicroVente,
              Colors.orange,
            ),
            const SizedBox(height: 16),

            // 4. Franchise TVA Majoré
            _buildGauge(
              context,
              "Franchise TVA (Majoré)",
              caVente + caService,
              config.seuilTvaMicroVenteMaj,
              Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(
    BuildContext context,
    String title,
    Decimal current,
    Decimal max,
    Color color,
  ) {
    final double percent = max > Decimal.zero
        ? (current.toDouble() / max.toDouble()).clamp(0.0, 1.0)
        : 0.0;

    final displayColor = percent > 0.9 ? Colors.red : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            Text(
              "${(percent * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: displayColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: displayColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: displayColor.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${current.toStringAsFixed(0)}€",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              "${max.toStringAsFixed(0)}€",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
