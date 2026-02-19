import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';

import '../../../models/facture_model.dart';
import '../../../models/client_model.dart';
import '../../../models/paiement_model.dart';
import '../../../models/chiffrage_model.dart';
import '../../../viewmodels/facture_viewmodel.dart';
import '../../../viewmodels/client_viewmodel.dart';
import '../../../viewmodels/entreprise_viewmodel.dart';
import '../../../viewmodels/devis_viewmodel.dart';
import '../../../config/supabase_config.dart';
import '../../../widgets/split_editor_scaffold.dart';
import '../../../utils/calculations_utils.dart';
import '../../../utils/format_utils.dart';

// Steps
import 'steps/step1_client.dart';
import 'steps/step2_details.dart';
import 'steps/step3_lignes.dart';
import 'steps/step4_validation.dart';

class FactureStepperView extends StatefulWidget {
  final String? id;
  final Facture? factureAModifier;
  final String? sourceDevisId;
  final String? sourceFactureId;

  const FactureStepperView({
    super.key,
    this.id,
    this.factureAModifier,
    this.sourceDevisId,
    this.sourceFactureId,
  });

  @override
  State<FactureStepperView> createState() => _FactureStepperViewState();
}

class _FactureStepperViewState extends State<FactureStepperView> {
  int _currentStep = 0;
  bool _isLoading = false;

  // --- STATE FACTURE ---
  // On stocke l'état ici pour le partager entre les steps
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _numeroCtrl;
  late TextEditingController _objetCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _conditionsCtrl;
  late TextEditingController _bonCommandeCtrl;
  late TextEditingController _motifAvoirCtrl;

  Client? _selectedClient;
  DateTime _dateEmission = DateTime.now();
  DateTime _dateEcheance = DateTime.now().add(const Duration(days: 30));

  List<LigneFacture> _lignes = [];
  List<LigneChiffrage> _chiffrage = [];
  List<Paiement> _paiements = [];

  String? _signatureUrl;
  DateTime? _dateSignature;
  String _statut = 'brouillon';
  String _typeFacture = 'standard';
  Decimal _remiseTaux = Decimal.zero;
  Decimal _acompteDejaRegle = Decimal.zero;

  // Liens parent préservés pour getLinkedFactures et historique
  String? _devisSourceId;
  String? _factureSourceId;
  String? _parentDocumentId;
  Decimal? _avancementGlobal;

  @override
  void initState() {
    super.initState();
    _numeroCtrl = TextEditingController();
    _objetCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _conditionsCtrl = TextEditingController();
    _bonCommandeCtrl = TextEditingController();
    _motifAvoirCtrl = TextEditingController();

    _initData();
  }

