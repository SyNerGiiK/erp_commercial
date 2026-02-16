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

class _ParametresViewState extends State<ParametresView> {
  final _formKey = GlobalKey<FormState>();

  // State
  StatutEntrepreneur _statut = StatutEntrepreneur.artisan;
  TypeActiviteMicro _activite = TypeActiviteMicro.mixte;
  bool _versementLiberatoire = false;
  bool _accreActive = false;
  int _accreAnnee = 1;

  // Controllers (Read Only / Override)
  late TextEditingController _tauxVenteCtrl;
  late TextEditingController _tauxPrestaBICCtrl;
  late TextEditingController _tauxPrestaBNCCtrl;
  late TextEditingController _tauxCfpVenteCtrl;
  late TextEditingController _tauxCfpPrestaCtrl;
  late TextEditingController _tauxCfpLiberalCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadData();
  }

  void _initControllers() {
    _tauxVenteCtrl = TextEditingController();
    _tauxPrestaBICCtrl = TextEditingController();
    _tauxPrestaBNCCtrl = TextEditingController();
    _tauxCfpVenteCtrl = TextEditingController();
    _tauxCfpPrestaCtrl = TextEditingController();
    _tauxCfpLiberalCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tauxVenteCtrl.dispose();
    _tauxPrestaBICCtrl.dispose();
    _tauxPrestaBNCCtrl.dispose();
    _tauxCfpVenteCtrl.dispose();
    _tauxCfpPrestaCtrl.dispose();
    _tauxCfpLiberalCtrl.dispose();
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
    setState(() {
      _statut = c.statut;
      _activite = c.typeActivite;
      _versementLiberatoire = c.versementLiberatoire;
      _accreActive = c.accreActive;
      _accreAnnee = c.accreAnnee;
    });

    _tauxVenteCtrl.text = c.tauxMicroVente.toString();
    _tauxPrestaBICCtrl.text = c.tauxMicroPrestationBIC.toString();
    _tauxPrestaBNCCtrl.text = c.tauxMicroPrestationBNC.toString();

    _tauxCfpVenteCtrl.text = c.tauxCfpVente.toString();
    _tauxCfpPrestaCtrl.text = c.tauxCfpPrestation.toString();
    _tauxCfpLiberalCtrl.text = c.tauxCfpLiberal.toString();
  }

  void _applyStatutDefaults(StatutEntrepreneur statut) {
    // Applique les taux CFP par défaut selon le statut
    Decimal cfpRate = Decimal.zero;
    switch (statut) {
      case StatutEntrepreneur.artisan:
        cfpRate = Decimal.parse('0.3');
        break;
      case StatutEntrepreneur.commercant:
        cfpRate = Decimal.parse('0.1');
        break;
      case StatutEntrepreneur.liberal:
        cfpRate = Decimal.parse('0.2');
        break;
    }
    _tauxCfpVenteCtrl.text = cfpRate.toString();
    _tauxCfpPrestaCtrl.text = cfpRate.toString();
    _tauxCfpLiberalCtrl.text = cfpRate.toString();
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    final config = UrssafConfig(
      id: Provider.of<UrssafViewModel>(context, listen: false).config?.id,
      userId: "", // Will be handled by Repo
      statut: _statut,
      typeActivite: _activite,
      versementLiberatoire: _versementLiberatoire,
      accreActive: _accreActive,
      accreAnnee: _accreAnnee,

      // Taux Overrides
      tauxMicroVente: Decimal.tryParse(_tauxVenteCtrl.text),
      tauxMicroPrestationBIC: Decimal.tryParse(_tauxPrestaBICCtrl.text),
      tauxMicroPrestationBNC: Decimal.tryParse(_tauxPrestaBNCCtrl.text),
      tauxCfpVente: Decimal.tryParse(_tauxCfpVenteCtrl.text),
      tauxCfpPrestation: Decimal.tryParse(_tauxCfpPrestaCtrl.text),
      tauxCfpLiberal: Decimal.tryParse(_tauxCfpLiberalCtrl.text),
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
      appBar: AppBar(title: const Text("Configuration Micro-Entreprise")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("1. Votre Statut", [
                _buildStatutSelector(),
              ]),
              _buildSection("2. Votre Activité", [
                _buildActiviteSelector(),
              ]),
              _buildSection("3. Options Fiscales & Sociales", [
                SwitchListTile(
                  title: const Text("Versement Libératoire de l'Impôt"),
                  subtitle: const Text(
                      "Paiement de l'IR en même temps que les cotisations"),
                  value: _versementLiberatoire,
                  onChanged: (v) => setState(() => _versementLiberatoire = v),
                ),
                SwitchListTile(
                  title: const Text("Bénéficiaire ACRE"),
                  subtitle: const Text(
                      "Exonération partielle des charges en début d'activité"),
                  value: _accreActive,
                  onChanged: (v) => setState(() => _accreActive = v),
                ),
                if (_accreActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<int>(
                      initialValue: _accreAnnee,
                      key: ValueKey(_accreAnnee),
                      decoration:
                          const InputDecoration(labelText: "Année ACRE"),
                      items: [1, 2, 3]
                          .map((y) => DropdownMenuItem(
                              value: y, child: Text("Année $y")))
                          .toList(),
                      onChanged: (v) => setState(() => _accreAnnee = v!),
                    ),
                  ),
              ]),
              _buildSection("4. Taux Appliqués (2026)", [
                const Text(
                  "Ces taux sont définis automatiquement selon votre statut, mais vous pouvez les ajuster si nécessaire.",
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                _buildRateRow("Vente (BIC)", _tauxVenteCtrl, _tauxCfpVenteCtrl,
                    UrssafConfig.libVente),
                _buildRateRow("Prestation (BIC)", _tauxPrestaBICCtrl,
                    _tauxCfpPrestaCtrl, UrssafConfig.libBIC),
                _buildRateRow("Prestation (BNC)", _tauxPrestaBNCCtrl,
                    _tauxCfpLiberalCtrl, UrssafConfig.libBNC),
              ]),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sauvegarder,
                  icon: const Icon(Icons.save),
                  label: const Text("Enregistrer la configuration"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatutSelector() {
    return Column(
      children: StatutEntrepreneur.values.map((s) {
        String label = "";
        String desc = "";
        switch (s) {
          case StatutEntrepreneur.artisan:
            label = "Artisan";
            desc = "Métiers manuels, fabrication... (CFP 0.3%)";
            break;
          case StatutEntrepreneur.commercant:
            label = "Commerçant";
            desc = "Achat/Revente... (CFP 0.1%)";
            break;
          case StatutEntrepreneur.liberal:
            label = "Libéral";
            desc = "Consultant, développeur... (CFP 0.2%)";
            break;
        }
        return RadioListTile<StatutEntrepreneur>(
          title: Text(label),
          subtitle: Text(desc),
          value: s,
          // ignore: deprecated_member_use
          groupValue: _statut,
          // ignore: deprecated_member_use
          onChanged: (v) {
            setState(() => _statut = v!);
            _applyStatutDefaults(v);
          },
        );
      }).toList(),
    );
  }

  Widget _buildActiviteSelector() {
    return DropdownButtonFormField<TypeActiviteMicro>(
      initialValue: _activite,
      key: ValueKey(_activite),
      decoration: const InputDecoration(
        labelText: "Type d'activité principale",
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: TypeActiviteMicro.mixte,
          child: Text("Mixte (Vente + Services)"),
        ),
        DropdownMenuItem(
          value: TypeActiviteMicro.bicVente,
          child: Text("Vente de Marchandises (BIC)"),
        ),
        DropdownMenuItem(
          value: TypeActiviteMicro.bicPrestation,
          child: Text("Prestation de Services (BIC)"),
        ),
        DropdownMenuItem(
          value: TypeActiviteMicro.bncPrestation,
          child: Text("Prestation de Services (BNC)"),
        ),
      ],
      onChanged: (v) => setState(() => _activite = v!),
    );
  }

  Widget _buildRateRow(String label, TextEditingController socialCtrl,
      TextEditingController cfpCtrl, Decimal libRate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: socialCtrl,
              decoration:
                  const InputDecoration(labelText: "Social %", isDense: true),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: cfpCtrl,
              decoration:
                  const InputDecoration(labelText: "CFP %", isDense: true),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          if (_versementLiberatoire)
            Expanded(
              flex: 2,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: "Lib. %",
                    isDense: true,
                    border: OutlineInputBorder()),
                child: Text("${libRate.toString()}%",
                    style: const TextStyle(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }
}
