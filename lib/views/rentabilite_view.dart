import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';

import '../config/theme.dart';
import '../models/devis_model.dart';
import '../models/chiffrage_model.dart';
import '../viewmodels/rentabilite_viewmodel.dart';
import '../viewmodels/urssaf_viewmodel.dart';
import '../utils/calculations_utils.dart';
import '../utils/format_utils.dart';
import '../widgets/base_screen.dart';
import '../widgets/rentabilite_card.dart';
import '../widgets/chiffrage_editor.dart';
import '../widgets/dialogs/chiffrage_dialog.dart';

/// Vue "Analyse & Rentabilité" revampée — Smart Progress Billing.
///
/// Architecture en 2 panneaux :
/// - Gauche : Navigation arborescente Devis → LigneDevis (avec avancement)
/// - Droite : Coûts internes (LigneChiffrage) avec toggle matériel / slider MO
class RentabiliteView extends StatefulWidget {
  const RentabiliteView({super.key});

  @override
  State<RentabiliteView> createState() => _RentabiliteViewState();
}

class _RentabiliteViewState extends State<RentabiliteView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentabiliteViewModel>().loadDevis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentabiliteViewModel>();

    return BaseScreen(
      menuIndex: 8,
      title: "Analyse & Rentabilité",
      child: vm.isLoading && vm.devisList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // === PANNEAU GAUCHE : Navigation arborescente ===
                SizedBox(
                  width: 380,
                  child: _LeftPanel(vm: vm),
                ),
                const VerticalDivider(width: 1),

                // === PANNEAU DROIT : Détail & Tracking ===
                Expanded(
                  child: _RightPanel(vm: vm),
                ),
              ],
            ),
    );
  }
}

// =============================================================================
// PANNEAU GAUCHE — Navigation Devis > Lignes
// =============================================================================

