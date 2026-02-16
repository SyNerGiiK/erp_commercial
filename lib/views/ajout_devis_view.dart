import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart'; // Pour PdfPageFormat
import 'package:pdf/pdf.dart'; // ADDED for PdfPageFormat
import 'dart:typed_data';

import '../widgets/dialogs/signature_dialog.dart';
import '../widgets/dialogs/matiere_dialog.dart';

import '../config/theme.dart';
import '../config/supabase_config.dart';
import '../models/devis_model.dart';
import '../models/article_model.dart';
import '../models/client_model.dart';
import '../models/chiffrage_model.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../viewmodels/urssaf_viewmodel.dart';
import '../models/urssaf_model.dart';
import '../models/enums/entreprise_enums.dart';

// Services
import '../services/pdf_service.dart';
// import '../services/preferences_service.dart';

// Widgets
// import '../widgets/base_screen.dart'; // REMOVED
import '../widgets/split_editor_scaffold.dart'; // ADDED
import '../widgets/app_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/client_selection_dialog.dart';
import '../widgets/article_selection_dialog.dart';
import '../widgets/ligne_editor.dart';
import '../widgets/chiffrage_editor.dart';
import '../widgets/rentabilite_card.dart';

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

class _AjoutDevisViewState extends State<AjoutDevisView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // TabController pour les onglets Devis / Analyse Coûts
  late TabController _tabController;

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
  Decimal _acomptePercentage = Decimal.fromInt(30); // Défaut : 30%
  String _statut = 'brouillon';

  // Signature
  String? _signatureUrl;
  DateTime? _dateSignature;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initData();
  }

  void _initData() {
    Devis? d = widget.devisAModifier;

    // Tentative de récupération de la version la plus récente depuis le ViewModel
    if (widget.id != null) {
      final vm = Provider.of<DevisViewModel>(context, listen: false);
      try {
        final fresh = vm.devis.firstWhere((element) => element.id == widget.id);
        d = fresh;
      } catch (_) {
        // Pas trouvé dans le VM (peut-être pas encore chargé), on garde widget.devisAModifier
      }
    }

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

      if (d.totalHt > Decimal.zero) {
        // On base le % sur le Net Commercial (HT - Remise)
        final net = d.totalHt -
            ((d.totalHt * d.remiseTaux) / Decimal.fromInt(100)).toDecimal();
        if (net > Decimal.zero) {
          _acomptePercentage =
              CalculationsUtils.calculateTauxFromMontant(net, d.acompteMontant);
        }
      }

      _statut = d.statut;
      _signatureUrl = d.signatureUrl;
      // Clean URL logic
      if (_signatureUrl != null && !_signatureUrl!.contains('?')) {
        _signatureUrl =
            "$_signatureUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      }
      _dateSignature = d.dateSignature;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clientVM = Provider.of<ClientViewModel>(context, listen: false);
        try {
          final client =
              clientVM.clients.firstWhere((c) => c.id == d!.clientId);
          setState(() => _selectedClient = client);
        } catch (_) {}
      });
    } else {
      _numeroCtrl = TextEditingController(text: "Brouillon");
      _objetCtrl = TextEditingController();
      _notesCtrl = TextEditingController();
      _conditionsCtrl = TextEditingController(text: "Paiement à réception");
      _statut = 'brouillon';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _numeroCtrl.dispose();
    _objetCtrl.dispose();
    _notesCtrl.dispose();
    _conditionsCtrl.dispose();
    super.dispose();
  }

  // --- HELPER: BUILD OBJECT ---
  Devis _buildDevisFromState() {
    return Devis(
      id: widget.id, // Null si création
      userId: SupabaseConfig.userId,
      numeroDevis: _numeroCtrl.text,
      objet: _objetCtrl.text,
      clientId: _selectedClient?.id ??
          "temp_client", // ID temporaire si pas encore sélect
      dateEmission: _dateEmission,
      dateValidite: _dateValidite,
      statut: _statut,
      totalHt: _totalHT,
      totalTva: _totalTVARemisee,
      totalTtc: _netAPayerFinal,
      remiseTaux: _remiseTaux,
      acompteMontant: _acompteMontant,
      conditionsReglement: _conditionsCtrl.text,
      notesPubliques: _notesCtrl.text,
      lignes: _lignes,
      chiffrage: _chiffrage,
      signatureUrl: _signatureUrl?.split('?').first,
      dateSignature: _dateSignature,
      estTransforme: widget.devisAModifier?.estTransforme ?? false,
      estArchive: widget.devisAModifier?.estArchive ?? false,
    );
  }

  // --- CALCULS ---

  Decimal get _totalHT =>
      _lignes.fold(Decimal.zero, (sum, l) => sum + l.totalLigne);

  Decimal get _totalTVA =>
      _lignes.fold(Decimal.zero, (sum, l) => sum + l.montantTva);

  Decimal get _totalRemise {
    return CalculationsUtils.calculateCharges(_totalHT, _remiseTaux);
  }

  Decimal get _netCommercial => _totalHT - _totalRemise;

  Decimal get _totalTVARemisee =>
      _totalTVA - CalculationsUtils.calculateCharges(_totalTVA, _remiseTaux);
  Decimal get _netAPayerFinal => _netCommercial + _totalTVARemisee;

  // --- ACTIONS ---

  Future<void> _selectionnerClient() async {
    final client = await showDialog<Client>(
        context: context, builder: (_) => const ClientSelectionDialog());

    if (!mounted) return;

    if (client != null) {
      setState(() => _selectedClient = client);
    }
  }

  // --- GESTION MATIÈRES PREMIÈRES ---

  Future<void> _ajouterMatiere() async {
    final result = await showDialog<LigneChiffrage>(
      context: context,
      builder: (_) => const MatiereDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        _chiffrage.add(result);
      });
    }
  }

  void _supprimerMatiere(int index) {
    setState(() {
      _chiffrage.removeAt(index);
    });
  }

  void _ajouterLigneSpeciale(String type) {
    setState(() {
      _lignes.add(LigneDevis(
        description: "",
        quantite: Decimal.zero,
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
          totalLigne: article.prixUnitaire,
          unite: article.unite,
          typeActivite: article.typeActivite,
          tauxTva: article.tauxTva,
        ));
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
    final devisToSave = _buildDevisFromState();

    bool success;
    if (widget.id == null) {
      success = await vm.addDevis(devisToSave);
    } else {
      success = await vm.updateDevis(devisToSave);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/app/devis');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Devis enregistré !")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'enregistrement")));
    }
  }

  /// callback pour SplitEditorScaffold
  Future<Uint8List> _generatePreviewPdf(PdfPageFormat format) async {
    final entrepriseVM =
        Provider.of<EntrepriseViewModel>(context, listen: false);
    if (entrepriseVM.profil == null) {
      await entrepriseVM.fetchProfil();
    }
    final isTvaApplicable = entrepriseVM.isTvaApplicable;

    // On utilise un client temporaire si pas sélectionné pour éviter crash
    final client = _selectedClient ??
        Client(
          nomComplet: "Client (En attente)",
          adresse: "",
          codePostal: "",
          ville: "",
          telephone: "",
          email: "",
          typeClient: "particulier",
        );

    final devis = _buildDevisFromState();

    return await PdfService.generateDocument(devis, client, entrepriseVM.profil,
        docType: "DEVIS", isTvaApplicable: isTvaApplicable);
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
    context.pop();
  }

  Future<void> _signerClient() async {
    if (widget.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Veuillez d'abord enregistrer le devis pour pouvoir le signer.")));
      return;
    }

    final Uint8List? signatureBytes = await showDialog(
      context: context,
      builder: (_) => const SignatureDialog(),
    );

    if (signatureBytes == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<DevisViewModel>(context, listen: false);

    final success = await vm.uploadSignature(widget.id!, signatureBytes);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature enregistrée !")));

      try {
        final updatedDevis = vm.devis.firstWhere((d) => d.id == widget.id);
        setState(() {
          if (updatedDevis.signatureUrl != null) {
            _signatureUrl =
                "${updatedDevis.signatureUrl}?t=${DateTime.now().millisecondsSinceEpoch}";
          } else {
            _signatureUrl = null;
          }
          _dateSignature = updatedDevis.dateSignature;
          _statut = updatedDevis.statut;
        });
      } catch (e) {
        debugPrint("Erreur signature: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la signature")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // On construit les données pour le draft (Minimisation)
    final draftData = _buildDevisFromState();

    return SplitEditorScaffold(
      title: widget.id == null ? "Nouveau Devis" : "Modifier Devis",
      onSave: _sauvegarder,
      isSaving: _isLoading,
      draftData: draftData,
      draftType: 'devis',
      draftId: widget.id,
      // La fonction qui génère le PDF preview
      onGeneratePdf: _generatePreviewPdf,

      // FORMULAIRE (Partie Gauche)
      editorForm: Column(
        children: [
          // TAB BAR (Reste visible en haut de la colonne gauche)
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.description), text: "Devis"),
                Tab(icon: Icon(Icons.analytics), text: "Coûts & Rentabilité"),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabDevis(),
                _buildTabAnalyse(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ONGLET DEVIS ---
  Widget _buildTabDevis() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                          validator: (v) => v!.isEmpty ? "Requis" : null,
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
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(_selectedClient!.ville),
                        ] else
                          const Row(
                            children: [
                              Icon(Icons.add_circle, color: AppTheme.primary),
                              SizedBox(width: 8),
                              Text("Sélectionner...",
                                  style: TextStyle(color: AppTheme.primary)),
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
                    tauxTva: ligne.tauxTva,
                    showTva: Provider.of<EntrepriseViewModel>(context)
                        .isTvaApplicable,
                    onChanged: (desc, qte, pu, unite, type, gras, ital, soul,
                        av, tva) {
                      setState(() {
                        _lignes[index] = ligne.copyWith(
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final isTvaApplicable = Provider.of<EntrepriseViewModel>(
                              context,
                              listen: false)
                          .isTvaApplicable;
                      setState(() {
                        _lignes.add(LigneDevis(
                          description: "",
                          quantite: Decimal.one,
                          prixUnitaire: Decimal.zero,
                          totalLigne: Decimal.zero,
                          tauxTva: isTvaApplicable
                              ? Decimal.fromInt(20)
                              : Decimal.zero,
                        ));
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Article"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _ajouterLigneSpeciale('titre'),
                    icon: const Icon(Icons.title),
                    label: const Text("Titre"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _ajouterLigneSpeciale('sous-titre'),
                    icon: const Icon(Icons.text_fields),
                    label: const Text("Sous-titre"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _ajouterLigneSpeciale('texte'),
                    icon: const Icon(Icons.comment),
                    label: const Text("Note"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _ajouterLigneSpeciale('saut_page'),
                    icon: const Icon(Icons.feed),
                    label: const Text("Saut Page"),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _importerArticle,
                    icon: const Icon(Icons.library_books),
                    label: const Text("Importer"),
                  ),
                ],
              ),
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
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(suffixText: "%"),
                          onChanged: (v) {
                            setState(() {
                              _remiseTaux = Decimal.tryParse(v) ?? Decimal.zero;
                            });
                          },
                        ),
                      ),
                      Text("- ${FormatUtils.currency(_totalRemise)}",
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  const Divider(),
                  _rowTotal("NET COMMERCIAL (HT)", _netCommercial,
                      isBig: false),
                  if (Provider.of<EntrepriseViewModel>(context).isTvaApplicable)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total TVA"),
                          Text(FormatUtils.currency(_totalTVARemisee)),
                        ]),
                  const Divider(),
                  _rowTotal(
                      Provider.of<EntrepriseViewModel>(context).isTvaApplicable
                          ? "NET À PAYER (TTC)"
                          : "NET À PAYER",
                      _netAPayerFinal,
                      isBig: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ACOMPTE
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Acompte demandé",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
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
                        onSelected: (val) {
                          if (val) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Montant acompte :"),
                      Text(FormatUtils.currency(_acompteMontant),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PIED DE PAGE & SIGNATURE
            AppCard(
              child: Column(
                children: [
                  CustomTextField(
                    label: "Conditions de règlement",
                    controller: _conditionsCtrl,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: "Notes (Visibles sur le PDF)",
                    controller: _notesCtrl,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  if (widget.id != null) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Signature Client :"),
                        if (_signatureUrl != null)
                          Tooltip(
                            message:
                                "Signé le ${DateFormat('dd/MM/yyyy HH:mm').format(_dateSignature ?? DateTime.now())}",
                            child: const Chip(
                                label: Text("Signé"),
                                avatar: Icon(Icons.check_circle,
                                    color: Colors.green)),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _signerClient,
                            icon: const Icon(Icons.draw),
                            label: const Text("Faire signer le client"),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 50),
            if (widget.id != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _finaliser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text("FINALISER LE DEVIS (Définitif)"),
                ),
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- ONGLET ANALYSE ---
  Widget _buildTabAnalyse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primary),
              SizedBox(width: 10),
              Text("Analyse de rentabilité",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Ce tableau vous aide à calculer vos marges réelles. Il n'est pas visible par le client.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // TABLEAU CHIFFRAGE
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(10),
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: Text("Désignation")),
                      Expanded(flex: 1, child: Text("Qté")),
                      Expanded(flex: 1, child: Text("P. Achat")),
                      Expanded(flex: 1, child: Text("P. Vente")),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                // Lignes
                if (_chiffrage.isEmpty)
                  const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Aucun élément de coût.")),
                Consumer<UrssafViewModel>(builder: (context, urssafVM, child) {
                  final taux =
                      urssafVM.config?.tauxMicroVente ?? Decimal.parse('12.3');
                  return Column(
                    children: List.generate(_chiffrage.length, (index) {
                      final item = _chiffrage[index];
                      return ChiffrageEditor(
                        description: item.designation,
                        quantite: item.quantite,
                        prixAchat: item.prixAchatUnitaire,
                        prixVente: item.prixVenteUnitaire,
                        unite: item.unite,
                        tauxUrssaf: taux,
                        onChanged: (desc, qte, pa, pv, unit) {
                          setState(() {
                            _chiffrage[index] = item.copyWith(
                              designation: desc,
                              quantite: qte,
                              prixAchatUnitaire: pa,
                              prixVenteUnitaire: pv,
                              unite: unit,
                            );
                          });
                        },
                        onDelete: () => _supprimerMatiere(index),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _ajouterMatiere,
            icon: const Icon(Icons.add),
            label: const Text("Ajouter charge / matière"),
          ),
          const SizedBox(height: 30),

          // RENTABILITÉ CARD
          // RENTABILITÉ CARD
          Consumer<UrssafViewModel>(builder: (context, urssafVM, child) {
            // Calcul des coûts (Achat Matériel/Sous-traitance)
            final totalAchat = _chiffrage.fold(Decimal.zero,
                (sum, item) => sum + (item.prixAchatUnitaire * item.quantite));

            // Calcul des charges URSSAF basées sur les lignes du devis (Service vs Vente)
            // Note: On utilise le Net Commercial (HT remisé) au prorata des lignes ?
            // Simplification V1 : On applique les taux sur le total HT par type, puis on proratise la remise globale.

            final config = urssafVM.config;
            final tauxPrestation =
                config?.tauxMicroServiceBIC ?? Decimal.parse('21.2');
            final tauxVente = config?.tauxMicroVente ?? Decimal.parse('12.3');

            Decimal totalServiceHT = Decimal.zero;
            Decimal totalVenteHT = Decimal.zero;

            for (var l in _lignes) {
              if (l.typeActivite == 'vente') {
                totalVenteHT += l.totalLigne;
              } else {
                totalServiceHT += l.totalLigne;
              }
            }

            // Appliquer remise globale
            if (_remiseTaux > Decimal.zero && _totalHT > Decimal.zero) {
              final ratio = Decimal.fromInt(1) -
                  (_remiseTaux / Decimal.fromInt(100)).toDecimal();
              totalServiceHT = totalServiceHT * ratio;
              totalVenteHT = totalVenteHT * ratio;
            }

            final chargesService = CalculationsUtils.calculateCharges(
                totalServiceHT, tauxPrestation);
            final chargesVente =
                CalculationsUtils.calculateCharges(totalVenteHT, tauxVente);
            final totalCharges = chargesService + chargesVente;

            final solde = _netCommercial - totalAchat - totalCharges;

            // Taux moyen pour l'affichage (indicatif)
            Decimal tauxAffiche = tauxPrestation;
            if (totalVenteHT > totalServiceHT) tauxAffiche = tauxVente;

            return RentabiliteCard(
              type: RentabiliteType.chantier,
              ca: _netCommercial,
              cout: totalAchat,
              charges: totalCharges,
              solde: solde,
              tauxUrssaf: tauxAffiche,
            );
          }),
        ],
      ),
    );
  }

  Widget _rowTotal(String label, Decimal amount, {bool isBig = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBig ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBig ? 18 : 14)),
          Text(FormatUtils.currency(amount),
              style: TextStyle(
                  fontWeight: isBig ? FontWeight.bold : FontWeight.bold,
                  fontSize: isBig ? 18 : 14,
                  color: isBig ? AppTheme.primary : Colors.black)),
        ],
      ),
    );
  }
}
