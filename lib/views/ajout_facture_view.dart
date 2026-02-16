import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart'; // ADDED
import 'dart:typed_data';

import '../config/theme.dart';
import '../models/facture_model.dart';
import '../models/article_model.dart';
import '../models/client_model.dart';
import '../models/chiffrage_model.dart';
import '../models/paiement_model.dart';

import '../viewmodels/facture_viewmodel.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../config/supabase_config.dart';

import '../services/pdf_service.dart';

// Widgets
import '../widgets/split_editor_scaffold.dart'; // ADDED
import '../widgets/app_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/client_selection_dialog.dart';
import '../widgets/article_selection_dialog.dart';
import '../widgets/ligne_editor.dart';
import '../widgets/dialogs/paiement_dialog.dart';
import '../widgets/dialogs/signature_dialog.dart';

import '../utils/format_utils.dart';
import '../utils/calculations_utils.dart';

class AjoutFactureView extends StatefulWidget {
  final String? id;
  final Facture? factureAModifier;
  final String? sourceDevisId;
  final String? sourceFactureId;

  const AjoutFactureView(
      {super.key,
      this.id,
      this.factureAModifier,
      this.sourceDevisId,
      this.sourceFactureId});

  @override
  State<AjoutFactureView> createState() => _AjoutFactureViewState();
}

