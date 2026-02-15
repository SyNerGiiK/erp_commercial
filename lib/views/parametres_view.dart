import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';

import '../models/urssaf_model.dart';
import '../models/enums/entreprise_enums.dart';
import '../viewmodels/urssaf_viewmodel.dart';

class ParametresView extends StatefulWidget {
  const ParametresView({super.key});

  @override
  State<ParametresView> createState() => _ParametresViewState();
}

class _ParametresViewState extends State<ParametresView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // État
  bool _accreActive = false;
  int _accreAnnee = 1;

  // Controllers - Micro
  final _tauxMicroVenteStdCtrl = TextEditingController();
  final _tauxMicroServiceBICStdCtrl = TextEditingController();
  final _tauxMicroServiceBNCStdCtrl = TextEditingController();
  final _tauxMicroLiberalCIPAVStdCtrl = TextEditingController();
  final _tauxMicroMeublesStdCtrl = TextEditingController();

  final _tauxMicroVenteAcreCtrl = TextEditingController();
  final _tauxMicroServiceBICAcreCtrl = TextEditingController();
  final _tauxMicroServiceBNCAcreCtrl = TextEditingController();
  final _tauxMicroLiberalCIPAVAcreCtrl = TextEditingController();
  final _tauxMicroMeublesAcreCtrl = TextEditingController();

  final _tauxCfpMicroVenteCtrl = TextEditingController();
  final _tauxCfpMicroServiceCtrl = TextEditingController();
  final _tauxCfpMicroLiberalCtrl = TextEditingController();

  final _plafondCaMicroVenteCtrl = TextEditingController();
  final _plafondCaMicroServiceCtrl = TextEditingController();
  final _seuilTvaMicroVenteCtrl = TextEditingController();
  final _seuilTvaMicroServiceCtrl = TextEditingController();

  // Controllers - TNS
  final _abattementTNSCtrl = TextEditingController();
  final _abattementMinTNSCtrl = TextEditingController();
  final _abattementMaxTNSCtrl = TextEditingController();
  final _tauxMaladieTNSMaxCtrl = TextEditingController();
  final _tauxIJTNSCtrl = TextEditingController();
  final _tauxRetraiteBaseTNST1Ctrl = TextEditingController();
  final _tauxRetraiteBaseTNST2Ctrl = TextEditingController();
  final _tauxRetraiteCompTNST1Ctrl = TextEditingController();
  final _tauxRetraiteCompTNST2Ctrl = TextEditingController();
  final _tauxInvaliditeDecesTNSCtrl = TextEditingController();
  final _tauxAllocFamTNSMaxCtrl = TextEditingController();
  final _tauxCsgCrdsTNSCtrl = TextEditingController();
  final _tauxCfpArtisanCtrl = TextEditingController();
  final _tauxCfpCommercantCtrl = TextEditingController();

  // Controllers - Assimilé Salarié
  final _tauxVieillesseSalT1Ctrl = TextEditingController();
  final _tauxVieillesseSalT2Ctrl = TextEditingController();
  final _tauxRetraiteCompSalT1Ctrl = TextEditingController();
  final _tauxRetraiteCompSalT2Ctrl = TextEditingController();
  final _tauxAPECSalCtrl = TextEditingController();
  final _tauxCSGDeductibleCtrl = TextEditingController();
  final _tauxCSGNonDeductibleCtrl = TextEditingController();
  final _tauxCRDSCtrl = TextEditingController();
  final _tauxMaladiePatronal1Ctrl = TextEditingController();
  final _tauxMaladiePatronal2Ctrl = TextEditingController();
  final _tauxVieillessePatT1Ctrl = TextEditingController();
  final _tauxVieillessePatT2Ctrl = TextEditingController();
  final _tauxAllocFamPatronal1Ctrl = TextEditingController();
  final _tauxAllocFamPatronal2Ctrl = TextEditingController();
  final _tauxChomagePatronalCtrl = TextEditingController();
  final _tauxRetraiteCompPatT1Ctrl = TextEditingController();
  final _tauxRetraiteCompPatT2Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose tous les controllers
    _tauxMicroVenteStdCtrl.dispose();
    _tauxMicroServiceBICStdCtrl.dispose();
    _tauxMicroServiceBNCStdCtrl.dispose();
    _tauxMicroLiberalCIPAVStdCtrl.dispose();
    _tauxMicroMeublesStdCtrl.dispose();
    _tauxMicroVenteAcreCtrl.dispose();
    _tauxMicroServiceBICAcreCtrl.dispose();
    _tauxMicroServiceBNCAcreCtrl.dispose();
    _tauxMicroLiberalCIPAVAcreCtrl.dispose();
    _tauxMicroMeublesAcreCtrl.dispose();
    _tauxCfpMicroVenteCtrl.dispose();
    _tauxCfpMicroServiceCtrl.dispose();
    _tauxCfpMicroLiberalCtrl.dispose();
    _plafondCaMicroVenteCtrl.dispose();
    _plafondCaMicroServiceCtrl.dispose();
    _seuilTvaMicroVenteCtrl.dispose();
    _seuilTvaMicroServiceCtrl.dispose();
    _abattementTNSCtrl.dispose();
    _abattementMinTNSCtrl.dispose();
    _abattementMaxTNSCtrl.dispose();
    _tauxMaladieTNSMaxCtrl.dispose();
    _tauxIJTNSCtrl.dispose();
    _tauxRetraiteBaseTNST1Ctrl.dispose();
    _tauxRetraiteBaseTNST2Ctrl.dispose();
    _tauxRetraiteCompTNST1Ctrl.dispose();
    _tauxRetraiteCompTNST2Ctrl.dispose();
    _tauxInvaliditeDecesTNSCtrl.dispose();
    _tauxAllocFamTNSMaxCtrl.dispose();
    _tauxCsgCrdsTNSCtrl.dispose();
    _tauxCfpArtisanCtrl.dispose();
    _tauxCfpCommercantCtrl.dispose();
    _tauxVieillesseSalT1Ctrl.dispose();
    _tauxVieillesseSalT2Ctrl.dispose();
    _tauxRetraiteCompSalT1Ctrl.dispose();
    _tauxRetraiteCompSalT2Ctrl.dispose();
    _tauxAPECSalCtrl.dispose();
    _tauxCSGDeductibleCtrl.dispose();
    _tauxCSGNonDeductibleCtrl.dispose();
    _tauxCRDSCtrl.dispose();
    _tauxMaladiePatronal1Ctrl.dispose();
    _tauxMaladiePatronal2Ctrl.dispose();
    _tauxVieillessePatT1Ctrl.dispose();
    _tauxVieillessePatT2Ctrl.dispose();
    _tauxAllocFamPatronal1Ctrl.dispose();
    _tauxAllocFamPatronal2Ctrl.dispose();
    _tauxChomagePatronalCtrl.dispose();
    _tauxRetraiteCompPatT1Ctrl.dispose();
    _tauxRetraiteCompPatT2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final vm = Provider.of<UrssafViewModel>(context, listen: false);
    await vm.loadConfig();
    if (vm.config != null) {
      _populateFields(vm.config!);
    }
  }

  void _populateFields(UrssafConfig c) {
    // Micro
    _tauxMicroVenteStdCtrl.text = UrssafConfig.tauxMicroVenteStd.toString();
    _tauxMicroServiceBICStdCtrl.text =
        UrssafConfig.tauxMicroServiceBICStd.toString();
    _tauxMicroServiceBNCStdCtrl.text =
        UrssafConfig.tauxMicroServiceBNCStd.toString();
    _tauxMicroLiberalCIPAVStdCtrl.text =
        UrssafConfig.tauxMicroLiberalCIPAVStd.toString();
    _tauxMicroMeublesStdCtrl.text = UrssafConfig.tauxMicroMeublesStd.toString();

    _tauxMicroVenteAcreCtrl.text = UrssafConfig.tauxMicroVenteAcre.toString();
    _tauxMicroServiceBICAcreCtrl.text =
        UrssafConfig.tauxMicroServiceBICAcre.toString();
    _tauxMicroServiceBNCAcreCtrl.text =
        UrssafConfig.tauxMicroServiceBNCAcre.toString();
    _tauxMicroLiberalCIPAVAcreCtrl.text =
        UrssafConfig.tauxMicroLiberalCIPAVAcre.toString();
    _tauxMicroMeublesAcreCtrl.text =
        UrssafConfig.tauxMicroMeublesAcre.toString();

    _tauxCfpMicroVenteCtrl.text = c.tauxCfpMicroVente.toString();
    _tauxCfpMicroServiceCtrl.text = c.tauxCfpMicroService.toString();
    _tauxCfpMicroLiberalCtrl.text = c.tauxCfpMicroLiberal.toString();

    _plafondCaMicroVenteCtrl.text = c.plafondCaMicroVente.toString();
    _plafondCaMicroServiceCtrl.text = c.plafondCaMicroService.toString();
    _seuilTvaMicroVenteCtrl.text = c.seuilTvaMicroVente.toString();
    _seuilTvaMicroServiceCtrl.text = c.seuilTvaMicroService.toString();

    // TNS
    _abattementTNSCtrl.text = c.abattementTNS.toString();
    _abattementMinTNSCtrl.text = c.abattementMinTNS.toString();
    _abattementMaxTNSCtrl.text = c.abattementMaxTNS.toString();
    _tauxMaladieTNSMaxCtrl.text = c.tauxMaladieTNSMax.toString();
    _tauxIJTNSCtrl.text = c.tauxIJTNS.toString();
    _tauxRetraiteBaseTNST1Ctrl.text = c.tauxRetraiteBaseTNST1.toString();
    _tauxRetraiteBaseTNST2Ctrl.text = c.tauxRetraiteBaseTNST2.toString();
    _tauxRetraiteCompTNST1Ctrl.text = c.tauxRetraiteCompTNST1.toString();
    _tauxRetraiteCompTNST2Ctrl.text = c.tauxRetraiteCompTNST2.toString();
    _tauxInvaliditeDecesTNSCtrl.text = c.tauxInvaliditeDecesTNS.toString();
    _tauxAllocFamTNSMaxCtrl.text = c.tauxAllocFamTNSMax.toString();
    _tauxCsgCrdsTNSCtrl.text = c.tauxCsgCrdsTNS.toString();
    _tauxCfpArtisanCtrl.text = c.tauxCfpArtisan.toString();
    _tauxCfpCommercantCtrl.text = c.tauxCfpCommercant.toString();

    // Assimilé Salarié
    _tauxVieillesseSalT1Ctrl.text = c.tauxVieillesseSalT1.toString();
    _tauxVieillesseSalT2Ctrl.text = c.tauxVieillesseSalT2.toString();
    _tauxRetraiteCompSalT1Ctrl.text = c.tauxRetraiteCompSalT1.toString();
    _tauxRetraiteCompSalT2Ctrl.text = c.tauxRetraiteCompSalT2.toString();
    _tauxAPECSalCtrl.text = c.tauxAPECSal.toString();
    _tauxCSGDeductibleCtrl.text = c.tauxCSGDeductible.toString();
    _tauxCSGNonDeductibleCtrl.text = c.tauxCSGNonDeductible.toString();
    _tauxCRDSCtrl.text = c.tauxCRDS.toString();
    _tauxMaladiePatronal1Ctrl.text = c.tauxMaladiePatronal1.toString();
    _tauxMaladiePatronal2Ctrl.text = c.tauxMaladiePatronal2.toString();
    _tauxVieillessePatT1Ctrl.text = c.tauxVieillessePatT1.toString();
    _tauxVieillessePatT2Ctrl.text = c.tauxVieillessePatT2.toString();
    _tauxAllocFamPatronal1Ctrl.text = c.tauxAllocFamPatronal1.toString();
    _tauxAllocFamPatronal2Ctrl.text = c.tauxAllocFamPatronal2.toString();
    _tauxChomagePatronalCtrl.text = c.tauxChomagePatronal.toString();
    _tauxRetraiteCompPatT1Ctrl.text = c.tauxRetraiteCompPatT1.toString();
    _tauxRetraiteCompPatT2Ctrl.text = c.tauxRetraiteCompPatT2.toString();

    setState(() {
      _accreActive = c.accreActive;
      _accreAnnee = c.accreAnnee;
    });
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    final config = UrssafConfig(
      id: Provider.of<UrssafViewModel>(context, listen: false).config?.id,
      accreActive: _accreActive,
      accreAnnee: _accreAnnee,
      // Micro
      tauxCfpMicroVente: Decimal.tryParse(_tauxCfpMicroVenteCtrl.text),
      tauxCfpMicroService: Decimal.tryParse(_tauxCfpMicroServiceCtrl.text),
      tauxCfpMicroLiberal: Decimal.tryParse(_tauxCfpMicroLiberalCtrl.text),
      plafondCaMicroVente: Decimal.tryParse(_plafondCaMicroVenteCtrl.text),
      plafondCaMicroService: Decimal.tryParse(_plafondCaMicroServiceCtrl.text),
      seuilTvaMicroVente: Decimal.tryParse(_seuilTvaMicroVenteCtrl.text),
      seuilTvaMicroService: Decimal.tryParse(_seuilTvaMicroServiceCtrl.text),
      // TNS
      abattementTNS: Decimal.tryParse(_abattementTNSCtrl.text),
      abattementMinTNS: Decimal.tryParse(_abattementMinTNSCtrl.text),
      abattementMaxTNS: Decimal.tryParse(_abattementMaxTNSCtrl.text),
      tauxMaladieTNSMax: Decimal.tryParse(_tauxMaladieTNSMaxCtrl.text),
      tauxIJTNS: Decimal.tryParse(_tauxIJTNSCtrl.text),
      tauxRetraiteBaseTNST1: Decimal.tryParse(_tauxRetraiteBaseTNST1Ctrl.text),
      tauxRetraiteBaseTNST2: Decimal.tryParse(_tauxRetraiteBaseTNST2Ctrl.text),
      tauxRetraiteCompTNST1: Decimal.tryParse(_tauxRetraiteCompTNST1Ctrl.text),
      tauxRetraiteCompTNST2: Decimal.tryParse(_tauxRetraiteCompTNST2Ctrl.text),
      tauxInvaliditeDecesTNS:
          Decimal.tryParse(_tauxInvaliditeDecesTNSCtrl.text),
      tauxAllocFamTNSMax: Decimal.tryParse(_tauxAllocFamTNSMaxCtrl.text),
      tauxCsgCrdsTNS: Decimal.tryParse(_tauxCsgCrdsTNSCtrl.text),
      tauxCfpArtisan: Decimal.tryParse(_tauxCfpArtisanCtrl.text),
      tauxCfpCommercant: Decimal.tryParse(_tauxCfpCommercantCtrl.text),
      // Assimilé
      tauxVieillesseSalT1: Decimal.tryParse(_tauxVieillesseSalT1Ctrl.text),
      tauxVieillesseSalT2: Decimal.tryParse(_tauxVieillesseSalT2Ctrl.text),
      tauxRetraiteCompSalT1: Decimal.tryParse(_tauxRetraiteCompSalT1Ctrl.text),
      tauxRetraiteCompSalT2: Decimal.tryParse(_tauxRetraiteCompSalT2Ctrl.text),
      tauxAPECSal: Decimal.tryParse(_tauxAPECSalCtrl.text),
      tauxCSGDeductible: Decimal.tryParse(_tauxCSGDeductibleCtrl.text),
      tauxCSGNonDeductible: Decimal.tryParse(_tauxCSGNonDeductibleCtrl.text),
      tauxCRDS: Decimal.tryParse(_tauxCRDSCtrl.text),
      tauxMaladiePatronal1: Decimal.tryParse(_tauxMaladiePatronal1Ctrl.text),
      tauxMaladiePatronal2: Decimal.tryParse(_tauxMaladiePatronal2Ctrl.text),
      tauxVieillessePatT1: Decimal.tryParse(_tauxVieillessePatT1Ctrl.text),
      tauxVieillessePatT2: Decimal.tryParse(_tauxVieillessePatT2Ctrl.text),
      tauxAllocFamPatronal1: Decimal.tryParse(_tauxAllocFamPatronal1Ctrl.text),
      tauxAllocFamPatronal2: Decimal.tryParse(_tauxAllocFamPatronal2Ctrl.text),
      tauxChomagePatronal: Decimal.tryParse(_tauxChomagePatronalCtrl.text),
      tauxRetraiteCompPatT1: Decimal.tryParse(_tauxRetraiteCompPatT1Ctrl.text),
      tauxRetraiteCompPatT2: Decimal.tryParse(_tauxRetraiteCompPatT2Ctrl.text),
    );

    try {
      await Provider.of<UrssafViewModel>(context, listen: false)
          .saveConfig(config);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Configuration enregistrée !")));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur : $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres URSSAF"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: "Général"),
            Tab(icon: Icon(Icons.store), text: "Micro-Entreprise"),
            Tab(icon: Icon(Icons.business), text: "TNS"),
            Tab(icon: Icon(Icons.work), text: "Assimilé Salarié"),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneralTab(),
            _buildMicroTab(),
            _buildTNSTab(),
            _buildAssimileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _sauvegarder,
          icon: const Icon(Icons.save),
          label: const Text("Enregistrer"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Constantes France 2026",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text("PASS 2026"),
                  trailing: Text("${UrssafConfig.pass2026} €",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: const Text("SMIC Mensuel Brut 2026"),
                  trailing: Text("${UrssafConfig.smicMensuel2026} €",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ACCRE / ACRE",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("ACCRE Active"),
                  value: _accreActive,
                  onChanged: (v) => setState(() => _accreActive = v),
                ),
                if (_accreActive) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    key: ValueKey(_accreAnnee),
                    initialValue: _accreAnnee,
                    decoration: const InputDecoration(
                      labelText: "Année ACCRE",
                      border: OutlineInputBorder(),
                    ),
                    items: [1, 2, 3].map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text("Année $year"),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _accreAnnee = v!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMicroTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          "Taux Standard",
          "Les taux micro-entrepreneur standards (lecture seule, définis par la loi)",
          [
            _buildReadOnlyField("Vente marchandises", _tauxMicroVenteStdCtrl),
            _buildReadOnlyField("Service BIC", _tauxMicroServiceBICStdCtrl),
            _buildReadOnlyField("Service BNC", _tauxMicroServiceBNCStdCtrl),
            _buildReadOnlyField("Libéral CIPAV", _tauxMicroLiberalCIPAVStdCtrl),
            _buildReadOnlyField("Location meublée", _tauxMicroMeublesStdCtrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Taux ACCRE",
          "Taux réduits si ACCRE active (lecture seule)",
          [
            _buildReadOnlyField("Vente ACCRE", _tauxMicroVenteAcreCtrl),
            _buildReadOnlyField(
                "Service BIC ACCRE", _tauxMicroServiceBICAcreCtrl),
            _buildReadOnlyField(
                "Service BNC ACCRE", _tauxMicroServiceBNCAcreCtrl),
            _buildReadOnlyField(
                "Libéral CIPAV ACCRE", _tauxMicroLiberalCIPAVAcreCtrl),
            _buildReadOnlyField(
                "Location meublée ACCRE", _tauxMicroMeublesAcreCtrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Contribution Formation Professionnelle (CFP)",
          "Taux CFP additionnels (modifiables)",
          [
            _buildDecimalField("CFP Vente (%)", _tauxCfpMicroVenteCtrl),
            _buildDecimalField("CFP Service (%)", _tauxCfpMicroServiceCtrl),
            _buildDecimalField("CFP Libéral (%)", _tauxCfpMicroLiberalCtrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Plafonds & Seuils",
          "Plafonds CA et seuils TVA (modifiables)",
          [
            _buildDecimalField(
                "Plafond CA Vente (€)", _plafondCaMicroVenteCtrl),
            _buildDecimalField(
                "Plafond CA Service (€)", _plafondCaMicroServiceCtrl),
            _buildDecimalField("Seuil TVA Vente (€)", _seuilTvaMicroVenteCtrl),
            _buildDecimalField(
                "Seuil TVA Service (€)", _seuilTvaMicroServiceCtrl),
          ],
        ),
      ],
    );
  }

  Widget _buildTNSTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          "Abattement TNS",
          "Abattement de 26% sur le revenu professionnel",
          [
            _buildDecimalField("Taux Abattement (%)", _abattementTNSCtrl),
            _buildDecimalField(
                "Abattement Min (% PASS)", _abattementMinTNSCtrl),
            _buildDecimalField(
                "Abattement Max (% PASS)", _abattementMaxTNSCtrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Maladie & Indemnités Journalières",
          "Cotisations maladie et IJ TNS",
          [
            _buildDecimalField(
                "Maladie Maternité Max (%)", _tauxMaladieTNSMaxCtrl),
            _buildDecimalField("Indemnités Journalières (%)", _tauxIJTNSCtrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Retraite Base TNS",
          "Retraite de base artisan/commerçant",
          [
            _buildDecimalField(
                "Tranche 1 (0-PASS) (%)", _tauxRetraiteBaseTNST1Ctrl),
            _buildDecimalField(
                "Tranche 2 (>PASS) (%)", _tauxRetraiteBaseTNST2Ctrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Retraite Complémentaire TNS",
          "RCI (Retraite Complémentaire Indépendants)",
          [
            _buildDecimalField(
                "Tranche 1 (0-41k€) (%)", _tauxRetraiteCompTNST1Ctrl),
            _buildDecimalField(
                "Tranche 2 (41k-206k€) (%)", _tauxRetraiteCompTNST2Ctrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Autres Cotisations TNS",
          "Invalidité-Décès, Allocations Familiales, CSG-CRDS",
          [
            _buildDecimalField(
                "Invalidité-Décès (%)", _tauxInvaliditeDecesTNSCtrl),
            _buildDecimalField(
                "Allocations Familiales Max (%)", _tauxAllocFamTNSMaxCtrl),
            _buildDecimalField("CSG-CRDS (%)", _tauxCsgCrdsTNSCtrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "CFP TNS",
          "Contribution Formation Professionnelle",
          [
            _buildDecimalField("CFP Artisan (%)", _tauxCfpArtisanCtrl),
            _buildDecimalField("CFP Commerçant (%)", _tauxCfpCommercantCtrl),
          ],
        ),
      ],
    );
  }

  Widget _buildAssimileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          "Cotisations Salariales",
          "Part salariale (déduite de la rémunération)",
          [
            _buildDecimalField("Vieillesse T1 (%)", _tauxVieillesseSalT1Ctrl),
            _buildDecimalField("Vieillesse T2 (%)", _tauxVieillesseSalT2Ctrl),
            _buildDecimalField(
                "Retraite Comp T1 (%)", _tauxRetraiteCompSalT1Ctrl),
            _buildDecimalField(
                "Retraite Comp T2 (%)", _tauxRetraiteCompSalT2Ctrl),
            _buildDecimalField("APEC (%)", _tauxAPECSalCtrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "CSG-CRDS Salarié",
          "Contributions sociales sur la rémunération",
          [
            _buildDecimalField("CSG Déductible (%)", _tauxCSGDeductibleCtrl),
            _buildDecimalField(
                "CSG Non Déductible (%)", _tauxCSGNonDeductibleCtrl),
            _buildDecimalField("CRDS (%)", _tauxCRDSCtrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Cotisations Patronales - Maladie",
          "Part employeur maladie-maternité",
          [
            _buildDecimalField("Maladie Taux 1 (%)", _tauxMaladiePatronal1Ctrl),
            _buildDecimalField("Maladie Taux 2 (%)", _tauxMaladiePatronal2Ctrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Cotisations Patronales - Retraite",
          "Part employeur vieillesse et retraite complémentaire",
          [
            _buildDecimalField(
                "Vieillesse Pat T1 (%)", _tauxVieillessePatT1Ctrl),
            _buildDecimalField(
                "Vieillesse Pat T2 (%)", _tauxVieillessePatT2Ctrl),
            _buildDecimalField(
                "Retraite Comp Pat T1 (%)", _tauxRetraiteCompPatT1Ctrl),
            _buildDecimalField(
                "Retraite Comp Pat T2 (%)", _tauxRetraiteCompPatT2Ctrl),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "Autres Cotisations Patronales",
          "Allocations familiales et chômage",
          [
            _buildDecimalField(
                "Alloc Fam Pat 1 (%)", _tauxAllocFamPatronal1Ctrl),
            _buildDecimalField(
                "Alloc Fam Pat 2 (%)", _tauxAllocFamPatronal2Ctrl),
            _buildDecimalField(
                "Chômage Patronal (%)", _tauxChomagePatronalCtrl),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String subtitle, List<Widget> fields) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildDecimalField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.isEmpty) return "Requis";
          final val = Decimal.tryParse(v);
          if (val == null) return "Nombre invalide";
          if (val < Decimal.zero) return "Doit être >= 0";
          return null;
        },
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "$label (lecture seule)",
          border: const OutlineInputBorder(),
        ),
        enabled: false,
      ),
    );
  }
}
