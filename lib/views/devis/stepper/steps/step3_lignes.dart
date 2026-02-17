import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:provider/provider.dart';

import '../../../../models/devis_model.dart';
import '../../../../models/chiffrage_model.dart';
import '../../../../models/article_model.dart';

import '../../../../widgets/ligne_editor.dart';
import '../../../../widgets/chiffrage_editor.dart';
import '../../../../widgets/rentabilite_card.dart';
import '../../../../widgets/article_selection_dialog.dart';
import '../../../../widgets/dialogs/matiere_dialog.dart';
import '../../../../viewmodels/entreprise_viewmodel.dart';
import '../../../../viewmodels/urssaf_viewmodel.dart'; // Correct Import
import '../../../../utils/calculations_utils.dart';

class DevisStep3Lignes extends StatefulWidget {
  final List<LigneDevis> lignes;
  final List<LigneChiffrage> chiffrage;
  final ValueChanged<List<LigneDevis>> onLignesChanged;
  final ValueChanged<List<LigneChiffrage>> onChiffrageChanged;
  final Decimal remiseTaux;

  const DevisStep3Lignes({
    super.key,
    required this.lignes,
    required this.chiffrage,
    required this.onLignesChanged,
    required this.onChiffrageChanged,
    required this.remiseTaux,
  });

  @override
  State<DevisStep3Lignes> createState() => _DevisStep3LignesState();
}

class _DevisStep3LignesState extends State<DevisStep3Lignes> {
  // --- ACTIONS LIGNES ---

  void _ajouterLigne() {
    final newList = List<LigneDevis>.from(widget.lignes);
    newList.add(LigneDevis(
      description: "",
      quantite: Decimal.one,
      prixUnitaire: Decimal.zero,
      totalLigne: Decimal.zero,
      type: 'article',
    ));
    widget.onLignesChanged(newList);
  }

  void _ajouterSection(String type) {
    // titre, sous-titre, saut_page, commentaire
    final newList = List<LigneDevis>.from(widget.lignes);
    String desc = "";
    if (type == 'titre') desc = "Nouvelle Section";
    if (type == 'sous-titre') desc = "Sous-section";

    newList.add(LigneDevis(
      description: desc,
      quantite: Decimal.zero,
      prixUnitaire: Decimal.zero,
      totalLigne: Decimal.zero,
      type: type,
    ));
    widget.onLignesChanged(newList);
  }

  Future<void> _importerArticle() async {
    final article = await showDialog<Article>(
        context: context, builder: (_) => const ArticleSelectionDialog());

    if (article != null) {
      final newLignes = List<LigneDevis>.from(widget.lignes);
      newLignes.add(LigneDevis(
        description: article.designation,
        quantite: Decimal.one,
        prixUnitaire: article.prixUnitaire,
        totalLigne: article.prixUnitaire,
        unite: article.unite,
        typeActivite: article.typeActivite,
        tauxTva: article.tauxTva,
      ));
      widget.onLignesChanged(newLignes);

      // Et on ajoute au chiffrage aussi !
      final newChiffrage = List<LigneChiffrage>.from(widget.chiffrage);
      newChiffrage.add(LigneChiffrage(
        designation: article.designation,
        quantite: Decimal.one,
        prixAchatUnitaire: article.prixAchat,
        prixVenteUnitaire: article.prixUnitaire,
        unite: article.unite,
      ));
      widget.onChiffrageChanged(newChiffrage);
    }
  }

  // --- ACTIONS CHIFFRAGE ---

