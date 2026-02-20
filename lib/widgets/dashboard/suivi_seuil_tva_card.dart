import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../services/tva_service.dart';
import '../../utils/format_utils.dart';

/// Widget dashboard « Suivi seuil TVA » avec progression vers les plafonds.
///
/// Affiche deux jauges (vente et service) avec indicateurs de statut
/// et un résumé du statut global TVA.
class SuiviSeuilTvaCard extends StatelessWidget {
  final BilanTva bilan;

  const SuiviSeuilTvaCard({
    super.key,
    required this.bilan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec icône statut
            Row(
              children: [
                Icon(
                  _globalIcon,
                  color: _globalColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Suivi Seuil TVA",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 20),

            // Jauge Vente
            _buildTvaGauge(
              context,
              analyse: bilan.vente,
              label: 'CA Vente',
              colorBase: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Jauge Service
            _buildTvaGauge(
              context,
              analyse: bilan.service,
              label: 'CA Service',
              colorBase: Colors.purple,
            ),

            // Alerte si dépassement
            if (bilan.requiresAlert) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...bilan.alertMessages.map((msg) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      msg,
                      style: TextStyle(
                        fontSize: 12,
                        color: _globalColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _globalColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _globalColor,
        ),
      ),
    );
  }

  Widget _buildTvaGauge(
    BuildContext context, {
    required AnalyseTva analyse,
    required String label,
    required Color colorBase,
  }) {
    final progressBase = analyse.progressionBase.clamp(0.0, 1.0);
    final progressMaj = analyse.progressionMajore.clamp(0.0, 1.0);
    final color = _colorForStatut(analyse.statut, colorBase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + montant
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              '${analyse.caActuel.toDouble().toStringAsFixed(0)}€',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Barre seuil de base
        Row(
          children: [
            const SizedBox(
              width: 45,
              child: Text('Base',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
            Expanded(
              child: _buildProgressBar(progressBase, color),
            ),
            const SizedBox(width: 8),
            Text(
              '${analyse.seuilBase.toDouble().toStringAsFixed(0)}€',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Barre seuil majoré
        Row(
          children: [
            const SizedBox(
              width: 45,
              child: Text('Majoré',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
            Expanded(
              child: _buildProgressBar(progressMaj, color),
            ),
            const SizedBox(width: 8),
            Text(
              '${analyse.seuilMajore.toDouble().toStringAsFixed(0)}€',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),

        // Marge restante
        if (analyse.margeBase > Decimal.zero)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 45),
            child: Text(
              'Marge base : ${analyse.margeBase.toDouble().toStringAsFixed(0)}€',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar(double percent, Color color) {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        FractionallySizedBox(
          widthFactor: percent,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _colorForStatut(StatutTva statut, Color base) {
    switch (statut) {
      case StatutTva.enFranchise:
        return base;
      case StatutTva.approcheSeuil:
        return Colors.orange;
      case StatutTva.seuilBaseDepasse:
        return Colors.deepOrange;
      case StatutTva.seuilMajoreDepasse:
        return Colors.red;
    }
  }

  Color get _globalColor {
    switch (bilan.statutGlobal) {
      case StatutTva.enFranchise:
        return Colors.green;
      case StatutTva.approcheSeuil:
        return Colors.orange;
      case StatutTva.seuilBaseDepasse:
        return Colors.deepOrange;
      case StatutTva.seuilMajoreDepasse:
        return Colors.red;
    }
  }

  IconData get _globalIcon {
    switch (bilan.statutGlobal) {
      case StatutTva.enFranchise:
        return Icons.verified_outlined;
      case StatutTva.approcheSeuil:
        return Icons.warning_amber_rounded;
      case StatutTva.seuilBaseDepasse:
        return Icons.notification_important;
      case StatutTva.seuilMajoreDepasse:
        return Icons.error;
    }
  }

  String get _statusLabel {
    switch (bilan.statutGlobal) {
      case StatutTva.enFranchise:
        return 'FRANCHISE';
      case StatutTva.approcheSeuil:
        return 'ATTENTION';
      case StatutTva.seuilBaseDepasse:
        return 'DÉPASSÉ';
      case StatutTva.seuilMajoreDepasse:
        return 'URGENT';
    }
  }
}
