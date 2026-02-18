import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';

import '../../../models/devis_model.dart';
import '../../../models/client_model.dart';
import '../../../models/chiffrage_model.dart';
import '../../../viewmodels/devis_viewmodel.dart';
import '../../../viewmodels/client_viewmodel.dart';
import '../../../viewmodels/entreprise_viewmodel.dart';
import '../../../config/supabase_config.dart';
import '../../../widgets/split_editor_scaffold.dart';
import '../../../utils/calculations_utils.dart';
import '../../../utils/format_utils.dart';

// Steps
import 'steps/step1_client.dart';
import 'steps/step2_details.dart';
import 'steps/step3_lignes.dart';
import 'steps/step4_validation.dart';

class DevisStepperView extends StatefulWidget {
  final String? id;
  final Devis? devisAModifier;

  const DevisStepperView({
    super.key,
    this.id,
    this.devisAModifier,
  });

  @override
  State<DevisStepperView> createState() => _DevisStepperViewState();
}

class _DevisStepperViewState extends State<DevisStepperView> {
  int _currentStep = 0;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _numeroCtrl;
  late TextEditingController _objetCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _conditionsCtrl;

  Client? _selectedClient;
  DateTime _dateEmission = DateTime.now();
  DateTime _dateValidite = DateTime.now().add(const Duration(days: 30));

  List<LigneDevis> _lignes = [];
  List<LigneChiffrage> _chiffrage = [];

  String? _signatureUrl;
  DateTime? _dateSignature;
  String _statut = 'brouillon';
  Decimal _remiseTaux = Decimal.zero;

  // Acompte calculé dynamiquement ou fixe?
  // Dans AjoutDevisView: _acompteAmount was calculated.
  // Here we need to store it or calc it. Devis model has acompteMontant.
  Decimal _acomptePercentage = Decimal.fromInt(30);

  @override
  void initState() {
    super.initState();
    _numeroCtrl = TextEditingController();
    _objetCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _conditionsCtrl = TextEditingController();

    _initData();
  }

  void _initData() {
    if (widget.devisAModifier != null) {
      final d = widget.devisAModifier!;
      _numeroCtrl.text = d.numeroDevis;
      _objetCtrl.text = d.objet;
      _notesCtrl.text = d.notesPubliques ?? '';
      _conditionsCtrl.text = d.conditionsReglement;
      _dateEmission = d.dateEmission;
      _dateValidite = d.dateValidite;
      _lignes = List.from(d.lignes);
      _chiffrage = List.from(d.chiffrage);
      _statut = d.statut;
      _remiseTaux = d.remiseTaux;
      _signatureUrl = d.signatureUrl;
      _dateSignature = d.dateSignature;
      _acomptePercentage = d.acomptePercentage;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clientVM = Provider.of<ClientViewModel>(context, listen: false);
        try {
          final client = clientVM.clients.firstWhere((c) => c.id == d.clientId);
          setState(() => _selectedClient = client);
        } catch (_) {}
      });
    } else {
      _conditionsCtrl.text = "Paiement à réception";
      _numeroCtrl.text = "Brouillon";
    }

    // Check Draft logic similar to AjoutDevisView?
    // Ideally yes, but sticking to basics first.
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _objetCtrl.dispose();
    _notesCtrl.dispose();
    _conditionsCtrl.dispose();
    super.dispose();
  }

  Devis _buildDevisFromState() {
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

    // Acompte Calculation
    final acompteMontant =
        ((netCommercial * _acomptePercentage) / Decimal.fromInt(100))
            .toDecimal();

    return Devis(
      id: widget.id,
      userId: SupabaseConfig.userId,
      numeroDevis: _numeroCtrl.text,
      objet: _objetCtrl.text,
      clientId: _selectedClient?.id ?? "temp-client",
      dateEmission: _dateEmission,
      dateValidite: _dateValidite,
      statut: _statut,
      totalHt: totalHt,
      totalTva: totalTvaRemisee,
      totalTtc: netAPayer,
      remiseTaux: _remiseTaux,
      acompteMontant: acompteMontant,
      acomptePercentage: _acomptePercentage,
      conditionsReglement: _conditionsCtrl.text,
      notesPubliques: _notesCtrl.text,
      lignes: _lignes,
      chiffrage: _chiffrage,
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

  Future<void> _sauvegarder() async {
    if (_formKey.currentState?.validate() == false) return;
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
      await vm.clearDevisDraft(widget.id);
      if (mounted) {
        context.go('/app/devis');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Devis enregistré !")));
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
    final draftData = _buildDevisFromState();
    final vm = Provider.of<DevisViewModel>(context);
    final entVM = Provider.of<EntrepriseViewModel>(context);

    vm.triggerDevisPdfUpdate(draftData, _selectedClient, entVM.profil,
        isTvaApplicable: entVM.isTvaApplicable);

    return SplitEditorScaffold(
      title: widget.id == null ? "Nouveau Devis" : "Modifier Devis",
      draftData: draftData,
      draftType: 'devis',
      pdfData: vm.currentPdfData,
      isPdfLoading: vm.isGeneratingPdf,
      isRealTime: vm.isRealTimePreviewEnabled,
      onToggleRealTime: (val) {
        vm.toggleRealTimePreview(val);
        if (val) {
          vm.triggerDevisPdfUpdate(draftData, _selectedClient, entVM.profil,
              isTvaApplicable: entVM.isTvaApplicable);
        }
      },
      onRefreshPdf: () {
        vm.forceRefreshDevisPdf(draftData, _selectedClient, entVM.profil,
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
            content: DevisStep1Client(
              selectedClient: _selectedClient,
              onClientChanged: (c) => setState(() => _selectedClient = c),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Détails'),
            content: DevisStep2Details(
              objetCtrl: _objetCtrl,
              notesCtrl: _notesCtrl,
              conditionsCtrl: _conditionsCtrl,
              dateEmission: _dateEmission,
              dateValidite: _dateValidite,
              onDatesChanged: (em, val) => setState(() {
                _dateEmission = em;
                _dateValidite = val;
              }),
              acomptePercentage: _acomptePercentage,
              acompteMontant: _buildDevisFromState().acompteMontant,
              onAcompteChanged: (val) =>
                  setState(() => _acomptePercentage = val),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Lignes'),
            content: DevisStep3Lignes(
              lignes: _lignes,
              chiffrage: _chiffrage,
              remiseTaux: _remiseTaux,
              onLignesChanged: (l) => setState(() => _lignes = l),
              onChiffrageChanged: (c) => setState(() => _chiffrage = c),
              readOnly: _statut == 'signe' || _statut == 'annule',
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Validation'),
            content: DevisStep4Validation(
              devis: draftData,
            ),
            isActive: _currentStep >= 3,
            state: _currentStep == 3 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }
}
