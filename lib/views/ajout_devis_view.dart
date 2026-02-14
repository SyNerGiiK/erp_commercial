import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart'; // Added Import

import '../config/theme.dart';
import '../config/supabase_config.dart';
import '../models/devis_model.dart';
import '../models/article_model.dart';
import '../models/client_model.dart';
import '../models/chiffrage_model.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart'; // Added Import

// Services
import '../services/pdf_service.dart';

// Widgets
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart'; // Import ajouté
import '../widgets/custom_text_field.dart';
import '../widgets/client_selection_dialog.dart';
import '../widgets/article_selection_dialog.dart';
import '../widgets/ligne_editor.dart';

// Utils
import '../utils/format_utils.dart';
import '../utils/calculations_utils.dart';

class AjoutDevisView extends StatefulWidget {
  final String? id;
  final Devis? devisAModifier;

  const AjoutDevisView({super.key, this.id, this.devisAModifier});

  @override
  State<AjoutDevisView> createState() => _AjoutDevisViewState();
}

class _AjoutDevisViewState extends State<AjoutDevisView> {
  final _formKey = GlobalKey<FormState>();

  // Champs Infos Générales
  late TextEditingController _numeroCtrl;
  late TextEditingController _objetCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _conditionsCtrl;

  // Client
  Client? _selectedClient;

  // Dates
  DateTime _dateEmission = DateTime.now();
  DateTime _dateValidite = DateTime.now().add(const Duration(days: 30));

  // Listes
  List<LigneDevis> _lignes = [];
  List<LigneChiffrage> _chiffrage = [];

