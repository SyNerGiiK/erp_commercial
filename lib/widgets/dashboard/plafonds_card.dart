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
    final caVente = this.caVente;
    final caService = caPrestaBIC + caPrestaBNC;
    final totalCA = caVente + caService;

    // Déterminer les seuils TVA appropriés selon le type d'activité principal
    // Vente → seuils vente (91900/101000), Service → seuils service (36800/39100)
    // Mixte / autre → on prend le seuil le plus bas (service) par prudence
    final bool isVenteOnly =
        caService == Decimal.zero && caVente > Decimal.zero;
    final Decimal seuilTvaBase =
        isVenteOnly ? config.seuilTvaMicroVente : config.seuilTvaMicroService;
    final Decimal seuilTvaMajore = isVenteOnly
        ? config.seuilTvaMicroVenteMaj
        : config.seuilTvaMicroServiceMaj;
    final String labelTypeCA = isVenteOnly ? "Vente" : "Service";

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

            // 1. Plafond Micro Vente (affiché seulement si CA vente > 0)
            if (caVente > Decimal.zero)
              _buildGauge(
                context,
                "Plafond Micro Vente",
                caVente,
                config.plafondCaMicroVente,
                Colors.purple,
              ),
            if (caVente > Decimal.zero) const SizedBox(height: 16),

            // 2. Plafond Micro Service (affiché seulement si CA service > 0)
            if (caService > Decimal.zero)
              _buildGauge(
                context,
                "Plafond Micro Service",
                caService,
                config.plafondCaMicroService,
                Colors.purpleAccent,
              ),
            if (caService > Decimal.zero) const SizedBox(height: 16),

            // 3. Franchise TVA Base (seuil adapté au type d'activité)
            _buildGauge(
              context,
              "Franchise TVA Base ($labelTypeCA)",
              totalCA,
              seuilTvaBase,
              Colors.orange,
            ),
            const SizedBox(height: 16),

            // 4. Franchise TVA Majoré (seuil adapté au type d'activité)
            _buildGauge(
              context,
              "Franchise TVA Majoré ($labelTypeCA)",
              totalCA,
              seuilTvaMajore,
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
