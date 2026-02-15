import 'package:flutter/foundation.dart'; // Pour kIsWeb
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

class ProfilEntrepriseView extends StatefulWidget {
  const ProfilEntrepriseView({super.key});

  @override
  State<ProfilEntrepriseView> createState() => _ProfilEntrepriseViewState();
}

class _ProfilEntrepriseViewState extends State<ProfilEntrepriseView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _nomEntController = TextEditingController();
  final _nomGerantController = TextEditingController();
  final _adresseController = TextEditingController();
  final _cpController = TextEditingController();
  final _villeController = TextEditingController();
  final _siretController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();
  final _mentionsController = TextEditingController();

  String _frequenceCotisation = 'mois';
  TypeEntreprise _typeEntreprise = TypeEntreprise.microEntrepreneurServiceBIC;
  RegimeFiscal? _regimeFiscal;
  CaisseRetraite _caisseRetraite = CaisseRetraite.ssi;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerProfil();
    });
  }

  void _chargerProfil() async {
    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    await vm.fetchProfil();

    if (!mounted) return;

    final p = vm.profil;
    if (p != null) {
      _nomEntController.text = p.nomEntreprise;
      _nomGerantController.text = p.nomGerant;
      _adresseController.text = p.adresse;
      _cpController.text = p.codePostal;
      _villeController.text = p.ville;
      _siretController.text = p.siret;
      _emailController.text = p.email;
      _telController.text = p.telephone ?? "";
      _ibanController.text = p.iban ?? "";
      _bicController.text = p.bic ?? "";
      _mentionsController.text = p.mentionsLegales ?? "";
      setState(() {
        _frequenceCotisation = p.frequenceCotisation;
        _typeEntreprise = p.typeEntreprise;
        _regimeFiscal = p.regimeFiscal;
        _caisseRetraite = p.caisseRetraite;
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

    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);

    final existingId = vm.profil?.id;
    final existingLogo = vm.profil?.logoUrl;
    final existingSignature = vm.profil?.signatureUrl;

    final profilToSave = ProfilEntreprise(
      id: existingId,
      // userId géré par le Repo
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
      logoUrl: existingLogo,
      signatureUrl: existingSignature,
      typeEntreprise: _typeEntreprise,
      regimeFiscal: _regimeFiscal,
      caisseRetraite: _caisseRetraite,
    );

    final success = await vm.saveProfil(profilToSave);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil enregistré avec succès !")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'enregistrement")));
    }
  }

  Future<void> _pickAndUpload(String type) async {
    // 1. Sélection image (XFile, compatible Web)
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (!mounted) return;

    // 2. Upload via ViewModel
    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    final success = await vm.uploadImage(image, type);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Image mise à jour !")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erreur upload")));
    }
  }

  Future<void> _drawAndUpload() async {
    // 1. Ouvrir le dialog de signature
    // ATTENTION: Il faut importer SignatureDialog (à créer/importer)
    final Uint8List? signatureBytes = await showDialog(
      context: context,
      builder: (context) => const SignatureDialog(),
    );

    if (signatureBytes == null) return;
    if (!mounted) return;

    // 2. Upload via ViewModel
    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    final success = await vm.uploadSignatureBytes(signatureBytes);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature mise à jour !")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erreur upload")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EntrepriseViewModel>(context);
    final profil = vm.profil;

    return BaseScreen(
      menuIndex: 9,
      title: "Mon Entreprise",
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LOGO ZONE
                    Center(
                      child: GestureDetector(
                        onTap: () => _pickAndUpload('logo'),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (profil?.logoUrl != null)
                              ? NetworkImage(profil!.logoUrl!)
                              : null,
                          child: (profil?.logoUrl == null)
                              ? const Icon(Icons.add_a_photo,
                                  size: 30, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text("Logo Entreprise",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 30),

                    // CHAMPS PRINCIPAUX
                    const Text("Identité",
                        style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
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
                        label: "SIRET",
                        controller: _siretController,
                        validator: (v) => v!.isEmpty ? "SIRET requis" : null),
                    const SizedBox(height: 20),

                    // TYPE D'ENTREPRISE
                    DropdownButtonFormField<TypeEntreprise>(
                      key: ValueKey(_typeEntreprise),
                      initialValue: _typeEntreprise,
                      decoration: InputDecoration(
                        labelText: "Type d'entreprise (régime fiscal)",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: TypeEntreprise.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _typeEntreprise = v!),
                    ),
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

                    const SizedBox(height: 30),
                    const Text("Adresse",
                        style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    CustomTextField(
                        label: "Adresse complète",
                        controller: _adresseController,
                        validator: (v) => v!.isEmpty ? "Requis" : null),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomTextField(
                              label: "Code Postal",
                              controller: _cpController,
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? "Requis" : null),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                              label: "Ville",
                              controller: _villeController,
                              validator: (v) => v!.isEmpty ? "Requis" : null),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Text("Facturation & Bancaire",
                        style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    CustomTextField(label: "IBAN", controller: _ibanController),
                    const SizedBox(height: 10),
                    CustomTextField(label: "BIC", controller: _bicController),
                    const SizedBox(height: 20),

                    // CORRECTION DROPDOWN: Utilisation Key+InitialValue
                    DropdownButtonFormField<String>(
                      key: ValueKey(_frequenceCotisation), // Key Stable
                      initialValue: _frequenceCotisation,
                      decoration: InputDecoration(
                        labelText: "Fréquence déclaration URSSAF",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'mois', child: Text("Mensuelle")),
                        DropdownMenuItem(
                            value: 'trimestre', child: Text("Trimestrielle")),
                      ],
                      onChanged: (v) =>
                          setState(() => _frequenceCotisation = v!),
                    ),
                    const SizedBox(height: 20),

                    // RÉGIME FISCAL (Optionnel)
                    DropdownButtonFormField<RegimeFiscal?>(
                      key: ValueKey(_regimeFiscal),
                      initialValue: _regimeFiscal,
                      decoration: InputDecoration(
                        labelText: "Régime fiscal (si différent du type)",
                        hintText: "Déterminé automatiquement",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text("Auto")),
                        ...RegimeFiscal.values.map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            )),
                      ],
                      onChanged: (v) => setState(() => _regimeFiscal = v),
                    ),
                    const SizedBox(height: 20),

                    // CAISSE RETRAITE
                    DropdownButtonFormField<CaisseRetraite>(
                      key: ValueKey(_caisseRetraite),
                      initialValue: _caisseRetraite,
                      decoration: InputDecoration(
                        labelText: "Caisse de retraite",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: CaisseRetraite.values
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.label),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _caisseRetraite = v!),
                    ),

                    const SizedBox(height: 30),
                    const Text("Mentions Légales (Pied de page)",
                        style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    CustomTextField(
                      label: "Texte libre (Ex: TVA non applicable...)",
                      controller: _mentionsController,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),
                    const Text("Signature / Tampon",
                        style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          if (profil?.signatureUrl != null)
                            Container(
                              height: 100,
                              width: 200,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.white),
                              child: Image.network(profil!.signatureUrl!,
                                  fit: BoxFit.contain),
                            ),
                          ElevatedButton.icon(
                            onPressed: _drawAndUpload, // NEW: _drawAndUpload
                            icon: const Icon(Icons.draw), // CHANGED ICON
                            label: const Text("Dessiner ma Signature"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.textDark,
                                side: const BorderSide(color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _sauvegarder,
                        child: const Text("ENREGISTRER LE PROFIL"),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