  void _initData() {
    // Cas 1 : Modification Facture existante
    if (widget.factureAModifier != null) {
      final f = widget.factureAModifier!;
      _numeroCtrl.text = f.numeroFacture;
      _objetCtrl.text = f.objet;
      _notesCtrl.text = f.notesPubliques ?? '';
      _conditionsCtrl.text = f.conditionsReglement;
      _bonCommandeCtrl.text = f.numeroBonCommande ?? '';
      _motifAvoirCtrl.text = f.motifAvoir ?? '';
      _dateEmission = f.dateEmission;
      _dateEcheance = f.dateEcheance;
      _lignes = List.from(f.lignes);
      _chiffrage = List.from(f.chiffrage);
      _paiements = List.from(f.paiements);
      _statut = f.statut;
      _typeFacture = f.type;
      _remiseTaux = f.remiseTaux;
      _acompteDejaRegle = f.acompteDejaRegle;
      _signatureUrl = f.signatureUrl;
      _dateSignature = f.dateSignature;
      _devisSourceId = f.devisSourceId;
      _factureSourceId = f.factureSourceId;
      _parentDocumentId = f.parentDocumentId;
      _avancementGlobal = f.avancementGlobal;

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
        _numeroCtrl.text = "Brouillon";
        _objetCtrl.text = "Facture pour ${devis.numeroDevis}";
        _notesCtrl.text = devis.notesPubliques ?? "";
        _conditionsCtrl.text = devis.conditionsReglement;
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
        _acompteDejaRegle = devis.acompteMontant;
        _devisSourceId = devis.id;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final clientVM = Provider.of<ClientViewModel>(context, listen: false);
          try {
            final client =
                clientVM.clients.firstWhere((c) => c.id == devis.clientId);
            setState(() => _selectedClient = client);
          } catch (_) {}
        });
      } catch (e) {
        _numeroCtrl.text = "Erreur Devis";
      }
    }
    // Cas 3 : Création Avoir depuis Facture
    else if (widget.sourceFactureId != null) {
      final factureVM = Provider.of<FactureViewModel>(context, listen: false);
      try {
        final source = factureVM.factures
            .firstWhere((f) => f.id == widget.sourceFactureId);
        _typeFacture = 'avoir';
        _numeroCtrl.text = "Brouillon Avoir";
        _objetCtrl.text = "Avoir sur facture ${source.numeroFacture}";
        _notesCtrl.text = source.notesPubliques ?? "";
        _conditionsCtrl.text = source.conditionsReglement;
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
        _factureSourceId = source.id;
        _devisSourceId = source.devisSourceId;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final clientVM = Provider.of<ClientViewModel>(context, listen: false);
          try {
            final client =
                clientVM.clients.firstWhere((c) => c.id == source.clientId);
            setState(() => _selectedClient = client);
          } catch (_) {}
        });
      } catch (e) {
        _numeroCtrl.text = "Erreur Source";
      }
    }
    // Cas 4 : Nouvelle Facture Vierge
    else {
      _conditionsCtrl.text = "Paiement à réception";
      _numeroCtrl.text = "Brouillon";
      _typeFacture = 'standard';
    }

    // Force refresh PDF on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = Provider.of<FactureViewModel>(context, listen: false);
      final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);
      vm.forceRefreshFacturePdf(
          _buildFactureFromState(), _selectedClient, entVM.profil,
          isTvaApplicable: entVM.isTvaApplicable);
    });
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _objetCtrl.dispose();
    _notesCtrl.dispose();
    _conditionsCtrl.dispose();
    _bonCommandeCtrl.dispose();
    _motifAvoirCtrl.dispose();
    super.dispose();
  }

  // --- BUILD OBJECT ---
  Facture _buildFactureFromState() {
    final isTva = Provider.of<EntrepriseViewModel>(context, listen: false)
        .isTvaApplicable;

    final totalHt = _lignes.fold(Decimal.zero, (sum, l) => sum + l.totalLigne);

    final remiseAmount =
        CalculationsUtils.calculateCharges(totalHt, _remiseTaux);
    final netCommercial = totalHt - remiseAmount;

    // TVA uniquement si l'entreprise est assujettie
    Decimal totalTvaRemisee = Decimal.zero;
    if (isTva) {
      final totalTva =
          _lignes.fold(Decimal.zero, (sum, l) => sum + l.montantTva);
      totalTvaRemisee =
          totalTva - CalculationsUtils.calculateCharges(totalTva, _remiseTaux);
    }

    final netAPayer = netCommercial + totalTvaRemisee;

    return Facture(
      id: widget.id,
      userId: SupabaseConfig.userId,
      numeroFacture: _numeroCtrl.text,
      objet: _objetCtrl.text,
      clientId: _selectedClient?.id ?? "temp-client",
      devisSourceId: _devisSourceId,
      factureSourceId: _factureSourceId ?? widget.sourceFactureId,
      parentDocumentId: _parentDocumentId,
      dateEmission: _dateEmission,
      dateEcheance: _dateEcheance,
      statut: _statut,
      type: _typeFacture,
      avancementGlobal: _avancementGlobal,
      totalHt: totalHt,
      totalTva: totalTvaRemisee,
      totalTtc: netAPayer,
      remiseTaux: _remiseTaux,
      acompteDejaRegle: _acompteDejaRegle,
      conditionsReglement: _conditionsCtrl.text,
      notesPubliques: _notesCtrl.text,
      numeroBonCommande:
          _bonCommandeCtrl.text.isNotEmpty ? _bonCommandeCtrl.text : null,
      motifAvoir: _motifAvoirCtrl.text.isNotEmpty ? _motifAvoirCtrl.text : null,
      lignes: _lignes,
      chiffrage: _chiffrage,
      paiements: _paiements,
      signatureUrl: _signatureUrl,
      dateSignature: _dateSignature,
    );
  }

  void _onStepContinue() {
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    } else {
      _sauvegarder();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _sauvegarderEtFinaliser() async {
    // Sauvegarde d'abord, puis finalise
    final savedId = await _sauvegarderEtRetournerId();
    if (savedId == null || !mounted) return;

    final vm = Provider.of<FactureViewModel>(context, listen: false);
    final factureToFinalize = _buildFactureFromState().copyWith(id: savedId);
    final success = await vm.finaliserFacture(factureToFinalize);

    if (!mounted) return;

    if (success) {
      await vm.clearFactureDraft(widget.id);
      if (mounted) {
        context.go('/app/factures');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Facture validée !")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erreur validation")));
    }
  }

  /// Sauvegarde la facture et retourne l'ID (null si erreur)
  Future<String?> _sauvegarderEtRetournerId() async {
    if (_formKey.currentState?.validate() == false) {
      return null;
    }

    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner un client")));
      return null;
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

    if (!mounted) {
      return null;
    }
    setState(() => _isLoading = false);

    if (success) {
      // Récupérer l'ID de la facture sauvegardée
      // Si c'est un update, on a déjà l'ID; si c'est un add, il faut le retrouver
      if (widget.id != null) {
        return widget.id;
      }
      // Pour un ajout, la dernière facture ajoutée est la première de la liste
      final factures = vm.factures;
      if (factures.isNotEmpty) {
        return factures.first.id;
      }
    }
    return null;
  }

  Future<void> _sauvegarder() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    // Global validation check
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
      await vm.clearFactureDraft(widget.id);
      if (mounted) {
        context.go('/app/factures');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Facture enregistrée !")));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de l'enregistrement")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draftData = _buildFactureFromState();
    final vm = Provider.of<FactureViewModel>(context);
    final entVM = Provider.of<EntrepriseViewModel>(context);
    // Auto Update PDF
    vm.triggerFacturePdfUpdate(draftData, _selectedClient, entVM.profil,
        isTvaApplicable: entVM.isTvaApplicable);

    return SplitEditorScaffold(
      title: widget.id == null ? "Nouvelle Facture" : "Modifier Facture",
      draftData: draftData,
      draftType: 'facture',
      // Bind PDF
      pdfData: vm.currentPdfData,
      isPdfLoading: vm.isGeneratingPdf,
      isRealTime: vm.isRealTimePreviewEnabled,
      onToggleRealTime: (val) {
        vm.toggleRealTimePreview(val);
        if (val) {
          vm.triggerFacturePdfUpdate(draftData, _selectedClient, entVM.profil,
              isTvaApplicable: entVM.isTvaApplicable);
        }
      },
      onRefreshPdf: () {
        vm.forceRefreshFacturePdf(draftData, _selectedClient, entVM.profil,
            isTvaApplicable: entVM.isTvaApplicable);
      },
      onSave: _sauvegarder,
      isSaving: _isLoading,
      editorForm: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 3 ? 'TERMINER' : 'SUIVANT'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('RETOUR'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Client'),
            content: Step1Client(
              selectedClient: _selectedClient,
              onClientChanged: (c) => setState(() => _selectedClient = c),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Détails'),
            content: Step2Details(
              objetCtrl: _objetCtrl,
              notesCtrl: _notesCtrl,
              bonCommandeCtrl: _bonCommandeCtrl,
              motifAvoirCtrl: _motifAvoirCtrl,
              isAvoir: _typeFacture == 'avoir',
              dateEmission: _dateEmission,
              dateEcheance: _dateEcheance,
              onDatesChanged: (em, ech) => setState(() {
                _dateEmission = em;
                _dateEcheance = ech;
              }),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Lignes'),
            content: Step3Lignes(
              lignes: _lignes,
              onLignesChanged: (l) => setState(() => _lignes = l),
              isSituation: _typeFacture == 'situation',
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Validation'),
            content: Step4Validation(
              facture: draftData,
              onFinalise: _sauvegarderEtFinaliser,
            ),
            isActive: _currentStep >= 3,
            state: _currentStep == 3 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }
}
