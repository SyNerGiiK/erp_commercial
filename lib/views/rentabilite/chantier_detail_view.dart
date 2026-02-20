import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';

import '../../config/theme.dart';
import '../../utils/format_utils.dart';
import '../../viewmodels/rentabilite_viewmodel.dart';
import '../../widgets/base_screen.dart';
import '../../models/chiffrage_model.dart';

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
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            _buildKpiHeader(vm),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceGlassLight,
                border: Border(
                  bottom: BorderSide(
                      color: AppTheme.primary.withValues(alpha: 0.1)),
                ),
              ),
              child: const TabBar(
                tabs: [
                  Tab(text: 'Terrain'),
                  Tab(text: 'Dépenses'),
                  Tab(text: 'Ventilation Secrète URSSAF'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTerrainTab(vm),
                  _buildDepensesTab(vm),
                  _buildVentilationTab(vm),
                ],
              ),
            ),
          ],
        ),
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
          _buildKpi(
              "Facturé (Acpt/Sit)", vm.facturationEncaissee, AppTheme.primary),
          _buildKpi("Marge Prévue", vm.margePrevue, AppTheme.warning),
          _buildKpi("Marge Réelle", vm.margeReelle, AppTheme.accent),
          _buildKpi("Avancement Global", vm.avancementGlobal, AppTheme.info,
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
              ? "${value.toDouble().toStringAsFixed(1)} %"
              : FormatUtils.currency(value),
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildTerrainTab(RentabiliteViewModel vm) {
    final lignes = vm.lignesAvancement;

    if (lignes.isEmpty) {
      return const Center(
          child: Text('Aucune ligne exploitable sur ce chantier.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lignes.length,
      itemBuilder: (context, index) {
        final state = lignes[index];
        final chiffrages = vm.getChiffragesForLigne(state.ligne.id ?? '');

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGlassLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      state.ligne.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${state.avancement.toDouble().toStringAsFixed(1)} %',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          state.isComplete ? AppTheme.accent : AppTheme.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                minHeight: 8,
                value: state.avancement.toDouble() / 100.0,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation(
                    state.isComplete ? AppTheme.accent : AppTheme.warning),
              ),
              const SizedBox(height: 8),
              Text(
                'Ligne: ${FormatUtils.currency(state.prixTotal)}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 10),
              ...chiffrages.map((c) {
                if (c.typeChiffrage == TypeChiffrage.materiel) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (c.id != null) {
                            vm.toggleEstAchete(c.id!);
                          }
                        },
                        icon: Icon(
                          c.estAchete
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                        ),
                        label: Text(
                          c.estAchete
                              ? 'Matériel acheté • ${FormatUtils.currency(c.prixVenteInterne)}'
                              : 'Marquer acheté • ${FormatUtils.currency(c.prixVenteInterne)}',
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Main d\'œuvre • ${FormatUtils.currency(c.prixVenteInterne)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Slider(
                        value: c.avancementMo.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label:
                            '${c.avancementMo.toDouble().toStringAsFixed(0)}%',
                        onChanged: (value) {
                          if (c.id != null) {
                            vm.updateAvancementMo(
                              c.id!,
                              Decimal.parse(value.toStringAsFixed(2)),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepensesTab(RentabiliteViewModel vm) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${vm.depenses.length} dépense(s) rattachée(s) • Total ${FormatUtils.currency(vm.depenses.fold(Decimal.zero, (s, d) => s + d.montant))}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.push('/app/ajout_depense'),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une dépense'),
              ),
            ],
          ),
        ),
        Expanded(
          child: vm.depenses.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune dépense rattachée à ce chantier pour le moment.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.depenses.length,
                  itemBuilder: (context, index) {
                    final depense = vm.depenses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceGlassLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ListTile(
                        title: Text(depense.titre),
                        subtitle: Text(
                          '${FormatUtils.date(depense.date)} • ${depense.fournisseur ?? 'Sans fournisseur'} • ${depense.categorie.toUpperCase()}',
                        ),
                        trailing: Text(
                          FormatUtils.currency(depense.montant),
                          style: const TextStyle(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVentilationTab(RentabiliteViewModel vm) {
    final lignes = vm.lignesAvancement;
    if (lignes.isEmpty) {
      return const Center(child: Text('Aucune ligne à ventiler.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lignes.length,
      itemBuilder: (context, index) {
        final ligne = lignes[index].ligne;
        if (ligne.id == null) return const SizedBox.shrink();

        final ratioMateriel = vm.getVentilationMaterielRatio(ligne.id!);
        final ratioMo = Decimal.fromInt(100) - ratioMateriel;
        final montantMateriel =
            ((ligne.totalLigne * ratioMateriel) / Decimal.fromInt(100))
                .toDecimal();
        final montantMo = ligne.totalLigne - montantMateriel;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGlassLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ligne.description,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Total ligne: ${FormatUtils.currency(ligne.totalLigne)}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                'Matériel ${ratioMateriel.toDouble().toStringAsFixed(0)}% • ${FormatUtils.currency(montantMateriel)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: ratioMateriel.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '${ratioMateriel.toDouble().toStringAsFixed(0)}%',
                onChanged: (value) {
                  vm.updateVentilationForLigne(
                    ligne.id!,
                    Decimal.parse(value.toStringAsFixed(2)),
                  );
                },
              ),
              Text(
                'Main d\'œuvre ${ratioMo.toDouble().toStringAsFixed(0)}% • ${FormatUtils.currency(montantMo)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}
