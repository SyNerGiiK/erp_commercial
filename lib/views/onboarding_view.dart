import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../models/entreprise_model.dart';
import '../models/enums/entreprise_enums.dart';
import '../utils/validation_utils.dart';
import '../viewmodels/entreprise_viewmodel.dart';

/// Assistant d'onboarding première connexion – 4 étapes.
///
/// Étape 1 : Identité (nom entreprise, gérant, SIRET, type)
/// Étape 2 : Coordonnées (adresse, CP, ville, email, téléphone)
/// Étape 3 : Bancaire (IBAN, BIC) + TVA
/// Étape 4 : Logo + confirmation
///
/// À la sauvegarde, les mentions légales sont auto-générées.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  final ImagePicker _picker = ImagePicker();

  // ── Contrôleurs ──
  final _nomEntController = TextEditingController();
  final _nomGerantController = TextEditingController();
  final _siretController = TextEditingController();
  final _adresseController = TextEditingController();
  final _cpController = TextEditingController();
  final _villeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();

  TypeEntreprise _typeEntreprise = TypeEntreprise.microEntrepreneur;
  bool _tvaApplicable = false;

  bool _isSaving = false;

  @override
  void dispose() {
    _nomEntController.dispose();
    _nomGerantController.dispose();
    _siretController.dispose();
    _adresseController.dispose();
    _cpController.dispose();
    _villeController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    super.dispose();
  }

  void _next() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _save();
      }
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);

    // Générer les mentions légales automatiquement
    final mentions = vm.getLegalMentionsSuggestion(
      _typeEntreprise,
      tvaApplicable: _tvaApplicable,
      estImmatricule: false,
    );

    final profil = ProfilEntreprise(
      id: vm.profil?.id,
      nomEntreprise: _nomEntController.text.trim(),
      nomGerant: _nomGerantController.text.trim(),
      siret: _siretController.text.trim(),
      adresse: _adresseController.text.trim(),
      codePostal: _cpController.text.trim(),
      ville: _villeController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telController.text.trim(),
      iban: _ibanController.text.trim(),
      bic: _bicController.text.trim(),
      typeEntreprise: _typeEntreprise,
      tvaApplicable: _tvaApplicable,
      mentionsLegales: mentions,
    );

    final success = await vm.saveProfil(profil);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      context.go('/app/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la sauvegarde")),
      );
    }
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    // On doit d'abord sauvegarder le profil pour avoir un ID
    if (vm.profil?.id == null) {
      // Pre-save minimal profile
      final tempProfil = ProfilEntreprise(
        nomEntreprise: _nomEntController.text.trim(),
        nomGerant: _nomGerantController.text.trim(),
        siret: _siretController.text.trim(),
        adresse: _adresseController.text.trim(),
        codePostal: _cpController.text.trim(),
        ville: _villeController.text.trim(),
        email: _emailController.text.trim(),
      );
      await vm.saveProfil(tempProfil);
      if (!mounted) return;
    }

    final success = await vm.uploadImage(image, 'logo');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? "Logo ajouté !" : "Erreur lors de l'upload"),
    ));
    setState(() {});
  }

  // ────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header gradient ──
            _buildHeader(),

            // ── Progress ──
            _buildStepper(),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),

            // ── Navigation buttons ──
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const titles = [
      "Votre entreprise",
      "Vos coordonnées",
      "Facturation",
      "Finition",
    ];
    const subtitles = [
      "Commençons par les informations essentielles",
      "Pour vos devis et factures",
      "Paramètres bancaires et TVA",
      "Logo et confirmation",
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Étape ${_currentStep + 1} / 4",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            titles[_currentStep],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitles[_currentStep],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Identity();
      case 1:
        return _buildStep2Coordinates();
      case 2:
        return _buildStep3Billing();
      case 3:
        return _buildStep4Finish();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── STEP 1 : Identité ──

  Widget _buildStep1Identity() {
    return Form(
      key: _formKeys[0],
      child: Column(
        children: [
          _field("Nom de l'entreprise *", _nomEntController,
              validator: (v) => ValidationUtils.validateRequired(v, "Le nom")),
          const SizedBox(height: 14),
          _field("Nom du Gérant *", _nomGerantController,
              validator: (v) =>
                  ValidationUtils.validateRequired(v, "Le nom du gérant")),
          const SizedBox(height: 14),
          _field("SIRET (14 chiffres)", _siretController,
              keyboard: TextInputType.number,
              validator: ValidationUtils.validateSiret),
          const SizedBox(height: 14),
          DropdownButtonFormField<TypeEntreprise>(
            initialValue: _typeEntreprise,
            isExpanded: true,
            decoration: _inputDecoration("Type d'entreprise"),
            items: TypeEntreprise.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (v) => setState(() => _typeEntreprise = v!),
          ),
        ],
      ),
    );
  }

  // ── STEP 2 : Coordonnées ──

  Widget _buildStep2Coordinates() {
    return Form(
      key: _formKeys[1],
      child: Column(
        children: [
          _field("Adresse complète *", _adresseController,
              validator: (v) =>
                  ValidationUtils.validateRequired(v, "L'adresse")),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _field("Code Postal *", _cpController,
                    keyboard: TextInputType.number,
                    validator: ValidationUtils.validateCodePostal),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _field("Ville *", _villeController,
                    validator: (v) =>
                        ValidationUtils.validateRequired(v, "La ville")),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _field("Email *", _emailController,
              keyboard: TextInputType.emailAddress,
              validator: ValidationUtils.validateEmailRequired),
          const SizedBox(height: 14),
          _field("Téléphone", _telController,
              keyboard: TextInputType.phone,
              validator: ValidationUtils.validatePhone),
        ],
      ),
    );
  }

  // ── STEP 3 : Facturation ──

  Widget _buildStep3Billing() {
    return Form(
      key: _formKeys[2],
      child: Column(
        children: [
          _field("IBAN", _ibanController),
          const SizedBox(height: 14),
          _field("BIC / SWIFT", _bicController),
          const SizedBox(height: 20),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text("Assujetti à la TVA"),
            subtitle: Text(
              _tvaApplicable
                  ? "TVA collectée et déductible"
                  : "Franchise en base (art. 293 B du CGI)",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            value: _tvaApplicable,
            activeTrackColor: AppTheme.primary,
            onChanged: (v) => setState(() => _tvaApplicable = v),
          ),
        ],
      ),
    );
  }

  // ── STEP 4 : Logo & Confirmation ──

  Widget _buildStep4Finish() {
    final vm = Provider.of<EntrepriseViewModel>(context);
    final logoUrl = vm.profil?.logoUrl;

    return Form(
      key: _formKeys[3],
      child: Column(
        children: [
          // Logo
          GestureDetector(
            onTap: _pickLogo,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
              child: logoUrl == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded,
                            size: 28, color: Colors.grey.shade500),
                        const SizedBox(height: 4),
                        Text("Ajouter un logo",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          // Récapitulatif
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Récapitulatif",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  const SizedBox(height: 12),
                  _recap("Entreprise", _nomEntController.text),
                  _recap("Gérant", _nomGerantController.text),
                  _recap("SIRET", _siretController.text),
                  _recap("Type", _typeEntreprise.label),
                  _recap("Adresse",
                      "${_adresseController.text}, ${_cpController.text} ${_villeController.text}"),
                  _recap("Email", _emailController.text),
                  if (_telController.text.isNotEmpty)
                    _recap("Tél.", _telController.text),
                  if (_ibanController.text.isNotEmpty)
                    _recap("IBAN", _ibanController.text),
                  _recap("TVA", _tvaApplicable ? "Assujetti" : "Franchise"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            "Vous pourrez modifier ces informations à tout moment\ndans Paramètres > Mon Entreprise.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _recap(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Boutons ──

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _back,
              child: const Text("Précédent"),
            ),
          const Spacer(),
          if (_currentStep < 3)
            ElevatedButton(
              onPressed: _next,
              child: const Text("Suivant"),
            )
          else
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _next,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSaving ? "Enregistrement..." : "Terminer"),
            ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