  Future<void> _ajouterMatiere() async {
    final result = await showDialog<LigneChiffrage>(
      context: context,
      builder: (_) => const MatiereDialog(),
    );

    if (result != null) {
      final newList = List<LigneChiffrage>.from(widget.chiffrage);
      newList.add(result);
      widget.onChiffrageChanged(newList);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculs pour Rentabilité
    final totalHt =
        widget.lignes.fold(Decimal.zero, (s, l) => s + l.totalLigne);
    final remiseAmount =
        CalculationsUtils.calculateCharges(totalHt, widget.remiseTaux);
    final netCommercial = totalHt - remiseAmount;

    final totalAchat =
        widget.chiffrage.fold(Decimal.zero, (s, l) => s + l.totalAchat);

    // Get URSSAF Taux
    final urssafVM = Provider.of<UrssafViewModel>(context);
    final tauxUrssaf =
        urssafVM.config?.tauxMicroPrestationBIC ?? Decimal.parse('21.2');

    // Marge Calculations
    final charges = (netCommercial * tauxUrssaf) / Decimal.fromInt(100);
    final solde = netCommercial - totalAchat - charges.toDecimal();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue, // AppTheme.primary
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.description), text: "Devis Client"),
              Tab(icon: Icon(Icons.analytics), text: "Analyse & Marge"),
            ],
          ),
          SizedBox(
            height: 600,
            child: TabBarView(
              children: [
                // TAB 1: LIGNES CLIENT
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // MENU D'AJOUT
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _ajouterLigne,
                            icon: const Icon(Icons.add),
                            label: const Text("Article vide"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _importerArticle,
                            icon: const Icon(Icons.library_books),
                            label: const Text("Bibliothèque"),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.playlist_add),
                            tooltip: "Ajouter spécial...",
                            onSelected: _ajouterSection,
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'titre',
                                  child: Text("Titre de section")),
                              const PopupMenuItem(
                                  value: 'sous-titre',
                                  child: Text("Sous-titre")),
                              const PopupMenuItem(
                                  value: 'texte', child: Text("Commentaire")),
                              const PopupMenuItem(
                                  value: 'saut_page',
                                  child: Text("Saut de page")),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.lignes.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final newList = List<LigneDevis>.from(widget.lignes);
                          final item = newList.removeAt(oldIndex);
                          newList.insert(newIndex, item);
                          widget.onLignesChanged(newList);
                        },
                        itemBuilder: (context, index) {
                          final ligne = widget.lignes[index];
                          return Card(
                            key: ValueKey("ligne_$index"),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: LigneEditor(
                              description: ligne.description,
                              quantite: ligne.quantite,
                              prixUnitaire: ligne.prixUnitaire,
                              unite: ligne.unite,
                              type: ligne.type,
                              estGras: ligne.estGras,
                              estItalique: ligne.estItalique,
                              estSouligne: ligne.estSouligne,
                              tauxTva: ligne.tauxTva,
                              showTva: Provider.of<EntrepriseViewModel>(context)
                                  .isTvaApplicable,
                              showHandle: true,
                              onChanged: (desc, qte, pu, unite, type, gras,
                                  ital, soul, av, tva) {
                                final newList =
                                    List<LigneDevis>.from(widget.lignes);
                                newList[index] = ligne.copyWith(
                                  description: desc,
                                  quantite: qte,
                                  prixUnitaire: pu,
                                  totalLigne:
                                      CalculationsUtils.calculateTotalLigne(
                                          qte, pu),
                                  unite: unite,
                                  type: type,
                                  estGras: gras,
                                  estItalique: ital,
                                  estSouligne: soul,
                                  tauxTva: tva,
                                );
                                widget.onLignesChanged(newList);
                              },
                              onDelete: () {
                                final newList =
                                    List<LigneDevis>.from(widget.lignes);
                                newList.removeAt(index);
                                widget.onLignesChanged(newList);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // TAB 2: CHIFFRAGE & RENTABILITÉ
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      RentabiliteCard(
                        type: RentabiliteType.chantier,
                        ca: netCommercial,
                        cout: totalAchat,
                        charges: charges.toDecimal(),
                        solde: solde,
                        tauxUrssaf: tauxUrssaf,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Détail des coûts (Matières & MO)",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: _ajouterMatiere,
                            icon: const Icon(Icons.add),
                            label: const Text("Ajouter Coût"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.chiffrage.length,
                        itemBuilder: (context, index) {
                          final ligne = widget.chiffrage[index];
                          return Card(
                            child: ChiffrageEditor(
                              description: ligne.designation,
                              quantite: ligne.quantite,
                              prixAchat: ligne.prixAchatUnitaire,
                              prixVente: ligne.prixVenteUnitaire,
                              unite: ligne.unite,
                              tauxUrssaf: tauxUrssaf,
                              onChanged: (des, qte, pa, pv, un) {
                                final newList =
                                    List<LigneChiffrage>.from(widget.chiffrage);
                                newList[index] = ligne.copyWith(
                                  designation: des,
                                  quantite: qte,
                                  prixAchatUnitaire: pa,
                                  prixVenteUnitaire: pv,
                                  unite: un,
                                );
                                widget.onChiffrageChanged(newList);
                              },
                              onDelete: () {
                                final newList =
                                    List<LigneChiffrage>.from(widget.chiffrage);
                                newList.removeAt(index);
                                widget.onChiffrageChanged(newList);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
