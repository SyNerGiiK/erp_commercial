import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../widgets/base_screen.dart';
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
  bool _sourceApi = false;
  DateTime? _lastSyncedAt;

  // Controllers (Read Only / Override)
  late TextEditingController _tauxVenteCtrl;
  late TextEditingController _tauxPrestaBICCtrl;
  late TextEditingController _tauxPrestaBNCCtrl;
  late TextEditingController _tauxCfpVenteCtrl;
  late TextEditingController _tauxCfpPrestaCtrl;
  late TextEditingController _tauxCfpLiberalCtrl;
  late TextEditingController _tauxTfcServiceCtrl;
  late TextEditingController _tauxTfcVenteCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
    SchedulerBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _initControllers() {
    _tauxVenteCtrl = TextEditingController();
    _tauxPrestaBICCtrl = TextEditingController();
    _tauxPrestaBNCCtrl = TextEditingController();
    _tauxCfpVenteCtrl = TextEditingController();
    _tauxCfpPrestaCtrl = TextEditingController();
    _tauxCfpLiberalCtrl = TextEditingController();
    _tauxTfcServiceCtrl = TextEditingController();
    _tauxTfcVenteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tauxVenteCtrl.dispose();
    _tauxPrestaBICCtrl.dispose();
    _tauxPrestaBNCCtrl.dispose();
    _tauxCfpVenteCtrl.dispose();
    _tauxCfpPrestaCtrl.dispose();
    _tauxCfpLiberalCtrl.dispose();
    _tauxTfcServiceCtrl.dispose();
    _tauxTfcVenteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final vm = Provider.of<UrssafViewModel>(context, listen: false);
    await vm.loadConfig();
    if (!mounted) return;
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
      _sourceApi = c.sourceApi;
      _lastSyncedAt = c.lastSyncedAt;
    });

    _tauxVenteCtrl.text = c.tauxMicroVente.toString();
    _tauxPrestaBICCtrl.text = c.tauxMicroPrestationBIC.toString();
    _tauxPrestaBNCCtrl.text = c.tauxMicroPrestationBNC.toString();

    _tauxCfpVenteCtrl.text = c.tauxCfpVente.toString();
    _tauxCfpPrestaCtrl.text = c.tauxCfpPrestation.toString();
    _tauxCfpLiberalCtrl.text = c.tauxCfpLiberal.toString();

    _tauxTfcServiceCtrl.text = c.tauxTfcService.toString();
    _tauxTfcVenteCtrl.text = c.tauxTfcVente.toString();
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

  Future<void> _syncFromApi() async {
    final vm = Provider.of<UrssafViewModel>(context, listen: false);
    final success = await vm.syncFromApi();
    if (!mounted) return;

    if (success && vm.config != null) {
      _populateFields(vm.config!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Taux synchronisés depuis l\'API URSSAF'),
          backgroundColor: AppTheme.accent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.syncMessage ?? 'Échec de la synchronisation'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
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
      sourceApi: _sourceApi,
      lastSyncedAt: _lastSyncedAt,

      // Taux Overrides
      tauxMicroVente: Decimal.tryParse(_tauxVenteCtrl.text),
      tauxMicroPrestationBIC: Decimal.tryParse(_tauxPrestaBICCtrl.text),
      tauxMicroPrestationBNC: Decimal.tryParse(_tauxPrestaBNCCtrl.text),
      tauxCfpVente: Decimal.tryParse(_tauxCfpVenteCtrl.text),
      tauxCfpPrestation: Decimal.tryParse(_tauxCfpPrestaCtrl.text),
      tauxCfpLiberal: Decimal.tryParse(_tauxCfpLiberalCtrl.text),
      tauxTfcService: Decimal.tryParse(_tauxTfcServiceCtrl.text),
      tauxTfcVente: Decimal.tryParse(_tauxTfcVenteCtrl.text),
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
    return Consumer<UrssafViewModel>(
      builder: (context, vm, _) {
        return BaseScreen(
          title: "Configuration Micro-Entreprise",
          menuIndex: -1, // No specific menu item highlighted
          headerActions: [
            IconButton(
              onPressed: vm.isLoading ? null : _syncFromApi,
              icon: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync, color: Colors.white),
              tooltip: 'Synchroniser avec l\'API URSSAF',
            ),
          ],
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bandeau Sync info
                  if (_lastSyncedAt != null || _sourceApi) _buildSyncBanner(),

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
                      onChanged: (v) =>
                          setState(() => _versementLiberatoire = v),
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
                    if (_sourceApi)
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacing12),
                        margin:
                            const EdgeInsets.only(bottom: AppTheme.spacing16),
                        decoration: BoxDecoration(
                          color: AppTheme.infoSoft,
                          borderRadius: AppTheme.borderRadiusSmall,
                          border: Border.all(
                              color: AppTheme.info.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline,
                                size: 16,
                                color: AppTheme.info.withValues(alpha: 0.8)),
                            const SizedBox(width: AppTheme.spacing8),
                            const Expanded(
                              child: Text(
                                "Taux verrouillés — synchronisés depuis l'API URSSAF. "
                                "Passez en mode manuel pour les modifier.",
                                style: TextStyle(
                                    fontSize: 12, color: AppTheme.info),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _sourceApi = false);
                              },
                              child: const Text("Mode manuel",
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text(
                        "Taux définis automatiquement selon votre statut, ajustables si nécessaire.",
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    const SizedBox(height: 16),
                    _buildRateRow("Vente (BIC)", _tauxVenteCtrl,
                        _tauxCfpVenteCtrl, UrssafConfig.libVente),
                    _buildRateRow("Prestation (BIC)", _tauxPrestaBICCtrl,
                        _tauxCfpPrestaCtrl, UrssafConfig.libBIC),
                    _buildRateRow("Prestation (BNC)", _tauxPrestaBNCCtrl,
                        _tauxCfpLiberalCtrl, UrssafConfig.libBNC),
                  ]),
                  _buildSection("5. Taxes Frais de Chambre (TFC)", [
                    const Text(
                      "Taxe applicable aux artisans et commerçants (CMA/CCI).",
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tauxTfcServiceCtrl,
                            readOnly: _sourceApi,
                            decoration: InputDecoration(
                              labelText: "TFC Service %",
                              isDense: true,
                              suffixIcon: _sourceApi
                                  ? const Icon(Icons.lock_outline, size: 16)
                                  : null,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _tauxTfcVenteCtrl,
                            readOnly: _sourceApi,
                            decoration: InputDecoration(
                              labelText: "TFC Vente %",
                              isDense: true,
                              suffixIcon: _sourceApi
                                  ? const Icon(Icons.lock_outline, size: 16)
                                  : null,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
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
      },
    );
  }

  /// Bandeau affichant le statut de synchronisation API
  Widget _buildSyncBanner() {
    final dateStr = _lastSyncedAt != null
        ? DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(_lastSyncedAt!)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing12),
      margin: const EdgeInsets.only(bottom: AppTheme.spacing20),
      decoration: BoxDecoration(
        color: _sourceApi ? AppTheme.accentSoft : AppTheme.warningSoft,
        borderRadius: AppTheme.borderRadiusSmall,
        border: Border.all(
          color: _sourceApi
              ? AppTheme.accent.withValues(alpha: 0.3)
              : AppTheme.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _sourceApi ? Icons.cloud_done : Icons.cloud_off,
            size: 20,
            color: _sourceApi ? AppTheme.accent : AppTheme.warning,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sourceApi
                      ? 'Données API URSSAF Publicodes'
                      : 'Mode manuel — taux modifiables',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _sourceApi ? AppTheme.accent : AppTheme.warning,
                  ),
                ),
                if (dateStr != null)
                  Text(
                    'Dernière synchronisation : $dateStr',
                    style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                  ),
              ],
            ),
          ),
        ],
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
    return RadioGroup<StatutEntrepreneur>(
      groupValue: _statut,
      onChanged: (v) {
        if (v != null) {
          setState(() => _statut = v);
          _applyStatutDefaults(v);
        }
      },
      child: Column(
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
            activeColor: AppTheme.primary,
          );
        }).toList(),
      ),
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
              readOnly: _sourceApi,
              decoration: InputDecoration(
                labelText: "Social %",
                isDense: true,
                suffixIcon: _sourceApi
                    ? const Icon(Icons.lock_outline, size: 16)
                    : null,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: cfpCtrl,
              readOnly: _sourceApi,
              decoration: InputDecoration(
                labelText: "CFP %",
                isDense: true,
                suffixIcon: _sourceApi
                    ? const Icon(Icons.lock_outline, size: 16)
                    : null,
              ),
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
