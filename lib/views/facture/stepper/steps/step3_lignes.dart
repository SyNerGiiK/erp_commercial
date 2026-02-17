import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:provider/provider.dart';

import '../../../../models/facture_model.dart';
import '../../../../viewmodels/entreprise_viewmodel.dart';
import '../../../../widgets/ligne_editor.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/article_selection_dialog.dart'; // ADDED
import '../../../../models/article_model.dart'; // ADDED
import '../../../../config/theme.dart'; // ADDED
import '../../../../utils/calculations_utils.dart';

class Step3Lignes extends StatelessWidget {
  final List<LigneFacture> lignes;
  final ValueChanged<List<LigneFacture>> onLignesChanged;

  final bool isSituation;

  const Step3Lignes({
    super.key,
    required this.lignes,
    required this.onLignesChanged,
    this.isSituation = false,
  });

  void _ajouterLigne(BuildContext context) {
    final isTvaApplicable =
        Provider.of<EntrepriseViewModel>(context, listen: false)
            .isTvaApplicable;

    final newList = List<LigneFacture>.from(lignes);
    newList.add(LigneFacture(
      description: "",
      quantite: Decimal.one,
      prixUnitaire: Decimal.zero,
      totalLigne: Decimal.zero,
      tauxTva: isTvaApplicable ? Decimal.fromInt(20) : Decimal.zero,
    ));
    onLignesChanged(newList);
  }

  void _updateLigne(int index, LigneFacture updated, bool isSituation) {
    final newList = List<LigneFacture>.from(lignes);

    // Recalcul total
    final total = CalculationsUtils.calculateTotalLigne(
      updated.quantite,
      updated.prixUnitaire,
      isSituation: isSituation,
      avancement: updated.avancement,
    );

    newList[index] = updated.copyWith(totalLigne: total);
    onLignesChanged(newList);
  }

  void _deleteLigne(int index) {
    final newList = List<LigneFacture>.from(lignes);
    newList.removeAt(index);
    onLignesChanged(newList);
  }

  void _ajouterLigneSpeciale(BuildContext context, String type) {
    final newList = List<LigneFacture>.from(lignes);
    newList.add(LigneFacture(
      description: "",
      quantite: Decimal.zero,
      prixUnitaire: Decimal.zero,
      totalLigne: Decimal.zero,
      type: type, // 'titre', 'sous-titre', 'texte', 'saut_page'
    ));
    onLignesChanged(newList);
  }

  Future<void> _importerArticle(BuildContext context) async {
    final isTvaApplicable =
        Provider.of<EntrepriseViewModel>(context, listen: false)
            .isTvaApplicable;

    final article = await showDialog<Article>(
      context: context,
      builder: (_) => const ArticleSelectionDialog(),
    );

    if (article != null) {
      final newList = List<LigneFacture>.from(lignes);
      newList.add(LigneFacture(
        description: article.designation,
        quantite: Decimal.one,
        prixUnitaire: article.prixUnitaire,
        totalLigne: article.prixUnitaire, // 1 * PU
        unite: article.unite,
        type: 'article',
        typeActivite: article.typeActivite,
        tauxTva: isTvaApplicable ? Decimal.fromInt(20) : Decimal.zero,
      ));
      onLignesChanged(newList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTvaApplicable =
        Provider.of<EntrepriseViewModel>(context).isTvaApplicable;

    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              // Header Row matching style
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Lignes de facture",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.add_circle,
                          size: 28, color: AppTheme.primary),
                      tooltip: "Ajouter...",
                      onSelected: (value) {
                        if (value == 'article') {
                          _ajouterLigne(context);
                        } else if (value == 'import') {
                          _importerArticle(context);
                        } else {
                          _ajouterLigneSpeciale(context, value);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'article',
                          child: ListTile(
                            leading: Icon(Icons.add, color: AppTheme.primary),
                            title: Text('Nouvelle ligne'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'import',
                          child: ListTile(
                            leading:
                                Icon(Icons.library_books, color: Colors.purple),
                            title: Text('Importer article/ouvrage'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'titre',
                          child: ListTile(
                            leading: Icon(Icons.title, color: Colors.black87),
                            title: Text('Titre de section'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'sous-titre',
                          child: ListTile(
                            leading:
                                Icon(Icons.short_text, color: Colors.black54),
                            title: Text('Sous-titre'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'texte',
                          child: ListTile(
                            leading: Icon(Icons.notes, color: Colors.grey),
                            title: Text('Texte / Commentaire'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'saut_page',
                          child: ListTile(
                            leading: Icon(Icons.insert_page_break,
                                color: Colors.red),
                            title: Text('Saut de page'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              lignes.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                          child: Text(
                              "Aucune ligne. Utilisez le bouton + pour commencer.")),
                    )
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: lignes.length,
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final newList = List<LigneFacture>.from(lignes);
                        final item = newList.removeAt(oldIndex);
                        newList.insert(newIndex, item);
                        onLignesChanged(newList);
                      },
                      itemBuilder: (context, index) {
                        final ligne = lignes[index];
                        return ReorderableDragStartListener(
                          key: ValueKey(ligne.uiKey),
                          index: index,
                          child: Card(
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
                              avancement: ligne.avancement,
                              tauxTva: ligne.tauxTva,
                              isSituation: isSituation,
                              showHandle: true,
                              showTva: isTvaApplicable,
                              onChanged: (desc, qte, pu, unite, type, gras,
                                  ital, soul, av, tva) {
                                _updateLigne(
                                    index,
                                    ligne.copyWith(
                                      description: desc,
                                      quantite: qte,
                                      prixUnitaire: pu,
                                      unite: unite,
                                      type: type,
                                      estGras: gras,
                                      estItalique: ital,
                                      estSouligne: soul,
                                      avancement: av,
                                      tauxTva: tva,
                                    ),
                                    isSituation);
                              },
                              onDelete: () => _deleteLigne(index),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
