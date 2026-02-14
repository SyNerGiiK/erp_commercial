import 'dart:io';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../models/entreprise_model.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerProfilExistants();
    });
  }

  void _chargerProfilExistants() async {
    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    await vm.fetchProfil();
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

    final p = ProfilEntreprise(
      id: vm.profil?.id,
      userId: vm.profil?.userId,
      nomEntreprise: _nomEntController.text,
      nomGerant: _nomGerantController.text,
      adresse: _adresseController.text,
      codePostal: _cpController.text,
      ville: _villeController.text,
      siret: _siretController.text,
      email: _emailController.text,
      telephone: _telController.text,
      iban: _ibanController.text,
      bic: _bicController.text,
      frequenceCotisation: _frequenceCotisation,
      mentionsLegales: _mentionsController.text,
      logoUrl: vm.profil?.logoUrl, // On garde l'existant
      signatureUrl: vm.profil?.signatureUrl, // On garde l'existant
    );

    final success = await vm.saveProfil(p);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour avec succès")),
      );
      context.pop();
    }
  }

  Future<void> _pickAndUpload(String type) async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null && mounted) {
      final vm = Provider.of<EntrepriseViewModel>(context, listen: false);

      // On sauvegarde d'abord le formulaire textuel pour ne pas perdre les données si l'ID n'existe pas encore
      if (vm.profil == null) {
        await _sauvegarder();
      }

      final success = await vm.uploadImage(image, type);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$type mis à jour !")),
        );
      }
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
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 8),
                    const Center(
                        child: Text("Appuyer pour modifier le logo",
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey))),
                    const SizedBox(height: 20),
                    const Text("Informations Générales",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primary)),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: "Nom commercial / Raison Sociale",
                      controller: _nomEntController,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: "Nom du Gérant",
                      controller: _nomGerantController,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: CustomTextField(
                        label: "SIRET",
                        controller: _siretController,
                        validator: (v) => v!.isEmpty ? "Requis" : null,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: CustomTextField(
                              label: "Email Pro",
                              controller: _emailController)),
                    ]),
                    const SizedBox(height: 20),
                    const Text("Coordonnées",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primary)),
                    const SizedBox(height: 10),
                    CustomTextField(
                        label: "Adresse", controller: _adresseController),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: CustomTextField(
                              label: "Code Postal", controller: _cpController)),
                      const SizedBox(width: 10),
                      Expanded(
                          flex: 2,
                          child: CustomTextField(
                              label: "Ville", controller: _villeController)),
                    ]),
                    const SizedBox(height: 10),
                    CustomTextField(
                        label: "Téléphone", controller: _telController),
                    const SizedBox(height: 20),
                    const Text("Bancaire & Administratif",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primary)),
                    const SizedBox(height: 10),
                    CustomTextField(label: "IBAN", controller: _ibanController),
                    const SizedBox(height: 10),
                    CustomTextField(label: "BIC", controller: _bicController),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _frequenceCotisation,
                      decoration:
                          const InputDecoration(labelText: "Cotisation URSSAF"),
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
                    const Text("Mentions Légales (Bas de page PDF)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    CustomTextField(
                      label: "Ex: Dispensé d'immatriculation...",
                      controller: _mentionsController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          const Text("Signature / Cachet (Pour PDF)",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _pickAndUpload('signature'),
                            child: Container(
                              height: 100,
                              width: 200,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  color: Colors.grey.shade100),
                              child: (profil?.signatureUrl != null)
                                  ? Image.network(profil!.signatureUrl!,
                                      fit: BoxFit.contain)
                                  : const Center(
                                      child: Icon(Icons.add_a_photo)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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
