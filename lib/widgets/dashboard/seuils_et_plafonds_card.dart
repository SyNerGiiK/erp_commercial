// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';
import '../../models/enums/entreprise_enums.dart';
import '../../models/urssaf_model.dart';
import '../../services/tva_service.dart';

/// Carte Unifiée "Seuils & Plafonds" (Aurora 2030)
///
/// Fusionne intelligemment l'ancien `PlafondsCard` et `SuiviSeuilTvaCard`.
/// S'adapte contextuellement :
/// - Micro-entrepreneur : Affiche Plafonds CA + Franchise TVA
/// - TNS / Assimilé : Affiche uniquement les Seuils TVA (Assujettissement)
class SeuilsEtPlafondsCard extends StatelessWidget {
  final TypeEntreprise type;
  final Decimal caVente;
  final Decimal caService;
  final UrssafConfig? config;
  final BilanTva? bilanTva;

  const SeuilsEtPlafondsCard({
    super.key,
    required this.type,
    required this.caVente,
    required this.caService,
    this.config,
    this.bilanTva,
  });

  bool get isMicro => type == TypeEntreprise.microEntrepreneur;

  @override
  Widget build(BuildContext context) {
    if (!isMicro && bilanTva == null) {
      return const SizedBox.shrink(); // Rien à afficher
    }

    // Détermination de la couleur/icône globale
    Color globalColor = AppTheme.accent;
    IconData globalIcon = Icons.check_circle_outline_rounded;
    String globalStatus = isMicro ? "Sécurisé" : "Franchise";

    if (bilanTva != null) {
      switch (bilanTva!.statutGlobal) {
        case StatutTva.enFranchise:
          globalColor = AppTheme.accent;
          globalIcon = Icons.check_circle_outline_rounded;
          globalStatus = "Franchise TVA";
          break;
        case StatutTva.approcheSeuil:
          globalColor = AppTheme.warning;
          globalIcon = Icons.warning_amber_rounded;
          globalStatus = "Approche Seuil TVA";
          break;
        case StatutTva.seuilBaseDepasse:
          globalColor = AppTheme.error;
          globalIcon = Icons.notification_important_rounded;
          globalStatus = "Seuil Base Dépassé";
          break;
        case StatutTva.seuilMajoreDepasse:
          globalColor = AppTheme.error;
          globalIcon = Icons.error_outline_rounded;
          globalStatus = "Assujetti TVA";
          break;
      }
    }

    if (isMicro && config != null) {
      if (caVente >= config!.plafondCaMicroVente ||
          caService >= config!.plafondCaMicroService) {
        globalColor = AppTheme.error;
        globalIcon = Icons.dangerous_rounded;
        globalStatus = "Plafond Micro Dépassé";
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
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
          // ── HEADER ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: globalColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
                child: Icon(globalIcon, color: globalColor, size: 24),
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  "Seuils & Plafonds",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: globalColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: globalColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  globalStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: globalColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing24),

          // ── PLAFONDS CA (MIE ONLY) ──
          if (isMicro && config != null) ...[
            _buildModernGauge(
              title: "Plafond CA (Vente)",
              current: caVente,
              max: config!.plafondCaMicroVente,
              baseColor: AppTheme.primary,
            ),
            SizedBox(height: AppTheme.spacing16),
            _buildModernGauge(
              title: "Plafond CA (Service)",
              current: caService,
              max: config!.plafondCaMicroService,
              baseColor: AppTheme.secondary,
            ),
            if (bilanTva != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                child: Divider(height: 1),
              ),
          ],

          // ── FRANCHISE TVA ──
          if (bilanTva != null) ...[
            _buildTvaGauge(
              label: 'Seuils TVA (Vente)',
              analyse: bilanTva!.vente,
              baseColor: AppTheme.info,
            ),
            SizedBox(height: AppTheme.spacing16),
            _buildTvaGauge(
              label: 'Seuils TVA (Service)',
              analyse: bilanTva!.service,
              baseColor: AppTheme.accent,
            ),

            // ALERT MESSAGES
            if (bilanTva!.requiresAlert) ...[
              SizedBox(height: AppTheme.spacing16),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.05),
                    borderRadius: AppTheme.borderRadiusSmall,
                    border: Border.all(
                        color: AppTheme.error.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: bilanTva!.alertMessages
                        .map((msg) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      size: 16, color: AppTheme.error),
                                  SizedBox(width: 8),
                                  Expanded(
                                      child: Text(msg,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textMedium))),
                                ],
                              ),
                            ))
                        .toList(),
                  ))
            ]
          ],
        ],
      ),
    );
  }

  // ─── WIDGETS INTERNES ───

  Widget _buildModernGauge({
    required String title,
    required Decimal current,
    required Decimal max,
    required Color baseColor,
  }) {
    final double percent = max > Decimal.zero
        ? (current.toDouble() / max.toDouble()).clamp(0.0, 1.0)
        : 0.0;

    final isWarning = percent > 0.85;
    final isDanger = percent > 0.95;
    final displayColor =
        isDanger ? AppTheme.error : (isWarning ? AppTheme.warning : baseColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textDark)),
            Text(
              "${(percent * 100).toDouble().toStringAsFixed(1)}%",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: displayColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.divider.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      displayColor.withValues(alpha: 0.7),
                      displayColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: displayColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${current.toDouble().toStringAsFixed(0)} €",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMedium),
            ),
            Text(
              "Max: ${max.toDouble().toStringAsFixed(0)} €",
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTvaGauge({
    required AnalyseTva analyse,
    required String label,
    required Color baseColor,
  }) {
    final progressBase = analyse.progressionBase.clamp(0.0, 1.0);
    final progressMaj = analyse.progressionMajore.clamp(0.0, 1.0);

    Color colorBase = baseColor;
    if (analyse.statut == StatutTva.seuilBaseDepasse ||
        analyse.statut == StatutTva.seuilMajoreDepasse) {
      colorBase = AppTheme.error;
    } else if (analyse.statut == StatutTva.approcheSeuil) {
      colorBase = AppTheme.warning;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textDark),
            ),
            Text(
              '${analyse.caActuel.toDouble().toStringAsFixed(0)} €',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: colorBase,
              ),
            ),
          ],
        ),
        if (analyse.margeBase > Decimal.zero)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: Text(
              'Marge restante : ${analyse.margeBase.toDouble().toStringAsFixed(0)} €',
              style: TextStyle(fontSize: 11, color: AppTheme.textLight),
            ),
          )
        else
          SizedBox(height: AppTheme.spacing8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: Text('Base',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMedium)),
            ),
            Expanded(child: _buildProgressBar(progressBase, colorBase)),
            SizedBox(width: AppTheme.spacing12),
            SizedBox(
              width: 60,
              child: Text(
                '${analyse.seuilBase.toDouble().toStringAsFixed(0)} €',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
            )
          ],
        ),
        SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: Text('Majoré',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMedium)),
            ),
            Expanded(child: _buildProgressBar(progressMaj, colorBase)),
            SizedBox(width: AppTheme.spacing12),
            SizedBox(
              width: 60,
              child: Text(
                '${analyse.seuilMajore.toDouble().toStringAsFixed(0)} €',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
            )
          ],
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
            color: AppTheme.divider.withValues(alpha: 0.3),
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
}