  // Totaux & Options
  Decimal _remiseTaux = Decimal.zero;
  // _acompteMontant est maintenant calculé dynamiquement
  Decimal get _acompteMontant =>
      ((_netCommercial * _acomptePercentage) / Decimal.fromInt(100))
          .toDecimal();
  Decimal _acomptePercentage = Decimal.zero; // Nouveau state pour le %

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final d = widget.devisAModifier;
    if (d != null) {
      _numeroCtrl = TextEditingController(text: d.numeroDevis);
      _objetCtrl = TextEditingController(text: d.objet);
      _notesCtrl = TextEditingController(text: d.notesPubliques ?? "");
      _conditionsCtrl = TextEditingController(text: d.conditionsReglement);
      _dateEmission = d.dateEmission;
      _dateValidite = d.dateValidite;
      _lignes = List.from(d.lignes);
      _chiffrage = List.from(d.chiffrage);
      _remiseTaux = d.remiseTaux;
      // _acompteMontant is now computed, so we don't assign it.
      // We calculate percentage from d.acompteMontant and d.totalHt
      // Reverse calc percentage
      if (d.totalHt > Decimal.zero) {
        // On base le % sur le Net Commercial (HT - Remise)
        final net = d.totalHt -
            ((d.totalHt * d.remiseTaux) / Decimal.fromInt(100)).toDecimal();
        if (net > Decimal.zero) {
          _acomptePercentage =
              CalculationsUtils.calculateTauxFromMontant(net, _acompteMontant);
        }
      }

      // Charger le client si on a l'ID
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clientVM = Provider.of<ClientViewModel>(context, listen: false);
        try {
          final client = clientVM.clients.firstWhere((c) => c.id == d.clientId);
          setState(() => _selectedClient = client);
        } catch (_) {
          // Client non trouvé (peut-être supprimé ou liste non chargée)
          // On ne fait rien, l'utilisateur devra resélectionner si besoin
        }
      });
    } else {
      _numeroCtrl = TextEditingController(text: "Brouillon");
      _objetCtrl = TextEditingController();
      _notesCtrl = TextEditingController();
      _conditionsCtrl = TextEditingController(text: "Paiement à réception");
    }
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _objetCtrl.dispose();
    _notesCtrl.dispose();
    _conditionsCtrl.dispose();
    super.dispose();
  }

  // --- CALCULS ---

  Decimal get _totalHT =>
      _lignes.fold(Decimal.zero, (sum, l) => sum + l.totalLigne);

  Decimal get _totalRemise {
    // CORRECTION RATIONAL : .toDecimal() obligatoire après une division
    return ((_totalHT * _remiseTaux) / Decimal.fromInt(100)).toDecimal();
  }

  Decimal get _netCommercial => _totalHT - _totalRemise;

  // --- ACTIONS ---

  Future<void> _selectionnerClient() async {
    final client = await showDialog<Client>(
        context: context, builder: (_) => const ClientSelectionDialog());

    // Async Safety
    if (!mounted) return;

    if (client != null) {
      setState(() => _selectedClient = client);
    }
  }

  void _ajouterLigne() {
    setState(() {
      _lignes.add(LigneDevis(
        description: "",
        quantite: Decimal.one,
        prixUnitaire: Decimal.zero,
        totalLigne: Decimal.zero,
      ));
    });
  }

  void _ajouterLigneSpeciale(String type) {
    setState(() {
      _lignes.add(LigneDevis(
        description: "",
        quantite: Decimal.zero, // Pas de quantité pour les titres/textes
        prixUnitaire: Decimal.zero,
        totalLigne: Decimal.zero,
        type: type,
      ));
    });
  }

  Future<void> _importerArticle() async {
    final article = await showDialog<Article>(
        context: context, builder: (_) => const ArticleSelectionDialog());

    if (!mounted) return;

    if (article != null) {
      setState(() {
        _lignes.add(LigneDevis(
          description: article.designation,
          quantite: Decimal.one,
          prixUnitaire: article.prixUnitaire,
          totalLigne: article.prixUnitaire, // 1 * PU
          unite: article.unite,
          typeActivite: article.typeActivite,
        ));
        // Ajout auto au chiffrage pour rentabilité
        _chiffrage.add(LigneChiffrage(
          designation: article.designation,
          quantite: Decimal.one,
          prixAchatUnitaire: article.prixAchat,
          prixVenteUnitaire: article.prixUnitaire,
          unite: article.unite,
        ));
      });
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Veuillez remplir les champs obligatoires")));
      return;
    }
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner un client")));
      return;
    }

    setState(() => _isLoading = true);

    final vm = Provider.of<DevisViewModel>(context, listen: false);

    final devisToSave = Devis(
      id: widget.id, // Null si création
      userId: SupabaseConfig.userId, // Sera géré par le Repo
      numeroDevis: _numeroCtrl.text,
      objet: _objetCtrl.text,
      clientId: _selectedClient!.id!,
      dateEmission: _dateEmission,
      dateValidite: _dateValidite,
      statut: widget.devisAModifier?.statut ?? 'brouillon',
      totalHt: _totalHT,
      remiseTaux: _remiseTaux,
      acompteMontant: _acompteMontant,
      conditionsReglement: _conditionsCtrl.text,
      notesPubliques: _notesCtrl.text,
      lignes: _lignes,
      chiffrage: _chiffrage,
      // On conserve les champs non éditables ici
      signatureUrl: widget.devisAModifier?.signatureUrl,
      dateSignature: widget.devisAModifier?.dateSignature,
      estTransforme: widget.devisAModifier?.estTransforme ?? false,
      estArchive: widget.devisAModifier?.estArchive ?? false,
    );

    bool success;
    if (widget.id == null) {
      success = await vm.addDevis(devisToSave);
    } else {
      success = await vm.updateDevis(devisToSave);
    }

    // Async Safety
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      context.pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Devis enregistré !")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'enregistrement")));
    }
  }

  Future<void> _genererPDF() async {
    if (widget.devisAModifier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Veuillez d'abord enregistrer le devis.")));
      return;
    }

    final entrepriseVM =
        Provider.of<EntrepriseViewModel>(context, listen: false);
    final clientVM = Provider.of<ClientViewModel>(context, listen: false);

    // Ensure entreprise is loaded
    if (entrepriseVM.profil == null) {
      await entrepriseVM.fetchProfil();
    }

    try {
      final client = clientVM.clients
          .firstWhere((c) => c.id == widget.devisAModifier!.clientId);

      // Appel au service PDF (implémenté dans pdf_service.dart)
      final pdfBytes = await PdfService.generateDevis(
          widget.devisAModifier!, client, entrepriseVM.profil);

      if (!mounted) return;

      await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: "Devis_${widget.devisAModifier!.numeroDevis}.pdf");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur génération PDF : $e")));
    }
  }

  Future<void> _finaliser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Finaliser le devis ?"),
        content: const Text(
            "Un numéro définitif sera attribué. Le devis ne sera plus modifiable."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Non")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Oui")),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<DevisViewModel>(context, listen: false);

    if (widget.devisAModifier != null) {
      await vm.finaliserDevis(widget.devisAModifier!);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    context.pop(); // Retour liste
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.id == null ? "Nouveau Devis" : "Modifier Devis",
      menuIndex: 1,
      useFullWidth: true,
      headerActions: [
        if (widget.devisAModifier != null)
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Voir PDF",
            onPressed: _genererPDF,
          )
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EN-TÊTE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  label: "Objet du devis",
                                  controller: _objetCtrl,
                                  validator: (v) =>
                                      v!.isEmpty ? "Requis" : null,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final d = await showDatePicker(
                                              context: context,
                                              initialDate: _dateEmission,
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2030));
                                          if (d != null && mounted) {
                                            setState(() => _dateEmission = d);
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                              labelText: "Date émission",
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white),
                                          child: Text(DateFormat('dd/MM/yyyy')
                                              .format(_dateEmission)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final d = await showDatePicker(
                                              context: context,
                                              initialDate: _dateValidite,
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2030));
                                          if (d != null && mounted) {
                                            setState(() => _dateValidite = d);
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                              labelText: "Validité",
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white),
                                          child: Text(DateFormat('dd/MM/yyyy')
                                              .format(_dateValidite)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: AppCard(
                            onTap: _selectionnerClient,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("CLIENT",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                                const SizedBox(height: 8),
                                if (_selectedClient != null) ...[
                                  Text(_selectedClient!.nomComplet,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(_selectedClient!.ville),
                                ] else
                                  const Row(
                                    children: [
                                      Icon(Icons.add_circle,
                                          color: AppTheme.primary),
                                      SizedBox(width: 8),
                                      Text("Sélectionner...",
                                          style: TextStyle(
                                              color: AppTheme.primary)),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // LIGNES DEVIS
                    const Text("LIGNES DU DEVIS",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary)),
                    const SizedBox(height: 10),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _lignes.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _lignes.removeAt(oldIndex);
                          _lignes.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final ligne = _lignes[index];
                        return Card(
                          key: ValueKey(ligne.uiKey), // Utilisation UiKey
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
                            showHandle: true,
                            onChanged: (desc, qte, pu, unite, type, gras, ital,
                                soul, avancement) {
                              setState(() {
                                _lignes[index] = ligne.copyWith(
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
                                );
                              });
                            },
                            onDelete: () {
                              setState(() {
                                _lignes.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _ajouterLigne,
                          icon: const Icon(Icons.add),
                          label: const Text("Article"),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _ajouterLigneSpeciale('titre'),
                          icon: const Icon(Icons.title),
                          label: const Text("Titre"),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _ajouterLigneSpeciale('sous-titre'),
                          icon: const Icon(Icons.text_fields),
                          label: const Text("Sous-titre"),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _ajouterLigneSpeciale('texte'),
                          icon: const Icon(Icons.comment),
                          label: const Text("Note"),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _ajouterLigneSpeciale('saut_page'),
                          icon: const Icon(
                              Icons.feed), // "Feed" looks like a page break
                          label: const Text("Saut Page"),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange),
                        ),
                        OutlinedButton.icon(
                          onPressed: _importerArticle,
                          icon: const Icon(Icons.library_books),
                          label: const Text("Importer"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // TOTAUX
                    AppCard(
                      child: Column(
                        children: [
                          _rowTotal("Total HT", _totalHT),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Remise (%)"),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  initialValue: _remiseTaux.toString(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration:
                                      const InputDecoration(suffixText: "%"),
                                  onChanged: (v) {
                                    setState(() {
                                      _remiseTaux =
                                          Decimal.tryParse(v) ?? Decimal.zero;
                                    });
                                  },
                                ),
                              ),
                              Text("- ${FormatUtils.currency(_totalRemise)}",
                                  style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                          const Divider(),
                          _rowTotal("NET COMMERCIAL", _netCommercial,
                              isBig: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ACOMPTE
                    AppCard(
                      title: const Text("Acompte demandé"),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pourcentage de l'acompte :",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [10, 20, 30, 40, 50].map((p) {
                              final isSelected =
                                  _acomptePercentage == Decimal.fromInt(p);
                              return ChoiceChip(
                                label: Text("$p%"),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _acomptePercentage = Decimal.fromInt(p);
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  key: ValueKey(_acomptePercentage.toString()),
                                  initialValue: _acomptePercentage.toString(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: "Autre (%)",
                                    suffixText: "%",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    setState(() {
                                      _acomptePercentage =
                                          Decimal.tryParse(v) ?? Decimal.zero;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Montant calculé :",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                      Text(
                                        FormatUtils.currency(_acompteMontant),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    // ACTIONS BAS DE PAGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.devisAModifier?.statut == 'brouillon')
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: OutlinedButton(
                              onPressed: _finaliser,
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green),
                              child: const Text("FINALISER (Figer)"),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: _sauvegarder,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15)),
                          child: const Text("ENREGISTRER",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _rowTotal(String label, Decimal val, {bool isBig = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBig ? FontWeight.bold : FontWeight.normal,
                fontSize: isBig ? 18 : 14)),
        Text(FormatUtils.currency(val),
            style: TextStyle(
                fontWeight: isBig ? FontWeight.bold : FontWeight.normal,
                fontSize: isBig ? 18 : 14,
                color: AppTheme.primary)),
      ],
    );
  }
}