class _LeftPanel extends StatelessWidget {
  final RentabiliteViewModel vm;
  const _LeftPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête avec avancement global
        _buildHeader(context),
        const Divider(height: 1),
        // Liste des devis avec expansion
        Expanded(
          child: vm.devisList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: vm.devisList.length,
                  itemBuilder: (_, i) =>
                      _DevisTreeTile(devis: vm.devisList[i], vm: vm),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasSelection = vm.selectedDevis != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.08),
            AppTheme.primary.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree, size: 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text("${vm.devisList.length} devis actifs",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              if (vm.isDirty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.2),
                    borderRadius: AppTheme.borderRadiusSmall,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5)),
                      SizedBox(width: 6),
                      Text("Sauvegarde...",
                          style:
                              TextStyle(fontSize: 10, color: AppTheme.warning)),
                    ],
                  ),
                ),
            ],
          ),
          if (hasSelection) ...[
            const SizedBox(height: 8),
            _AvancementGlobalBar(
              avancement: vm.avancementGlobal,
              label:
                  "Avancement global : ${vm.avancementGlobal.toDouble().toStringAsFixed(1)}%",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text("Aucun devis actif", style: TextStyle(color: Colors.grey)),
          Text("Créez un devis pour commencer l'analyse",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Tuile d'un devis dans l'arbre de navigation, expansible vers ses lignes
class _DevisTreeTile extends StatelessWidget {
  final Devis devis;
  final RentabiliteViewModel vm;

  const _DevisTreeTile({required this.devis, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.selectedDevis?.id == devis.id;
    final isExpanded = vm.expandedDevisIds.contains(devis.id);
    final hasChiffrage = devis.chiffrage.isNotEmpty;

    final lignesArticle = devis.lignes
        .where((l) =>
            !['titre', 'sous-titre', 'texte', 'saut_page'].contains(l.type))
        .toList();

    return Column(
      children: [
        // Devis header
        InkWell(
          onTap: () {
            if (devis.id != null) {
              vm.toggleDevisExpanded(devis.id!);
              if (!isSelected) {
                vm.selectDevis(devis);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppTheme.primary.withValues(alpha: 0.08) : null,
              border: Border(
                left: BorderSide(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                // Icône état
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isSelected ? AppTheme.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  hasChiffrage
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: hasChiffrage ? AppTheme.accent : Colors.grey.shade400,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        devis.numeroDevis.isNotEmpty
                            ? devis.numeroDevis
                            : "Brouillon",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color:
                              isSelected ? AppTheme.primary : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        devis.objet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ),
                Text(
                  FormatUtils.currency(devis.totalHt),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        // Lignes du devis (expandables)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: lignesArticle.map((ligne) {
              return _LigneDevisTile(
                ligne: ligne,
                vm: vm,
                avancement: vm.avancements[ligne.id] ?? Decimal.zero,
              );
            }).toList(),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        const Divider(height: 1, indent: 16),
      ],
    );
  }
}

/// Tuile d'une ligne de devis dans l'arbre — avec barre d'avancement
class _LigneDevisTile extends StatelessWidget {
  final LigneDevis ligne;
  final RentabiliteViewModel vm;
  final Decimal avancement;

  const _LigneDevisTile({
    required this.ligne,
    required this.vm,
    required this.avancement,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.selectedLigneDevis?.id == ligne.id;
    final isComplete = avancement >= Decimal.fromInt(100);
    final prixTotal = ligne.quantite * ligne.prixUnitaire;

    return InkWell(
      onTap: () => vm.selectLigneDevis(ligne),
      child: Container(
        padding: const EdgeInsets.only(left: 56, right: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primarySoft : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppTheme.secondary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Badge de complétion
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, size: 12, color: Colors.white),
                  )
                else
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ligne.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isComplete ? AppTheme.textLight : AppTheme.textDark,
                      decoration:
                          isComplete ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  FormatUtils.currency(prixTotal),
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textMedium),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Barre d'avancement
            Row(
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: avancement.toDouble() / 100.0,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isComplete ? AppTheme.accent : AppTheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${avancement.toDouble().toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isComplete ? AppTheme.accent : AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre d'avancement global en haut du panneau gauche
class _AvancementGlobalBar extends StatelessWidget {
  final Decimal avancement;
  final String label;

  const _AvancementGlobalBar({required this.avancement, required this.label});

  @override
  Widget build(BuildContext context) {
    final isComplete = avancement >= Decimal.fromInt(100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isComplete ? AppTheme.accent : AppTheme.textMedium,
            )),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: avancement.toDouble() / 100.0,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? AppTheme.accent : AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PANNEAU DROIT — Détail des coûts + Tracking
// =============================================================================

class _RightPanel extends StatelessWidget {
  final RentabiliteViewModel vm;
  const _RightPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    // Aucun devis sélectionné
    if (vm.selectedDevis == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text("Sélectionnez un devis pour analyser",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Devis sélectionné mais pas de ligne sélectionnée
    if (vm.selectedLigneDevis == null) {
      return _buildDevisOverview(context);
    }

    // Ligne sélectionnée → afficher les coûts liés
    return _buildLigneDetail(context);
  }

  /// Vue d'ensemble du devis (rentabilité + résumé)
  Widget _buildDevisOverview(BuildContext context) {
    final devis = vm.selectedDevis!;
    final urssafVM = Provider.of<UrssafViewModel>(context);
    final config = urssafVM.config;
    final tauxUrssaf = config?.tauxMicroPrestationBIC ?? Decimal.parse('21.2');

    final totalHt = devis.lignes.fold(Decimal.zero, (s, l) => s + l.totalLigne);
    final remiseAmount =
        CalculationsUtils.calculateCharges(totalHt, devis.remiseTaux);
    final netCommercial = totalHt - remiseAmount;

    final totalAchat =
        vm.chiffrages.fold(Decimal.zero, (Decimal s, l) => s + l.totalAchat);

    final ventilation = CalculationsUtils.ventilerCA(
      lignes: devis.lignes,
      remiseTaux: devis.remiseTaux,
    );

    Decimal chargesTotal;
    if (config != null && ventilation.isMixte) {
      final cotisations = config.calculerCotisations(
        ventilation.caVente,
        ventilation.caPrestaBIC,
        ventilation.caPrestaBNC,
      );
      chargesTotal = cotisations['total'] ?? Decimal.zero;
    } else {
      chargesTotal =
          (netCommercial * tauxUrssaf / Decimal.fromInt(100)).toDecimal();
    }

    final solde = netCommercial - totalAchat - chargesTotal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(devis.numeroDevis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(devis.objet,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          RentabiliteCard(
            type: RentabiliteType.chantier,
            ca: netCommercial,
            cout: totalAchat,
            charges: chargesTotal,
            solde: solde,
            tauxUrssaf: tauxUrssaf,
          ),
          const SizedBox(height: 20),

          // Résumé avancement par ligne
          const Text("Avancement par ligne du devis",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Cliquez sur une ligne dans le panneau de gauche pour tracker "
            "ses coûts (matériaux et main d'œuvre).",
            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
          const SizedBox(height: 16),

          // Table récapitulative
          ...vm.lignesAvancement.map((la) => _buildLigneAvancementCard(la)),
        ],
      ),
    );
  }

  Widget _buildLigneAvancementCard(LigneDevisAvancement la) {
    final isComplete = la.isComplete;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (isComplete)
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 20)
            else
              Icon(Icons.pending, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(la.ligne.description,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: la.avancement.toDouble() / 100.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isComplete ? AppTheme.accent : AppTheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${la.avancement.toDouble().toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isComplete ? AppTheme.accent : AppTheme.textDark,
                    )),
                Text(
                  "${FormatUtils.currency(la.valeurRealisee)} / ${FormatUtils.currency(la.prixTotal)}",
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text("${la.chiffrages.length}",
                style:
                    const TextStyle(fontSize: 11, color: AppTheme.textLight)),
            const Icon(Icons.layers, size: 14, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  /// Détail des coûts pour une ligne de devis sélectionnée
  Widget _buildLigneDetail(BuildContext context) {
    final ligne = vm.selectedLigneDevis!;
    final chiffrages = vm.chiffragesForSelectedLigne;
    final avancement = vm.avancements[ligne.id] ?? Decimal.zero;
    final prixTotal = ligne.quantite * ligne.prixUnitaire;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              InkWell(
                onTap: () => vm.selectLigneDevis(
                    // Hack: désélectionner en passant par selectDevis
                    vm.selectedDevis!.lignes.first),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.selectedDevis!.numeroDevis,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight),
                    ),
                    Text(
                      ligne.description,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Résumé avancement de cette ligne
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: avancement >= Decimal.fromInt(100)
                    ? [
                        AppTheme.accentSoft,
                        AppTheme.accent.withValues(alpha: 0.1)
                      ]
                    : [
                        AppTheme.primarySoft,
                        AppTheme.primary.withValues(alpha: 0.05)
                      ],
              ),
              borderRadius: AppTheme.borderRadiusMedium,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Avancement de la ligne",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      "${avancement.toDouble().toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: avancement >= Decimal.fromInt(100)
                            ? AppTheme.accent
                            : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: avancement.toDouble() / 100.0,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      avancement >= Decimal.fromInt(100)
                          ? AppTheme.accent
                          : AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Prix total : ${FormatUtils.currency(prixTotal)}",
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMedium)),
                    Text("${chiffrages.length} coûts rattachés",
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMedium)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // En-tête coûts + bouton ajout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Coûts internes (Matériaux & MO)",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _ajouterCout(context, ligne),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Ajouter Coût"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Liste des coûts
          if (chiffrages.isEmpty)
            _buildEmptyCosts()
          else
            ...chiffrages.map((c) => _ChiffrageTrackingCard(
                  chiffrage: c,
                  vm: vm,
                )),
        ],
      ),
    );
  }

  Widget _buildEmptyCosts() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.layers_clear, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text("Aucun coût rattaché à cette ligne.",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          const Text(
            "Ajoutez vos matériaux et heures de main d'œuvre pour calculer\n"
            "automatiquement l'avancement de cette ligne.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _ajouterCout(BuildContext context, LigneDevis ligne) async {
    final result = await showDialog<LigneChiffrage>(
      context: context,
      builder: (_) => ChiffrageDialog(
        devisId: vm.selectedDevis!.id!,
        ligneDevisId: ligne.id,
        prixTotalLigne: ligne.quantite * ligne.prixUnitaire,
      ),
    );
    if (result != null) {
      vm.ajouterChiffrage(result);
    }
  }
}

// =============================================================================
// CARTE DE TRACKING D'UN COÛT (Matériel toggle / MO slider)
// =============================================================================

class _ChiffrageTrackingCard extends StatelessWidget {
  final LigneChiffrage chiffrage;
  final RentabiliteViewModel vm;

  const _ChiffrageTrackingCard({
    required this.chiffrage,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final isMateriel = chiffrage.typeChiffrage == TypeChiffrage.materiel;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation:
          chiffrage.estAchete || chiffrage.avancementMo > Decimal.zero ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.borderRadiusMedium,
        side: BorderSide(
          color: _getBorderColor(),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : type badge + désignation + supprimer
            Row(
              children: [
                _buildTypeBadge(isMateriel),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chiffrage.designation,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        "${FormatUtils.quantity(chiffrage.quantite)} ${chiffrage.unite} × ${FormatUtils.currency(chiffrage.prixAchatUnitaire)}",
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ),
                // Valeur réalisée
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FormatUtils.currency(chiffrage.valeurRealisee),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: chiffrage.valeurRealisee > Decimal.zero
                            ? AppTheme.accent
                            : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      "/ ${FormatUtils.currency(chiffrage.prixVenteInterne)}",
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textLight),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.grey),
                  onPressed: () {
                    if (chiffrage.id != null) {
                      vm.supprimerChiffrage(chiffrage.id!);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Zone de tracking selon le type
            if (isMateriel) _buildMaterielTracker() else _buildMoTracker(),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (chiffrage.typeChiffrage == TypeChiffrage.materiel) {
      return chiffrage.estAchete
          ? AppTheme.accent.withValues(alpha: 0.5)
          : Colors.grey.shade200;
    } else {
      final pct = chiffrage.avancementMo.toDouble();
      if (pct >= 100) return AppTheme.accent.withValues(alpha: 0.5);
      if (pct > 0) return AppTheme.secondary.withValues(alpha: 0.3);
      return Colors.grey.shade200;
    }
  }

  Widget _buildTypeBadge(bool isMateriel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMateriel
            ? Colors.orange.withValues(alpha: 0.15)
            : Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMateriel ? Icons.inventory_2 : Icons.engineering,
            size: 14,
            color: isMateriel ? Colors.orange.shade700 : Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isMateriel ? "MAT" : "MO",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isMateriel ? Colors.orange.shade700 : Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle matériel réceptionné (binaire)
  Widget _buildMaterielTracker() {
    return InkWell(
      onTap: () {
        if (chiffrage.id != null) {
          vm.toggleEstAchete(chiffrage.id!);
        }
      },
      borderRadius: AppTheme.borderRadiusSmall,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              chiffrage.estAchete ? AppTheme.accentSoft : Colors.grey.shade50,
          borderRadius: AppTheme.borderRadiusSmall,
          border: Border.all(
            color: chiffrage.estAchete ? AppTheme.accent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: chiffrage.estAchete
                  ? const Icon(Icons.check_box,
                      color: AppTheme.accent, key: ValueKey('checked'))
                  : Icon(Icons.check_box_outline_blank,
                      color: Colors.grey.shade400,
                      key: const ValueKey('unchecked')),
            ),
            const SizedBox(width: 10),
            Text(
              chiffrage.estAchete
                  ? "Matériel réceptionné"
                  : "Matériel non réceptionné",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color:
                    chiffrage.estAchete ? AppTheme.accent : AppTheme.textLight,
              ),
            ),
            const Spacer(),
            Text(
              chiffrage.estAchete ? "100%" : "0%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    chiffrage.estAchete ? AppTheme.accent : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Slider d'avancement Main d'Œuvre (0–100%)
  Widget _buildMoTracker() {
    final pct = chiffrage.avancementMo.toDouble();
    final isComplete = pct >= 100;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Avancement main d'œuvre",
              style: TextStyle(
                fontSize: 12,
                color: isComplete ? AppTheme.accent : AppTheme.textMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isComplete ? AppTheme.accentSoft : AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${pct.toStringAsFixed(0)}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isComplete ? AppTheme.accent : AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: isComplete ? AppTheme.accent : AppTheme.primary,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: isComplete ? AppTheme.accent : AppTheme.primary,
            overlayColor: (isComplete ? AppTheme.accent : AppTheme.primary)
                .withValues(alpha: 0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: pct.clamp(0, 100),
            min: 0,
            max: 100,
            divisions: 20,
            label: "${pct.toStringAsFixed(0)}%",
            onChanged: (value) {
              if (chiffrage.id != null) {
                vm.updateAvancementMo(
                  chiffrage.id!,
                  Decimal.parse(value.toStringAsFixed(0)),
                );
              }
            },
          ),
        ),
        // Paliers rapides
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [0, 25, 50, 75, 100].map((p) {
            final isActive = pct >= p;
            return InkWell(
              onTap: () {
                if (chiffrage.id != null) {
                  vm.updateAvancementMo(
                    chiffrage.id!,
                    Decimal.fromInt(p),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$p%",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? AppTheme.primary : AppTheme.textLight,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
