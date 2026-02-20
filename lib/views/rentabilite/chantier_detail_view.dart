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
    try {
      if (vm.devisList.isEmpty) {
        await vm.loadDevis();
      }
      final devis = vm.devisList.firstWhere((d) => d.id == widget.devisId);
      await vm.selectDevis(devis);
    } catch (e) {
      // Devis introuvable ou erreur de chargement
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
        length: 4,
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
                  Tab(text: 'Bilan Financier'),
                  Tab(text: 'Ventilation URSSAF'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTerrainTab(vm),
                  _buildDepensesTab(vm),
                  _buildBilanFinancierTab(vm),
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
    final resultatPrev = vm.resultatPrevisionnel;
    final resultatReel = vm.resultatReel;
    final colorPrev =
        resultatPrev >= Decimal.zero ? AppTheme.accent : AppTheme.error;
    final colorReel =
        resultatReel >= Decimal.zero ? AppTheme.accent : AppTheme.error;

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
          _buildKpi("Résultat Prévisionnel", resultatPrev, colorPrev),
          _buildKpi("Résultat Réel", resultatReel, colorReel),
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

  Widget _buildBilanFinancierTab(RentabiliteViewModel vm) {
    final devis = vm.selectedDevis;
    if (devis == null) {
      return const Center(child: Text('Aucun devis sélectionné.'));
    }

    final caHt = devis.totalHt;
    final totalAchats = vm.totalAchats;
    final margePrevue = vm.margePrevue;
    final totalDepenses = vm.totalDepenses;
    final margeReelle = vm.margeReelle;
    final detail = vm.detailCotisations;
    final totalCharges = vm.chargesSociales;
    final resultatPrev = vm.resultatPrevisionnel;
    final resultatReel = vm.resultatReel;

    // Déterminer le taux dominant pour l'affichage
    final caVente = devis.caVente;
    final caPrestation = devis.caPrestation;
    String tauxSocialLabel;
    if (caVente > Decimal.zero && caPrestation > Decimal.zero) {
      tauxSocialLabel = 'mixte';
    } else if (caVente > Decimal.zero) {
      tauxSocialLabel =
          '${vm.urssafConfig.tauxMicroVente.toStringAsFixed(1)}%';
    } else {
      tauxSocialLabel =
          '${vm.urssafConfig.tauxMicroPrestationBIC.toStringAsFixed(1)}%';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CA HT
          _buildWaterfallRow(
            icon: Icons.receipt_long,
            label: 'CA HT (Devis)',
            montant: caHt,
            color: AppTheme.primary,
          ),
          const Divider(height: 24),

          // Coûts prévus
          _buildWaterfallRow(
            icon: Icons.shopping_cart_outlined,
            label: 'Coûts prévus (Chiffrages)',
            montant: -totalAchats,
            color: AppTheme.warning,
            prefix: '-',
          ),
          _buildWaterfallResult(
            label: 'Marge brute prévue',
            montant: margePrevue,
          ),
          const Divider(height: 24),

          // Dépenses réelles
          _buildWaterfallRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Dépenses réelles',
            montant: -totalDepenses,
            color: AppTheme.error,
            prefix: '-',
          ),
          _buildWaterfallResult(
            label: 'Marge brute réelle',
            montant: margeReelle,
          ),
          const Divider(height: 24),

          // Cotisations sociales
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Cotisations Sociales',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          _buildChargeRow(
            label: 'Sociales ($tauxSocialLabel)',
            montant: detail['social'] ?? Decimal.zero,
          ),
          if ((detail['cfp'] ?? Decimal.zero) > Decimal.zero)
            _buildChargeRow(
              label: 'CFP',
              montant: detail['cfp'] ?? Decimal.zero,
            ),
          if ((detail['tfc'] ?? Decimal.zero) > Decimal.zero)
            _buildChargeRow(
              label: 'TFC',
              montant: detail['tfc'] ?? Decimal.zero,
            ),
          if ((detail['liberatoire'] ?? Decimal.zero) > Decimal.zero)
            _buildChargeRow(
              label: 'Versement Libératoire',
              montant: detail['liberatoire'] ?? Decimal.zero,
            ),
          const SizedBox(height: 4),
          _buildWaterfallRow(
            icon: Icons.summarize_outlined,
            label: 'Total Cotisations',
            montant: -totalCharges,
            color: AppTheme.textSecondary,
            prefix: '-',
            bold: true,
          ),
          const SizedBox(height: 24),

          // Résultat net prévisionnel
          _buildFinalResult(
            label: 'Résultat net prévisionnel',
            montant: resultatPrev,
          ),
          const SizedBox(height: 12),

          // Résultat net réel
          _buildFinalResult(
            label: 'Résultat net réel',
            montant: resultatReel,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterfallRow({
    required IconData icon,
    required String label,
    required Decimal montant,
    required Color color,
    String prefix = '',
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            '${prefix.isNotEmpty && montant != Decimal.zero ? '$prefix ' : ''}${FormatUtils.currency(montant.abs())}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterfallResult({
    required String label,
    required Decimal montant,
  }) {
    final isPositive = montant >= Decimal.zero;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: Text(
              '= $label',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            FormatUtils.currency(montant),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: isPositive ? AppTheme.accent : AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeRow({
    required String label,
    required Decimal montant,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 2, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            '- ${FormatUtils.currency(montant)}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalResult({
    required String label,
    required Decimal montant,
  }) {
    final isPositive = montant >= Decimal.zero;
    final color = isPositive ? AppTheme.accent : AppTheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            FormatUtils.currency(montant),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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

        // Correction : getVentilationMaterielRatio attend un Devis, pas un String
        final devis = vm.selectedDevis;
        if (devis == null) return const SizedBox.shrink();
        final ratioMateriel = vm.getVentilationMaterielRatio(devis);
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
