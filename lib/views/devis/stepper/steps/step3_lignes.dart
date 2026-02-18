import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:provider/provider.dart';

import '../../../../models/devis_model.dart';
import '../../../../models/chiffrage_model.dart';
import '../../../../models/article_model.dart';

import '../../../../widgets/ligne_editor.dart';
import '../../../../widgets/article_selection_dialog.dart';
import '../../../../viewmodels/entreprise_viewmodel.dart';
import '../../../../utils/calculations_utils.dart';

class DevisStep3Lignes extends StatefulWidget {
  final List<LigneDevis> lignes;
  final List<LigneChiffrage> chiffrage;
  final ValueChanged<List<LigneDevis>> onLignesChanged;
  final ValueChanged<List<LigneChiffrage>> onChiffrageChanged;
  final Decimal remiseTaux;
  final bool readOnly;

  const DevisStep3Lignes({
    super.key,
    required this.lignes,
    required this.chiffrage,
    required this.onLignesChanged,
    required this.onChiffrageChanged,
    required this.remiseTaux,
    this.readOnly = false,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // BANNER LECTURE SEULE
        if (widget.readOnly)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lecture seule — Ce devis est verrouillé (signé ou annulé).",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

        // MENU D'AJOUT
        if (!widget.readOnly)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
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
                        value: 'titre', child: Text("Titre de section")),
                    const PopupMenuItem(
                        value: 'sous-titre', child: Text("Sous-titre")),
                    const PopupMenuItem(
                        value: 'texte', child: Text("Commentaire")),
                    const PopupMenuItem(
                        value: 'saut_page', child: Text("Saut de page")),
                  ],
                ),
              ],
            ),
          ),

        // LIGNES
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  showTva:
                      Provider.of<EntrepriseViewModel>(context).isTvaApplicable,
                  showHandle: !widget.readOnly,
                  readOnly: widget.readOnly,
                  onChanged: widget.readOnly
                      ? null
                      : (desc, qte, pu, unite, type, gras, ital, soul, av,
                          tva) {
                          final newList = List<LigneDevis>.from(widget.lignes);
                          newList[index] = ligne.copyWith(
                            description: desc,
                            quantite: qte,
                            prixUnitaire: pu,
                            totalLigne:
                                CalculationsUtils.calculateTotalLigne(qte, pu),
                            unite: unite,
                            type: type,
                            estGras: gras,
                            estItalique: ital,
                            estSouligne: soul,
                            tauxTva: tva,
                          );
                          widget.onLignesChanged(newList);
                        },
                  onDelete: widget.readOnly
                      ? null
                      : () {
                          final newList = List<LigneDevis>.from(widget.lignes);
                          newList.removeAt(index);
                          widget.onLignesChanged(newList);
                        },
                ),
              );
            },
          ),
        ),

        // Mini résumé rentabilité (si chiffrage renseigné et pas mode discret)
        if (widget.chiffrage.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(children: [
              const Icon(Icons.analytics, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                "${widget.chiffrage.length} coût(s) renseigné(s) — Voir la vue Rentabilité pour le détail",
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ]),
          ),
      ],
    );
  }
}
