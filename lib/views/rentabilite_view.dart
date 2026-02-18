import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';

import '../config/theme.dart';
import '../models/devis_model.dart';
import '../models/chiffrage_model.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/urssaf_viewmodel.dart';
import '../utils/calculations_utils.dart';
import '../utils/format_utils.dart';
import '../widgets/base_screen.dart';
import '../widgets/rentabilite_card.dart';
import '../widgets/chiffrage_editor.dart';
import '../widgets/dialogs/matiere_dialog.dart';

/// Vue autonome d'analyse de rentabilité.
/// Affiche la liste des devis (sélection) puis le détail coûts/marges
/// dans un split view.
class RentabiliteView extends StatefulWidget {
  const RentabiliteView({super.key});

  @override
  State<RentabiliteView> createState() => _RentabiliteViewState();
}

class _RentabiliteViewState extends State<RentabiliteView> {
  Devis? _selectedDevis;
  List<LigneChiffrage> _chiffrage = [];
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDevis());
  }

  Future<void> _loadDevis() async {
    final vm = Provider.of<DevisViewModel>(context, listen: false);
    await vm.fetchDevis();
  }

  void _selectDevis(Devis devis) {
    setState(() {
      _selectedDevis = devis;
      _chiffrage = List<LigneChiffrage>.from(devis.chiffrage);
      _dirty = false;
    });
  }

  Future<void> _ajouterCout() async {
    final result = await showDialog<LigneChiffrage>(
      context: context,
      builder: (_) => const MatiereDialog(),
    );
    if (result != null) {
      setState(() {
        _chiffrage.add(result);
        _dirty = true;
      });
    }
  }

  Future<void> _sauvegarder() async {
    if (_selectedDevis == null) return;

    final vm = Provider.of<DevisViewModel>(context, listen: false);
    final updated = _selectedDevis!.copyWith(chiffrage: _chiffrage);

    await vm.updateDevis(updated);
    if (!mounted) return;

    setState(() {
      _selectedDevis = updated;
      _dirty = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Chiffrage sauvegardé !")));
  }

  @override
  Widget build(BuildContext context) {
    final devisVM = context.watch<DevisViewModel>();
    final devisList = devisVM.devis;

    return BaseScreen(
      menuIndex: 8,
      title: "Analyse & Rentabilité",
      child: devisVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // === PANNEAU GAUCHE : Liste Devis ===
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: AppTheme.primary.withValues(alpha: 0.05),
                        child: Row(children: [
                          const Icon(Icons.analytics, size: 20),
                          const SizedBox(width: 8),
                          Text("${devisList.length} devis",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: devisList.length,
                          itemBuilder: (_, index) {
                            final d = devisList[index];
                            final isSelected = _selectedDevis?.id == d.id;
                            final hasChiffrage = d.chiffrage.isNotEmpty;

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor:
                                  AppTheme.primary.withValues(alpha: 0.1),
                              leading: Icon(
                                hasChiffrage
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: hasChiffrage
                                    ? Colors.green
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                              title: Text(d.numeroDevis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              subtitle: Text(
                                d.objet,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                FormatUtils.currency(d.totalHt),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              onTap: () => _selectDevis(d),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),

                // === PANNEAU DROIT : Détail Rentabilité ===
                Expanded(
                  child: _selectedDevis == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text("Sélectionnez un devis pour analyser",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : _buildAnalysePanel(),
                ),
              ],
            ),
    );
  }

  Widget _buildAnalysePanel() {
    final devis = _selectedDevis!;
    final urssafVM = Provider.of<UrssafViewModel>(context);
    final config = urssafVM.config;
    final tauxUrssaf = config?.tauxMicroPrestationBIC ?? Decimal.parse('21.2');

    final totalHt = devis.lignes.fold(Decimal.zero, (s, l) => s + l.totalLigne);
    final remiseAmount =
        CalculationsUtils.calculateCharges(totalHt, devis.remiseTaux);
    final netCommercial = totalHt - remiseAmount;

    final totalAchat =
        _chiffrage.fold(Decimal.zero, (s, l) => s + l.totalAchat);

    // Ventilation URSSAF BIC/BNC
    final ventilation = CalculationsUtils.ventilerCA(
      lignes: devis.lignes,
      remiseTaux: devis.remiseTaux,
    );

    // Charges ventilées
    Decimal chargesTotal;
    Map<String, Decimal>? cotisations;
    if (config != null && ventilation.isMixte) {
      cotisations = config.calculerCotisations(
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
          // En-tête devis
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(devis.numeroDevis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(devis.objet,
                        style: const TextStyle(color: Colors.grey)),
                  ]),
            ),
            if (_dirty)
              ElevatedButton.icon(
                onPressed: _sauvegarder,
                icon: const Icon(Icons.save, size: 18),
                label: const Text("Sauvegarder"),
              ),
          ]),
          const SizedBox(height: 20),

          // Carte Rentabilité
          RentabiliteCard(
            type: RentabiliteType.chantier,
            ca: netCommercial,
            cout: totalAchat,
            charges: chargesTotal,
            solde: solde,
            tauxUrssaf: tauxUrssaf,
          ),
          const SizedBox(height: 16),

          // Ventilation URSSAF détaillée
          if (ventilation.isMixte) ...[
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.pie_chart, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Ventilation URSSAF BIC/BNC",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 12),
                    _buildVentilationRow("Vente (BIC)", ventilation.caVente,
                        config?.tauxMicroVente ?? Decimal.parse('12.3')),
                    _buildVentilationRow(
                        "Prestation BIC",
                        ventilation.caPrestaBIC,
                        config?.tauxMicroPrestationBIC ??
                            Decimal.parse('21.2')),
                    _buildVentilationRow(
                        "Prestation BNC",
                        ventilation.caPrestaBNC,
                        config?.tauxMicroPrestationBNC ??
                            Decimal.parse('24.6')),
                    const Divider(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total cotisations",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(FormatUtils.currency(chargesTotal),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                    if (cotisations != null && cotisations['cfp'] != null)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("dont CFP",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(FormatUtils.currency(cotisations['cfp']!),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Titre + bouton ajout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Détail des coûts (Matières & MO)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _ajouterCout,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Ajouter Coût"),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Liste chiffrage
          if (_chiffrage.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.center,
              child: Column(children: [
                Icon(Icons.info_outline, size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                const Text("Aucun coût renseigné pour ce devis.",
                    style: TextStyle(color: Colors.grey)),
                const Text("Ajoutez vos achats matière et main d'œuvre.",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _chiffrage.length,
              itemBuilder: (_, index) {
                final ligne = _chiffrage[index];
                return Card(
                  child: ChiffrageEditor(
                    description: ligne.designation,
                    quantite: ligne.quantite,
                    prixAchat: ligne.prixAchatUnitaire,
                    prixVente: ligne.prixVenteUnitaire,
                    unite: ligne.unite,
                    tauxUrssaf: tauxUrssaf,
                    onChanged: (des, qte, pa, pv, un) {
                      setState(() {
                        _chiffrage[index] = ligne.copyWith(
                          designation: des,
                          quantite: qte,
                          prixAchatUnitaire: pa,
                          prixVenteUnitaire: pv,
                          unite: un,
                        );
                        _dirty = true;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        _chiffrage.removeAt(index);
                        _dirty = true;
                      });
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVentilationRow(String label, Decimal base, Decimal taux) {
    if (base == Decimal.zero) return const SizedBox.shrink();
    final cotis = (base * taux / Decimal.fromInt(100)).toDecimal();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(flex: 3, child: Text(label)),
        Expanded(
            flex: 2,
            child:
                Text(FormatUtils.currency(base), textAlign: TextAlign.right)),
        Expanded(
            child: Text("${taux.toStringAsFixed(1)}%",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey))),
        Expanded(
            flex: 2,
            child: Text(FormatUtils.currency(cotis),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
