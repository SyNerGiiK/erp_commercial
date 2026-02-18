import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/relance_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../services/relance_service.dart';
import '../widgets/base_screen.dart';
import '../config/theme.dart';
import '../utils/format_utils.dart';

/// Écran de gestion des relances clients
class RelancesView extends StatefulWidget {
  const RelancesView({super.key});

  @override
  State<RelancesView> createState() => _RelancesViewState();
}

class _RelancesViewState extends State<RelancesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);
      final vm = Provider.of<RelanceViewModel>(context, listen: false);
      vm.setProfil(entVM.profil);
      vm.chargerRelances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RelanceViewModel>(
      builder: (context, vm, _) {
        return BaseScreen(
          menuIndex: 11,
          title: "Relances",
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: vm.chargerRelances,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── STATISTIQUES ──
                        _buildStatsRow(vm),
                        const SizedBox(height: 24),

                        // ── FILTRES ──
                        _buildFilters(vm),
                        const SizedBox(height: 16),

                        // ── LISTE ──
                        if (vm.relancesFiltrees.isEmpty)
                          _buildEmptyState()
                        else
                          ...vm.relancesFiltrees
                              .map((r) => _buildRelanceCard(context, vm, r)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // ── STATISTIQUES ROW ──

  Widget _buildStatsRow(RelanceViewModel vm) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          "Factures en retard",
          vm.totalRelances.toString(),
          Icons.warning_rounded,
          Colors.orange,
        ),
        _buildStatCard(
          "Montant total",
          "${vm.montantTotalImpaye.toStringAsFixed(2)} €",
          Icons.euro_rounded,
          Colors.red,
        ),
        _buildStatCard(
          "Retard moyen",
          "${vm.retardMoyen.toStringAsFixed(0)} jours",
          Icons.schedule_rounded,
          AppTheme.primary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    Text(label,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── FILTRES ──

  Widget _buildFilters(RelanceViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(vm, null, "Toutes"),
          const SizedBox(width: 8),
          _buildFilterChip(vm, NiveauRelance.amiable, "Amiable"),
          const SizedBox(width: 8),
          _buildFilterChip(vm, NiveauRelance.ferme, "Ferme"),
          const SizedBox(width: 8),
          _buildFilterChip(vm, NiveauRelance.miseEnDemeure, "Mise en demeure"),
          const SizedBox(width: 8),
          _buildFilterChip(vm, NiveauRelance.contentieux, "Contentieux"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      RelanceViewModel vm, NiveauRelance? niveau, String label) {
    final isSelected = vm.filtreNiveau == niveau;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.filtrerParNiveau(niveau),
      selectedColor: _niveauColor(niveau).withValues(alpha: 0.2),
      checkmarkColor: _niveauColor(niveau),
      labelStyle: TextStyle(
        color: isSelected ? _niveauColor(niveau) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // ── EMPTY STATE ──

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text("Aucune facture en retard !",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text("Tous vos clients sont à jour de paiement.",
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // ── CARTE RELANCE ──

  Widget _buildRelanceCard(
      BuildContext context, RelanceViewModel vm, RelanceInfo relance) {
    final color = _niveauColor(relance.niveau);
    final niveauLabel = _niveauLabel(relance.niveau);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/app/ajout_facture/${relance.facture.id}',
            extra: relance.facture),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Badge niveau
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_niveauIcon(relance.niveau),
                            size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(niveauLabel,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Jours de retard
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${relance.joursRetard} jours",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Infos facture
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(relance.facture.numeroFacture,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        if (relance.client != null)
                          Text(relance.client!.nomComplet,
                              style: TextStyle(color: Colors.grey.shade600)),
                        Text(relance.facture.objet,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${relance.resteAPayer.toStringAsFixed(2)} €",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      Text(
                        "Échéance: ${FormatUtils.date(relance.facture.dateEcheance)}",
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bouton relancer
                  TextButton.icon(
                    onPressed: () => _envoyerRelance(context, vm, relance),
                    icon: const Icon(Icons.email_rounded, size: 18),
                    label: const Text("Relancer"),
                    style: TextButton.styleFrom(foregroundColor: color),
                  ),
                  const SizedBox(width: 8),
                  // Bouton aperçu texte
                  TextButton.icon(
                    onPressed: () => _afficherTexteRelance(context, relance),
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text("Aperçu"),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ACTIONS ──

  Future<void> _envoyerRelance(
      BuildContext context, RelanceViewModel vm, RelanceInfo relance) async {
    final result = await vm.envoyerRelance(relance);

    if (!context.mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Relance envoyée pour ${relance.facture.numeroFacture}"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? "Erreur d'envoi"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _afficherTexteRelance(BuildContext context, RelanceInfo relance) {
    final texte = RelanceService.genererTexteRelance(relance);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Aperçu relance - ${_niveauLabel(relance.niveau)}"),
        content: SingleChildScrollView(
          child: SelectableText(texte, style: const TextStyle(fontSize: 14)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Fermer")),
        ],
      ),
    );
  }

  // ── HELPERS NIVEAU ──

  static Color _niveauColor(NiveauRelance? niveau) {
    switch (niveau) {
      case NiveauRelance.amiable:
        return Colors.orange;
      case NiveauRelance.ferme:
        return Colors.deepOrange;
      case NiveauRelance.miseEnDemeure:
        return Colors.red;
      case NiveauRelance.contentieux:
        return Colors.red.shade900;
      case null:
        return AppTheme.primary;
    }
  }

  static String _niveauLabel(NiveauRelance niveau) {
    switch (niveau) {
      case NiveauRelance.amiable:
        return "Amiable";
      case NiveauRelance.ferme:
        return "Ferme";
      case NiveauRelance.miseEnDemeure:
        return "Mise en demeure";
      case NiveauRelance.contentieux:
        return "Contentieux";
    }
  }

  static IconData _niveauIcon(NiveauRelance niveau) {
    switch (niveau) {
      case NiveauRelance.amiable:
        return Icons.info_outline_rounded;
      case NiveauRelance.ferme:
        return Icons.warning_amber_rounded;
      case NiveauRelance.miseEnDemeure:
        return Icons.gavel_rounded;
      case NiveauRelance.contentieux:
        return Icons.report_rounded;
    }
  }
}
