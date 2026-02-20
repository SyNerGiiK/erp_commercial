import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';

import '../config/theme.dart';
import '../models/entreprise_model.dart';
import '../models/enums/entreprise_enums.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dialogs/signature_dialog.dart';

class SettingsRootView extends StatefulWidget {
  const SettingsRootView({super.key});

  @override
  State<SettingsRootView> createState() => _SettingsRootViewState();
}

class _SettingsRootViewState extends State<SettingsRootView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // === Expansion Panel State ===
  final List<bool> _expanded = [false, false, false];

  // === SECTION 1: Entreprise ===
  final _nomEntController = TextEditingController();
  final _nomGerantController = TextEditingController();
  final _adresseController = TextEditingController();
  final _cpController = TextEditingController();
  final _villeController = TextEditingController();
  final _siretController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();

  // === SECTION 2: Fiscalité & Légal ===
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();
  final _mentionsController = TextEditingController();
  TypeEntreprise _typeEntreprise = TypeEntreprise.microEntrepreneurService;
  RegimeFiscal? _regimeFiscal;
  CaisseRetraite _caisseRetraite = CaisseRetraite.ssi;
  FrequenceCotisation _frequenceCotisation = FrequenceCotisation.mensuelle;
  bool _tvaApplicable = false;

  // === SECTION 3: Préférences d'Édition ===
  PdfTheme _pdfTheme = PdfTheme.moderne;
  ModeFacturation _modeFacturation = ModeFacturation.global;
  bool _modeDiscret = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);
    await entVM.fetchProfil();

    if (!mounted) return;

    final p = entVM.profil;
    if (p != null) {
      _nomEntController.text = p.nomEntreprise;
      _nomGerantController.text = p.nomGerant;
      _adresseController.text = p.adresse;
      _cpController.text = p.codePostal;
      _villeController.text = p.ville;
      _siretController.text = p.siret;
      _emailController.text = p.email;
      _telController.text = p.telephone ?? '';
      _ibanController.text = p.iban ?? '';
      _bicController.text = p.bic ?? '';
      _mentionsController.text = p.mentionsLegales ?? '';
      setState(() {
        _typeEntreprise = p.typeEntreprise;
        _regimeFiscal = p.regimeFiscal;
        _caisseRetraite = p.caisseRetraite;
        _frequenceCotisation = p.frequenceCotisation;
        _tvaApplicable = p.tvaApplicable;
        _pdfTheme = p.pdfTheme;
        _modeFacturation = p.modeFacturation;
        _modeDiscret = p.modeDiscret;
      });
    }
  }

  @override
  void dispose() {
    _nomEntController.dispose();
    _nomGerantController.dispose();
    _adresseController.dispose();
    _cpController.dispose();
    _villeController.dispose();
    _siretController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    _mentionsController.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);

    final profil = ProfilEntreprise(
      id: entVM.profil?.id,
      nomEntreprise: _nomEntController.text.trim(),
      nomGerant: _nomGerantController.text.trim(),
      adresse: _adresseController.text.trim(),
      codePostal: _cpController.text.trim(),
      ville: _villeController.text.trim(),
      siret: _siretController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telController.text.trim(),
      iban: _ibanController.text.trim(),
      bic: _bicController.text.trim(),
      frequenceCotisation: _frequenceCotisation,
      mentionsLegales: _mentionsController.text.trim(),
      logoUrl: entVM.profil?.logoUrl,
      signatureUrl: entVM.profil?.signatureUrl,
      typeEntreprise: _typeEntreprise,
      regimeFiscal: _regimeFiscal,
      caisseRetraite: _caisseRetraite,
      tvaApplicable: _tvaApplicable,
      pdfTheme: _pdfTheme,
      modeFacturation: _modeFacturation,
      modeDiscret: _modeDiscret,
    );

    try {
      await entVM.saveProfil(profil);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paramètres enregistrés !")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    final success = await vm.uploadImage(image, 'logo');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? "Logo mis à jour !" : "Erreur upload")));
  }

  Future<void> _drawAndUploadSignature() async {
    final Uint8List? signatureBytes = await showDialog(
      context: context,
      builder: (_) => const SignatureDialog(),
    );
    if (signatureBytes == null || !mounted) return;

    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    final success = await vm.uploadSignatureBytes(signatureBytes);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? "Signature mise à jour !" : "Erreur upload")));
  }

  @override
  Widget build(BuildContext context) {
    final entVM = Provider.of<EntrepriseViewModel>(context);
    final profil = entVM.profil;

    return BaseScreen(
      menuIndex: 9,
      title: "Paramètres",
      child: entVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickAndUploadLogo,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: profil?.logoUrl != null
                            ? NetworkImage(profil!.logoUrl!)
                            : null,
                        child: profil?.logoUrl == null
                            ? const Icon(Icons.add_a_photo,
                                size: 28, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                      child: Text("Logo Entreprise",
                          style: TextStyle(color: Colors.grey, fontSize: 12))),
                  const SizedBox(height: 20),

                  // === ACCORDÉON ===
                  ExpansionPanelList(
                    expansionCallback: (index, isExpanded) {
                      setState(() => _expanded[index] = isExpanded);
                    },
                    children: [
                      ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _expanded[0],
                        headerBuilder: (_, isExpanded) => const ListTile(
                          leading:
                              Icon(Icons.business, color: AppTheme.primary),
                          title: Text("Mon Entreprise",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Infos générales, Contact, Signature"),
                        ),
                        body: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildEntrepriseSection(profil),
                        ),
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _expanded[1],
                        headerBuilder: (_, isExpanded) => const ListTile(
                          leading: Icon(Icons.account_balance,
                              color: AppTheme.primary),
                          title: Text("Fiscalité & Légal",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("SIRET, TVA, URSSAF, ACRE, RIB"),
                        ),
                        body: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildFiscaliteSection(),
                        ),
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _expanded[2],
                        headerBuilder: (_, isExpanded) => const ListTile(
                          leading: Icon(Icons.palette, color: AppTheme.primary),
                          title: Text("Préférences d'Édition",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle:
                              Text("Mode facturation, Thème PDF, Privacy"),
                        ),
                        body: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildPreferencesSection(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _sauvegarder,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(
                          _isSaving ? "Enregistrement..." : "ENREGISTRER TOUT",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // === SECTION 1: MON ENTREPRISE ===
  Widget _buildEntrepriseSection(ProfilEntreprise? profil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
            label: "Nom de l'entreprise (Raison Sociale)",
            controller: _nomEntController,
            validator: (v) => v!.isEmpty ? "Nom requis" : null),
        const SizedBox(height: 10),
        CustomTextField(
            label: "Nom du Gérant",
            controller: _nomGerantController,
            validator: (v) => v!.isEmpty ? "Nom requis" : null),
        const SizedBox(height: 10),
        CustomTextField(
            label: "Email contact",
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v!.isEmpty ? "Email requis" : null),
        const SizedBox(height: 10),
        CustomTextField(
            label: "Téléphone",
            controller: _telController,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 20),
        const Text("Adresse",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary)),
        const SizedBox(height: 10),
        CustomTextField(
            label: "Adresse complète",
            controller: _adresseController,
            validator: (v) => v!.isEmpty ? "Requis" : null),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: CustomTextField(
                  label: "Code Postal",
                  controller: _cpController,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Requis" : null)),
          const SizedBox(width: 10),
          Expanded(
              flex: 2,
              child: CustomTextField(
                  label: "Ville",
                  controller: _villeController,
                  validator: (v) => v!.isEmpty ? "Requis" : null)),
        ]),
        const SizedBox(height: 20),
        const Text("Signature / Tampon",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary)),
        const SizedBox(height: 10),
        Center(
          child: Column(children: [
            if (profil?.signatureUrl != null)
              Container(
                height: 80,
                width: 180,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white),
                child:
                    Image.network(profil!.signatureUrl!, fit: BoxFit.contain),
              ),
            ElevatedButton.icon(
              onPressed: _drawAndUploadSignature,
              icon: const Icon(Icons.draw),
              label: const Text("Dessiner ma Signature"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.textDark,
                  side: const BorderSide(color: Colors.grey)),
            ),
          ]),
        ),
      ],
    );
  }

  // === SECTION 2: FISCALITÉ & LÉGAL ===
  Widget _buildFiscaliteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
            label: "SIRET",
            controller: _siretController,
            validator: (v) => v!.isEmpty ? "SIRET requis" : null),
        const SizedBox(height: 10),
        DropdownButtonFormField<TypeEntreprise>(
          key: ValueKey(_typeEntreprise),
          initialValue: _typeEntreprise,
          decoration: InputDecoration(
            labelText: "Statut Juridique",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: TypeEntreprise.values
              .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
              .toList(),
          onChanged: (v) {
            setState(() {
              _typeEntreprise = v!;
              if (_mentionsController.text.isEmpty) {
                final vm =
                    Provider.of<EntrepriseViewModel>(context, listen: false);
                _mentionsController.text = vm.getLegalMentionsSuggestion(v);
              }
            });
          },
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text("Assujetti à la TVA"),
          subtitle: const Text("Désactivé = Franchise en base (Art. 293 B)"),
          value: _tvaApplicable,
          onChanged: (v) => setState(() => _tvaApplicable = v),
        ),
        const Divider(height: 30),

        // === CONFIGURATION URSSAF — Renvoi vers page dédiée ===
        const Text("Configuration URSSAF & Cotisations",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary)),
        const SizedBox(height: 8),
        const Text(
          "Statut, activité, taux cotisations, TFC, versement libératoire, ACRE, synchronisation API.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/app/config_urssaf'),
            icon: const Icon(Icons.tune),
            label: const Text("Configurer URSSAF"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ),

        const Divider(height: 30),
        const Text("Coordonnées Bancaires",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary)),
        const SizedBox(height: 10),
        CustomTextField(label: "IBAN", controller: _ibanController),
        const SizedBox(height: 10),
        CustomTextField(label: "BIC", controller: _bicController),
        const SizedBox(height: 10),
        DropdownButtonFormField<FrequenceCotisation>(
          key: ValueKey(_frequenceCotisation),
          initialValue: _frequenceCotisation,
          decoration: InputDecoration(
            labelText: "Fréquence déclaration URSSAF",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: FrequenceCotisation.values
              .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
              .toList(),
          onChanged: (v) => setState(() => _frequenceCotisation = v!),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          label: "Mentions Légales (pied de page)",
          controller: _mentionsController,
          maxLines: 3,
        ),
      ],
    );
  }

  // === SECTION 3: PRÉFÉRENCES D'ÉDITION ===
  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mode de Facturation",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<ModeFacturation>(
          key: ValueKey(_modeFacturation),
          initialValue: _modeFacturation,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: ModeFacturation.values
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(m.label),
                        Text(m.description,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _modeFacturation = v!),
        ),
        const SizedBox(height: 20),
        const Text("Thème PDF", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RadioGroup<PdfTheme>(
          groupValue: _pdfTheme,
          onChanged: (v) {
            if (v != null) {
              setState(() => _pdfTheme = v);
            }
          },
          child: Column(
            children: PdfTheme.values
                .map((theme) => RadioListTile<PdfTheme>(
                      title: Text(theme.label),
                      subtitle: Text(theme.description),
                      value: theme,
                      activeColor: AppTheme.primary,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text("Mode Discret (Privacy)"),
          subtitle:
              const Text("Masquer le résumé financier détaillé dans l'éditeur"),
          value: _modeDiscret,
          onChanged: (v) => setState(() => _modeDiscret = v),
        ),
      ],
    );
  }
}