class _AjoutFactureViewState extends State<AjoutFactureView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _numeroCtrl;
  late TextEditingController _objetCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _conditionsCtrl;

  Client? _selectedClient;

  DateTime _dateEmission = DateTime.now();
  DateTime _dateEcheance = DateTime.now().add(const Duration(days: 30));

  List<LigneFacture> _lignes = [];
  List<LigneChiffrage> _chiffrage = [];
  List<Paiement> _paiements = [];

  String? _signatureUrl;
  DateTime? _dateSignature;

  String _typeFacture = 'standard';

  Decimal _remiseTaux = Decimal.zero;
  // Stockage de l'acompte déjà réglé (venant du devis par ex)
  Decimal _acompteDejaRegle = Decimal.zero;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    // Cas 1 : Modification Facture existante
    if (widget.factureAModifier != null) {
      Facture f = widget.factureAModifier!;

      // Tentative de récupération fraîche
      if (widget.id != null) {
        final vm = Provider.of<FactureViewModel>(context, listen: false);
        try {
          final fresh =
              vm.factures.firstWhere((element) => element.id == widget.id);
          f = fresh;
        } catch (_) {}
      }

      _numeroCtrl = TextEditingController(text: f.numeroFacture);
      _objetCtrl = TextEditingController(text: f.objet);
      _typeFacture = f.type;
      _notesCtrl = TextEditingController(text: f.notesPubliques ?? "");
      _conditionsCtrl = TextEditingController(text: f.conditionsReglement);
      _dateEmission = f.dateEmission;
      _dateEcheance = f.dateEcheance;
      _lignes = List.from(f.lignes);
      _chiffrage = List.from(f.chiffrage);
      _paiements = List.from(f.paiements);

      _remiseTaux = f.remiseTaux;
      _acompteDejaRegle = f.acompteDejaRegle;

      // Init Signature
      _signatureUrl = f.signatureUrl;
      if (_signatureUrl != null && !_signatureUrl!.contains('?')) {
        _signatureUrl =
            "$_signatureUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      }
      _dateSignature = f.dateSignature;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clientVM = Provider.of<ClientViewModel>(context, listen: false);
        try {
          final client = clientVM.clients.firstWhere((c) => c.id == f.clientId);
          setState(() => _selectedClient = client);
        } catch (_) {}
      });
    }
    // Cas 2 : Création depuis Devis
    else if (widget.sourceDevisId != null) {
      final devisVM = Provider.of<DevisViewModel>(context, listen: false);
      try {
        final devis =
            devisVM.devis.firstWhere((d) => d.id == widget.sourceDevisId);
        _typeFacture = 'standard';
        _numeroCtrl = TextEditingController(text: "Brouillon");
        _objetCtrl =
            TextEditingController(text: "Facture pour ${devis.numeroDevis}");
        _notesCtrl = TextEditingController(text: devis.notesPubliques ?? "");
        _conditionsCtrl =
            TextEditingController(text: devis.conditionsReglement);
        _dateEmission = DateTime.now();
        _dateEcheance = DateTime.now().add(const Duration(days: 30));

        _lignes = devis.lignes
            .map((ld) => LigneFacture(
                description: ld.description,
                quantite: ld.quantite,
                prixUnitaire: ld.prixUnitaire,
                totalLigne: ld.totalLigne,
                unite: ld.unite,
                typeActivite: ld.typeActivite,
                type: ld.type,
                ordre: ld.ordre,
                estGras: ld.estGras,
                estItalique: ld.estItalique,
                estSouligne: ld.estSouligne,
                tauxTva: ld.tauxTva))
            .toList();

        _chiffrage = List.from(devis.chiffrage);
        _remiseTaux = devis.remiseTaux;
        // On récupère l'acompte du devis comme "Déjà réglé"
        _acompteDejaRegle = devis.acompteMontant;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final clientVM = Provider.of<ClientViewModel>(context, listen: false);
          try {
            final client =
                clientVM.clients.firstWhere((c) => c.id == devis.clientId);
            setState(() => _selectedClient = client);
          } catch (_) {}
        });
      } catch (e) {
        _numeroCtrl = TextEditingController(text: "Erreur Devis");
        _objetCtrl = TextEditingController();
        _notesCtrl = TextEditingController();
        _conditionsCtrl = TextEditingController();
      }
    }
    // Cas 3 : Création Avoir depuis Facture
    else if (widget.sourceFactureId != null) {
      final factureVM = Provider.of<FactureViewModel>(context, listen: false);
      try {
        final source = factureVM.factures
            .firstWhere((f) => f.id == widget.sourceFactureId);
        _typeFacture = 'avoir';
        _numeroCtrl = TextEditingController(text: "Brouillon Avoir");
        _objetCtrl = TextEditingController(
            text: "Avoir sur facture ${source.numeroFacture}");
        _notesCtrl = TextEditingController(text: source.notesPubliques ?? "");
        _conditionsCtrl =
            TextEditingController(text: source.conditionsReglement);
        _dateEmission = DateTime.now();
        _dateEcheance = DateTime.now().add(const Duration(days: 30));

        _lignes = source.lignes
            .map((l) => LigneFacture(
                description: l.description,
                quantite: l.quantite,
                prixUnitaire: l.prixUnitaire,
                totalLigne: l.totalLigne,
                unite: l.unite,
                typeActivite: l.typeActivite,
                type: l.type,
                ordre: l.ordre,
                estGras: l.estGras,
                estItalique: l.estItalique,
                estSouligne: l.estSouligne,
                tauxTva: l.tauxTva))
            .toList();

        _chiffrage = List.from(source.chiffrage);
        _remiseTaux = source.remiseTaux;
        _acompteDejaRegle = source.acompteDejaRegle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final clientVM = Provider.of<ClientViewModel>(context, listen: false);
          try {
            final client =
                clientVM.clients.firstWhere((c) => c.id == source.clientId);
            setState(() => _selectedClient = client);
          } catch (_) {}
        });
      } catch (e) {
        _numeroCtrl = TextEditingController(text: "Erreur Source");
        _objetCtrl = TextEditingController();
        _notesCtrl = TextEditingController();
        _conditionsCtrl = TextEditingController();
      }
    }
    // Cas 4 : Nouvelle Facture Vierge
    else {
      _numeroCtrl = TextEditingController(text: "Brouillon");
      _objetCtrl = TextEditingController();
      _notesCtrl = TextEditingController();
      _conditionsCtrl = TextEditingController(text: "Paiement à réception");
      _typeFacture = 'standard';
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

  // --- BUILD OBJECT ---
  Facture _buildFactureFromState() {
    return Facture(
      id: widget.id,
      userId: SupabaseConfig.userId,
      numeroFacture: _numeroCtrl.text,
      objet: _objetCtrl.text,
      clientId: _selectedClient?.id ?? "temp-client",
      devisSourceId:
          widget.sourceDevisId ?? widget.factureAModifier?.devisSourceId,
      dateEmission: _dateEmission,
      dateEcheance: _dateEcheance,
      statut: widget.factureAModifier?.statut ?? 'brouillon',
      statutJuridique: widget.factureAModifier?.statutJuridique ?? 'brouillon',
      type: _typeFacture,
      totalHt: _totalHT,
      totalTva: _totalTVARemisee,
      totalTtc: _netAPayerFinal,
      remiseTaux: _remiseTaux,
      acompteDejaRegle: _acompteDejaRegle,
      conditionsReglement: _conditionsCtrl.text,
      notesPubliques: _notesCtrl.text,
      lignes: _lignes,
      chiffrage: _chiffrage,
      paiements: _paiements,
      signatureUrl: _signatureUrl?.split('?').first,
      dateSignature: _dateSignature,
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

  Decimal get _totalRegle =>
      _paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);

  Decimal get _resteAPayer {
    // Reste = NetFinal - AcompteDéjàReglé (venant devis) - PaiementsReçusSurFacture
    return _netAPayerFinal - _acompteDejaRegle - _totalRegle;
  }

  // --- ACTIONS ---

  void _ajouterLigne() {
    setState(() {
      _lignes.add(LigneFacture(
        description: "",
        quantite: Decimal.one,
        prixUnitaire: Decimal.zero,
        totalLigne: Decimal.zero,
        tauxTva: Decimal.fromInt(20),
      ));
    });
  }

  Future<void> _ajouterPaiement() async {
    final result = await showDialog<Paiement>(
      context: context,
      builder: (_) => const PaiementDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        _paiements.add(result);
      });
    }
  }

  void _supprimerPaiement(int index) {
    setState(() {
      _paiements.removeAt(index);
    });
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner un client")));
      return;
    }

    setState(() => _isLoading = true);
    final vm = Provider.of<FactureViewModel>(context, listen: false);

    final factureToSave = _buildFactureFromState();

    bool success;
    if (widget.id == null) {
      success = await vm.addFacture(factureToSave);
    } else {
      success = await vm.updateFacture(factureToSave);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/app/factures');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Facture enregistrée !")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'enregistrement")));
    }
  }

  // Preview PDF (Callback)
  Future<Uint8List> _generatePreviewPdf(PdfPageFormat format) async {
    final entrepriseVM =
        Provider.of<EntrepriseViewModel>(context, listen: false);
    if (entrepriseVM.profil == null) {
      await entrepriseVM.fetchProfil();
    }

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

    final facture = _buildFactureFromState();
    return await PdfService.generateFacture(
        facture, client, entrepriseVM.profil);
  }

  Future<void> _signerClient() async {
    if (widget.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Veuillez d'abord enregistrer la facture.")));
      return;
    }

    final Uint8List? signatureBytes = await showDialog(
      context: context,
      builder: (_) => const SignatureDialog(),
    );

    if (signatureBytes == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<FactureViewModel>(context, listen: false);

    final success = await vm.uploadSignature(widget.id!, signatureBytes);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature enregistrée !")));

      try {
        final updated = vm.factures.firstWhere((f) => f.id == widget.id);
        setState(() {
          if (updated.signatureUrl != null) {
            _signatureUrl =
                "${updated.signatureUrl}?t=${DateTime.now().millisecondsSinceEpoch}";
          }
          _dateSignature = updated.dateSignature;
        });
      } catch (_) {}
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la signature")));
    }
  }

  Future<void> _finaliser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Valider définitivement ?"),
        content: const Text(
            "La facture sera verrouillée et numérotée officiellement. Cette action est irréversible."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Valider")),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<FactureViewModel>(context, listen: false);

    if (widget.factureAModifier != null) {
      final success = await vm.finaliserFacture(widget.factureAModifier!);
      if (success && mounted) {
        context.pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Facture validée !")));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Draft Data for Minimize
    final draftData = _buildFactureFromState();

    return SplitEditorScaffold(
      title: widget.id == null ? "Nouvelle Facture" : "Modifier Facture",
      draftData: draftData,
      draftType: 'facture',
      draftId: widget.id,
      // Pass source info for restore
      sourceDevisId: widget.sourceDevisId,
      onSave: _sauvegarder,
      isSaving: _isLoading,
      onGeneratePdf: _generatePreviewPdf,
      editorForm: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // INFORMATIONS
              AppCard(
                title: const Text("INFORMATIONS"),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _numeroCtrl,
                            label: "Numéro",
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _objetCtrl,
                            label: "Objet",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          _selectedClient?.nomComplet ??
                              "Sélectionner un client",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedClient == null
                                  ? Colors.red
                                  : Colors.black)),
                      subtitle: Text(_selectedClient?.email ?? ""),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final client = await showDialog<Client>(
                            context: context,
                            builder: (_) => const ClientSelectionDialog());
                        if (client != null) {
                          setState(() => _selectedClient = client);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
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
                          decoration:
                              const InputDecoration(labelText: "Date Emission"),
                          child: Text(
                              DateFormat('dd/MM/yyyy').format(_dateEmission)),
                        ),
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                              context: context,
                              initialDate: _dateEcheance,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030));
                          if (d != null && mounted) {
                            setState(() => _dateEcheance = d);
                          }
                        },
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: "Échéance"),
                          child: Text(
                              DateFormat('dd/MM/yyyy').format(_dateEcheance)),
                        ),
                      )),
                    ])
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ELEMENTS (LIGNES)
              AppCard(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("ELEMENTS"),
                    IconButton(
                        onPressed: _ajouterLigne,
                        icon: const Icon(Icons.add_circle,
                            color: AppTheme.primary)),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _lignes.length,
                  itemBuilder: (context, index) {
                    final ligne = _lignes[index];
                    final isSituation = _typeFacture == 'situation';

                    return Card(
                      key: ValueKey(ligne.uiKey),
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
                        onChanged: (desc, qte, pu, unite, type, gras, ital,
                            soul, av, tva) {
                          setState(() {
                            Decimal total;
                            if (isSituation) {
                              total = ((qte * pu * av) / Decimal.fromInt(100))
                                  .toDecimal();
                            } else {
                              total = CalculationsUtils.calculateTotalLigne(
                                  qte, pu);
                            }

                            _lignes[index] = ligne.copyWith(
                              description: desc,
                              quantite: qte,
                              prixUnitaire: pu,
                              totalLigne: total,
                              unite: unite,
                              type: type,
                              estGras: gras,
                              estItalique: ital,
                              estSouligne: soul,
                              avancement: av,
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
              ),
              const SizedBox(height: 16),

              // SECTION TOTAUX
              AppCard(
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total HT"),
                          Text(FormatUtils.currency(_totalHT)),
                        ]),
                    if (_totalRemise > Decimal.zero)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Remise"),
                            Text("- ${FormatUtils.currency(_totalRemise)}",
                                style: const TextStyle(color: Colors.red)),
                          ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total TVA"),
                          Text(FormatUtils.currency(_totalTVARemisee)),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Remise (%)"),
                          SizedBox(
                              width: 80,
                              child: TextFormField(
                                  initialValue: _remiseTaux.toString(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: (v) => setState(() => _remiseTaux =
                                      Decimal.tryParse(v) ?? Decimal.zero))),
                        ]),
                    // Affichage Acompte déjà réglé
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Acompte déjà réglé (ex: Devis)"),
                          SizedBox(
                              width: 100,
                              child: TextFormField(
                                  initialValue: _acompteDejaRegle.toString(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: (v) => setState(() =>
                                      _acompteDejaRegle = Decimal.tryParse(v) ??
                                          Decimal.zero))),
                        ]),

                    const Divider(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("NET À PAYER (TTC)",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(FormatUtils.currency(_netAPayerFinal),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))
                        ]),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // NEW: SECTION PAIEMENTS / RÈGLEMENTS
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text("RÈGLEMENTS / PAIEMENTS REÇUS",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textDark)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _ajouterPaiement,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("Ajouter"),
                        )
                      ],
                    ),
                    const Divider(),
                    if (_paiements.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Aucun règlement enregistré",
                            style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _paiements.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final p = _paiements[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                                "${FormatUtils.currency(p.montant)} (${p.typePaiement})"),
                            subtitle: Text(
                                "${DateFormat('dd/MM/yyyy').format(p.datePaiement)} - ${p.commentaire}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              onPressed: () => _supprimerPaiement(index),
                            ),
                          );
                        },
                      ),
                    const Divider(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Règlements : "),
                          Text("- ${FormatUtils.currency(_totalRegle)}")
                        ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      const Text("RESTE À PAYER : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(FormatUtils.currency(_resteAPayer),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: _resteAPayer > Decimal.zero
                                  ? Colors.orange
                                  : Colors.green))
                    ])
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // NEW: SECTION SIGNATURE CLIENT
              AppCard(
                title: const Text("SIGNATURE CLIENT"),
                child: Column(
                  children: [
                    if (_signatureUrl != null)
                      Column(
                        children: [
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.network(_signatureUrl!,
                                fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              "Signé le ${DateFormat('dd/MM/yyyy HH:mm').format(_dateSignature ?? DateTime.now())}",
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Text("Aucune signature client",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _signerClient,
                            icon: const Icon(Icons.draw),
                            label: const Text("Faire signer le client"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // PIED DE PAGE & NOTES
              AppCard(
                  child: Column(children: [
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
              ])),
              const SizedBox(height: 20),

              // BOUTONS VALIDATION
              if (widget.factureAModifier?.statut == 'brouillon' ||
                  widget.factureAModifier?.statut == null)
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
                    label: const Text("VALIDER FACTURE (DÉFINITIF)"),
                  ),
                ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
