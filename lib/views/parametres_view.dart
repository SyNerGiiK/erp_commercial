import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/urssaf_viewmodel.dart';
import '../models/urssaf_model.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';
import '../config/theme.dart';

class ParametresView extends StatefulWidget {
  const ParametresView({super.key});

  @override
  State<ParametresView> createState() => _ParametresViewState();
}

class _ParametresViewState extends State<ParametresView> {
  final _formKey = GlobalKey<FormState>();

  final _tauxPrestaCtrl = TextEditingController();
  final _tauxVenteCtrl = TextEditingController();
  final _tauxImpotServiceCtrl = TextEditingController();
  final _tauxImpotVenteCtrl = TextEditingController();
  final _tauxCfpServiceCtrl = TextEditingController();
  final _tauxCfpVenteCtrl = TextEditingController();
  final _plafondServiceCtrl = TextEditingController();
  final _plafondVenteCtrl = TextEditingController();

  bool _accreActive = false;
  String _typeEntreprise = 'artisan';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final vm = Provider.of<UrssafViewModel>(context, listen: false);
    await vm.loadConfig();
    if (vm.config != null) {
      _populateFields(vm.config!);
    }
  }

  void _populateFields(UrssafConfig c) {
    _tauxPrestaCtrl.text = c.tauxPrestation.toString();
    _tauxVenteCtrl.text = c.tauxVente.toString();
    _tauxImpotServiceCtrl.text = c.tauxImpotService.toString();
    _tauxImpotVenteCtrl.text = c.tauxImpotVente.toString();
    _tauxCfpServiceCtrl.text = c.tauxCfpService.toString();
    _tauxCfpVenteCtrl.text = c.tauxCfpVente.toString();
    _plafondServiceCtrl.text = c.plafondCaService.toString();
    _plafondVenteCtrl.text = c.plafondCaVente.toString();
    setState(() {
      _accreActive = c.accreActive;
      _typeEntreprise = c.typeEntreprise;
    });
  }

  void _updateRates(bool isAccre) {
    if (isAccre) {
      _tauxPrestaCtrl.text = UrssafConfig.tauxPrestationAcre.toString();
      _tauxVenteCtrl.text = UrssafConfig.tauxVenteAcre.toString();
    } else {
      _tauxPrestaCtrl.text = UrssafConfig.tauxPrestationStandard.toString();
      _tauxVenteCtrl.text = UrssafConfig.tauxVenteStandard.toString();
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    final config = UrssafConfig(
      id: Provider.of<UrssafViewModel>(context, listen: false).config?.id,
      accreActive: _accreActive,
      typeEntreprise: _typeEntreprise,
      tauxPrestation: Decimal.tryParse(_tauxPrestaCtrl.text),
      tauxVente: Decimal.tryParse(_tauxVenteCtrl.text),
      tauxImpotService: Decimal.tryParse(_tauxImpotServiceCtrl.text),
      tauxImpotVente: Decimal.tryParse(_tauxImpotVenteCtrl.text),
      tauxCfpService: Decimal.tryParse(_tauxCfpServiceCtrl.text),
      tauxCfpVente: Decimal.tryParse(_tauxCfpVenteCtrl.text),
      plafondCaService: Decimal.tryParse(_plafondServiceCtrl.text),
      plafondCaVente: Decimal.tryParse(_plafondVenteCtrl.text),
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      menuIndex: 9, // CORRECTION: Index Paramètres
      title: "Configuration URSSAF",
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text("Bénéficiaire de l'ACCRE ?"),
                subtitle:
                    const Text("Réduction de charges les premières années"),
                value: _accreActive,
                onChanged: (v) {
                  setState(() => _accreActive = v);
                  _updateRates(v);
                },
              ),
              const Divider(),
              const SizedBox(height: 10),
              _buildSection("Taux de Cotisations (%)"),
              Row(children: [
                Expanded(
                    child: CustomTextField(
                        label: "Prestation Service",
                        controller: _tauxPrestaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomTextField(
                        label: "Vente Marchandise",
                        controller: _tauxVenteCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
              ]),
              const SizedBox(height: 20),
              _buildSection("Impôt Libératoire (%)"),
              Row(children: [
                Expanded(
                    child: CustomTextField(
                        label: "Service",
                        controller: _tauxImpotServiceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomTextField(
                        label: "Vente",
                        controller: _tauxImpotVenteCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
              ]),
              const SizedBox(height: 20),
              _buildSection("Formation Pro (CFP) (%)"),
              Row(children: [
                Expanded(
                    child: CustomTextField(
                        label: "Service",
                        controller: _tauxCfpServiceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomTextField(
                        label: "Vente",
                        controller: _tauxCfpVenteCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
              ]),
              const SizedBox(height: 20),
              _buildSection("Plafonds CA (€)"),
              Row(children: [
                Expanded(
                    child: CustomTextField(
                        label: "Plafond Service",
                        controller: _plafondServiceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomTextField(
                        label: "Plafond Vente",
                        controller: _plafondVenteCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
              ]),
              const SizedBox(height: 30),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _sauvegarder,
                      child: const Text("ENREGISTRER CONFIG"))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              fontSize: 16)),
    );
  }
}
