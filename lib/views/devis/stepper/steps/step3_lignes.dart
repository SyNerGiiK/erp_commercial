import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../../models/devis_model.dart';
import '../../../../models/chiffrage_model.dart';
import '../../../../models/article_model.dart';
import '../../../../viewmodels/devis_viewmodel.dart';
import '../../../../viewmodels/article_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAiGenerating = false;
  String _recognizedText = "";

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

  Future<void> _showAitiseDialog() async {
    _recognizedText = "";
    final currentTextCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple),
              SizedBox(width: 8),
              Text("AITISE TON DEVIS"),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Décrivez les travaux à réaliser (ou dictez-les), l'I.A. s'occupera du reste."),
                const SizedBox(height: 16),
                TextField(
                  controller: currentTextCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText:
                        "Ex: Je veux refaire une salle de bain de 5m2, avec pose de baignoire...",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (!_isListening) {
                      bool available = await _speech.initialize(
                        onStatus: (status) {
                          if (status == 'done' || status == 'notListening') {
                            setDialogState(() => _isListening = false);
                          }
                        },
                      );
                      if (available) {
                        setDialogState(() => _isListening = true);
                        final previousText = currentTextCtrl.text.trim();
                        _speech.listen(
                          listenOptions: stt.SpeechListenOptions(
                            listenMode: stt.ListenMode.dictation,
                          ),
                          pauseFor: const Duration(seconds: 10),
                          onResult: (val) {
                            setDialogState(() {
                              final textToAppend = val.recognizedWords.trim();
                              _recognizedText = previousText.isEmpty
                                  ? textToAppend
                                  : "$previousText $textToAppend";
                              currentTextCtrl.text = _recognizedText;
                              currentTextCtrl.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: currentTextCtrl.text.length),
                              );
                            });
                          },
                        );
                      } else {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text("Micro non disponible")));
                      }
                    } else {
                      setDialogState(() => _isListening = false);
                      _speech.stop();
                    }
                  },
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  label: Text(_isListening
                      ? "Écoute en cours..."
                      : "Dicter vocalement"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red.shade50 : null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, currentTextCtrl.text);
              },
              child: const Text("Générer"),
            ),
          ],
        );
      }),
    ).then((prompt) async {
      if (prompt != null && prompt.toString().trim().isNotEmpty) {
        if (!mounted) return;
        setState(() => _isAiGenerating = true);
        final devisVM = Provider.of<DevisViewModel>(context, listen: false);
        final articleVM = Provider.of<ArticleViewModel>(context, listen: false);

        final catalog = articleVM.articles
            .map((a) => {
                  'designation': a.designation,
                  'unite': a.unite,
                  'prix_unitaire': a.prixUnitaire.toString(),
                  'type_activite': a.typeActivite
                })
            .toList();
        final catalogJSON = jsonEncode(catalog);

        final newAiLignes =
            await devisVM.generateAILignes(prompt.toString(), catalogJSON);
        if (!mounted) return;
        setState(() => _isAiGenerating = false);

        if (newAiLignes != null && newAiLignes.isNotEmpty) {
          final newList = List<LigneDevis>.from(widget.lignes);
          newList.addAll(newAiLignes);
          widget.onLignesChanged(newList);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Lignes générées par l\'I.A. avec succès !')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Erreur I.A. ou aucune ligne retournée.')));
        }
      }
    });
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
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showAitiseDialog,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("AITISE TON DEVIS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50,
                    foregroundColor: Colors.purple,
                  ),
                ),
                const Spacer(),
                if (_isAiGenerating)
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
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
        SizedBox(
          height: (widget.lignes.length * 120.0).clamp(100.0, 500.0),
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
