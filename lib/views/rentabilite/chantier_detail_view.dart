import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';
import '../../utils/format_utils.dart';
import '../../viewmodels/rentabilite_viewmodel.dart';
import '../../widgets/base_screen.dart';
import '../../models/chiffrage_model.dart';

// Note : L'ancien panneau "Right" et l'éditeur de chiffrage ont été conservés
import '../../widgets/chiffrage_editor.dart';

class ChantierDetailView extends StatefulWidget {
  final String devisId;

  const ChantierDetailView({super.key, required this.devisId});

  @override
  State<ChantierDetailView> createState() => _ChantierDetailViewState();
}

class _ChantierDetailViewState extends State<ChantierDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final vm = context.read<RentabiliteViewModel>();
    if (vm.devisList.isEmpty) {
      await vm.loadDevis();
    }
    try {
      final devis = vm.devisList.firstWhere((d) => d.id == widget.devisId);
      await vm.selectDevis(devis);
    } catch (e) {
      // Introuvable
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentabiliteViewModel>();

    if (vm.isLoading || vm.selectedDevis == null) {
      return const BaseScreen(
        menuIndex: 8,
        title: "Détail Chantier",
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final devis = vm.selectedDevis!;

    return BaseScreen(
      menuIndex: 8,
      title: "Chantier : ${devis.objet}",
      child: Column(
        children: [
          _buildKpiHeader(vm),
          Expanded(
            child: Row(
              children: [
                // Panel Gauche : Lignes du Devis
                SizedBox(
                  width: 380,
                  child: _buildLignesPanel(vm),
                ),
                const VerticalDivider(width: 1),
                // Panel Droit : Éditeur / Détails Tracking
                Expanded(
                  child: _buildTrackingPanel(vm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiHeader(RentabiliteViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlassLight,
        border: Border(
            bottom: BorderSide(color: AppTheme.primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildKpi("Facturé (Acpt/Sit)", vm.facturationEncaissee, Colors.blue),
          _buildKpi("Marge Réelle", vm.margeReelle, Colors.green),
          _buildKpi("Avancement Global", vm.avancementGlobal, Colors.orange,
              isPercent: true),
        ],
      ),
    );
  }

  Widget _buildKpi(String label, dynamic value, Color color,
      {bool isPercent = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Text(
          isPercent
              ? "${value.toStringAsFixed(1)} %"
              : FormatUtils.formatCurrency(value),
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildLignesPanel(RentabiliteViewModel vm) {
    final lignes = vm.lignesAvancement;
    return ListView.builder(
      itemCount: lignes.length,
      itemBuilder: (context, index) {
        final state = lignes[index];
        final isSelected = vm.selectedLigneDevis?.id == state.ligne.id;
        return InkWell(
          onTap: () => vm.selectLigneDevis(state.ligne),
          child: Container(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.05) : null,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.ligne.description,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FormatUtils.formatCurrency(state.prixTotal),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      "${state.avancement.toDouble().toStringAsFixed(1)} %",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: state.isComplete
                            ? AppTheme.accent
                            : AppTheme.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: state.avancement.toDouble() / 100.0,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(
                      state.isComplete ? AppTheme.accent : AppTheme.warning),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackingPanel(RentabiliteViewModel vm) {
    if (vm.selectedLigneDevis == null) {
      return const Center(
        child: Text("Sélectionnez une ligne pour gérer son suivi et ses coûts"),
      );
    }
    // Composant existant pour l'édition détaillée
    return ChiffrageEditor(
      vm: vm, // suppose un ViewModel compatible ou qu'on lui passe directement la logique
    );
  }
}
