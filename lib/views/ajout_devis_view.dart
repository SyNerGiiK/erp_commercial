import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../widgets/dialogs/signature_dialog.dart';
import '../widgets/dialogs/matiere_dialog.dart';

import '../config/theme.dart';
import '../config/supabase_config.dart';
import '../models/devis_model.dart';
import '../models/article_model.dart';
import '../models/client_model.dart';
import '../models/chiffrage_model.dart';
// import '../models/config_charges_model.dart'; // Removed
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../viewmodels/urssaf_viewmodel.dart';
import '../models/urssaf_model.dart';
import '../models/enums/entreprise_enums.dart';

// Services
import '../services/pdf_service.dart';
import '../services/preferences_service.dart';

// Widgets
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart'; // Import ajouté
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
      // _acompteMontant is now computed, so we don't assign it.
      // We calculate percentage from d.acompteMontant and d.totalHt
      // Reverse calc percentage
      if (d.totalHt > Decimal.zero) {
        // On base le % sur le Net Commercial (HT - Remise)
        final net = d.totalHt -
            ((d.totalHt * d.remiseTaux) / Decimal.fromInt(100)).toDecimal();
        if (net > Decimal.zero) {
          _acomptePercentage =
              CalculationsUtils.calculateTauxFromMontant(net, d.acompteMontant);
        }
      }

      // Init Statut
      _statut = d.statut;
      // Init Signature (Clean URL handled display-side)
      _signatureUrl = d.signatureUrl;
      if (_signatureUrl != null && !_signatureUrl!.contains('?')) {
        // Add timestamp for display only
        _signatureUrl =
            "$_signatureUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      }
      _dateSignature = d.dateSignature;

      // Charger le client si on a l'ID
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clientVM = Provider.of<ClientViewModel>(context, listen: false);
        try {
          final client =
              clientVM.clients.firstWhere((c) => c.id == d!.clientId);
          setState(() => _selectedClient = client);
        } catch (_) {
          // Client non trouvé (peut-être supprimé ou liste non chargée)
          // On ne fait rien, l'utilisateur devra resélectionner si besoin
        }
      });
    } else {
      _numeroCtrl = TextEditingController(text: "Brouillon");
      _objetCtrl = TextEditingController();
      _notesCtrl = TextEditingController(); // Fixed duplicate line
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
      statut: _statut,
      totalHt: _totalHT,
      remiseTaux: _remiseTaux,
      acompteMontant: _acompteMontant,
      conditionsReglement: _conditionsCtrl.text,
      notesPubliques: _notesCtrl.text,
      lignes: _lignes,
      chiffrage: _chiffrage,
      // On conserve les champs non éditables ici
      // On utilise les variables d'état qui peuvent avoir été mises à jour par _signerClient
      // IMPORTANT : On nettoie l'URL de tout paramètre (timestamp) avant sauvegarde
      signatureUrl: _signatureUrl?.split('?').first,
      dateSignature: _dateSignature,
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
      context.go(
          '/app/devis'); // ✅ FIX: Utiliser go() au lieu de pop() pour éviter "nothing to pop"
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature enregistrée !")));

      // Récupérer le devis mis à jour depuis le VM pour avoir l'URL correcte
      try {
        final updatedDevis = vm.devis.firstWhere((d) => d.id == widget.id);
        setState(() {
          // On ajoute un timestamp pour forcer le rafraîchissement du cache navigateur
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
        // Fallback si pas trouvé (rare)
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la signature")));
    }
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
          : Column(
              children: [
                // TAB BAR
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primary,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(icon: Icon(Icons.description), text: "Devis"),
                      Tab(
                          icon: Icon(Icons.analytics),
                          text: "Coûts & Rentabilité"),
                    ],
                  ),
                ),
                // TAB BAR VIEW
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
                    onChanged: (desc, qte, pu, unite, type, gras, ital, soul,
                        avancement) {
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
                  icon:
                      const Icon(Icons.feed), // "Feed" looks like a page break
                  label: const Text("Saut Page"),
                  style:
                      OutlinedButton.styleFrom(foregroundColor: Colors.orange),
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
                  _rowTotal("NET COMMERCIAL", _netCommercial, isBig: true),
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
                          keyboardType: const TextInputType.numberWithOptions(
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
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Montant calculé :",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
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

            // SIGNATURE CLIENT
            AppCard(
              child: Column(
                children: [
                  const Text("Signature Client",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  if (_signatureUrl != null) ...[
                    Image.network(
                      _signatureUrl!,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                              height: 150,
                              child: Center(
                                  child: Text("Erreur chargement signature"))),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Signé le ${DateFormat('dd/MM/yyyy HH:mm').format(_dateSignature ?? DateTime.now())}",
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(_signatureUrl ?? 'URL Nulle',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey)), // DEBUG
                  ] else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                          "Aucune signature client enregistrée pour ce devis."),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _signerClient,
                      icon: const Icon(Icons.draw),
                      label: Text(_signatureUrl != null
                          ? "Refaire la signature"
                          : "Faire signer le client"),
                    ),
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
    );
  }

  // --- ONGLET ANALYSE COÛTS ---
  Widget _buildTabAnalyse() {
    // Récupération configuration URSSAF & Profil
    final urssafVM = Provider.of<UrssafViewModel>(context);
    final entrepriseVM = Provider.of<EntrepriseViewModel>(context);

    final config = urssafVM.config;
    final profil = entrepriseVM.profil;

    // Calcul du taux applicable (Priorité Micro-Entrepreneur Vente pour les matières)
    Decimal tauxApplicable = Decimal.zero;
    String detailsTaux = "Non configuré";

    if (config != null && profil != null) {
      if (profil.typeEntreprise.isMicroEntrepreneur) {
        // Pour les matières premières, c'est de la Vente de Marchandises
        final tauxBase = config.tauxMicroVente;
        final tauxEffectif = config.getTauxMicroEffectif(tauxBase);
        final cfp = config.tauxCfpMicroVente;

        tauxApplicable = tauxEffectif + cfp;
        detailsTaux =
            "Micro-Entreprise Vente : ${tauxEffectif.toDouble()}% (Cotis.) + ${cfp.toDouble()}% (CFP) = ${tauxApplicable.toDouble()}%";
        if (config.accreActive) {
          detailsTaux += " [ACRE Année ${config.accreAnnee}]";
        }
      } else {
        // Autres régimes (TNS, SASU...)
        // Le calcul est beaucoup plus complexe (sur bénéfice), on affiche 0 pour l'instant
        // ou on pourrait mettre une estimation si demandé.
        detailsTaux =
            "Régime Réel / TNS : Calcul sur bénéfice (Non simulé ici)";
        tauxApplicable = Decimal.zero;
      }
    } else {
      detailsTaux = "Profil entreprise ou Config URSSAF manquant";
    }

    // Calculer totaux Decimal
    final totalAchats = _chiffrage.fold<Decimal>(
      Decimal.zero,
      (sum, ligne) => sum + (ligne.quantite * ligne.prixAchatUnitaire),
    );

    final totalVentes = _chiffrage.fold<Decimal>(
      Decimal.zero,
      (sum, ligne) => sum + (ligne.quantite * ligne.prixVenteUnitaire),
    );

    final charges = (totalVentes * tauxApplicable) / Decimal.fromInt(100);
    final chargesDecimal = charges.toDecimal();
    final solde = totalVentes - totalAchats - chargesDecimal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARTE RENTABILITÉ
          RentabiliteCard(
            type: RentabiliteType.materiel,
            ca: totalVentes,
            cout: totalAchats,
            charges: chargesDecimal,
            solde: solde,
            tauxUrssaf: tauxApplicable,
          ),
          const SizedBox(height: 16),

          // SECTION MATIÈRES
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec titre et bouton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Matières Premières",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.add_circle, color: AppTheme.primary),
                      onPressed: _ajouterMatiere,
                      tooltip: "Ajouter matière",
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Contenu
                _chiffrage.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            "Aucune matière ajoutée\nCliquez sur + pour commencer",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: _chiffrage.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ligne = entry.value;
                          return ChiffrageEditor(
                            description: ligne.designation,
                            quantite: ligne.quantite,
                            prixAchat: ligne.prixAchatUnitaire,
                            prixVente: ligne.prixVenteUnitaire,
                            unite: ligne.unite,
                            tauxUrssaf: tauxApplicable,
                            onChanged: (desc, qte, pa, pv, unite) {
                              setState(() {
                                _chiffrage[index] = ligne.copyWith(
                                  designation: desc,
                                  quantite: qte,
                                  prixAchatUnitaire: pa,
                                  prixVenteUnitaire: pv,
                                  unite: unite,
                                );
                              });
                            },
                            onDelete: () => _supprimerMatiere(index),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // NOTE SUR LES TAUX
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Information Taux & Charges",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        detailsTaux,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.indigo),
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
