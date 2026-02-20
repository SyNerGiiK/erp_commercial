import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../config/theme.dart';
import '../models/entreprise_model.dart';
import '../models/enums/entreprise_enums.dart';
import '../utils/validation_utils.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dialogs/signature_dialog.dart';

/// Vue profil entreprise complète — toutes les données du [ProfilEntreprise].
/// Sections : Identité, Adresse, Facturation, TVA, Mentions légales,
/// Personnalisation PDF, Signature, Logo.
class ProfilEntrepriseView extends StatefulWidget {
  const ProfilEntrepriseView({super.key});

  @override
  State<ProfilEntrepriseView> createState() => _ProfilEntrepriseViewState();
}

class _ProfilEntrepriseViewState extends State<ProfilEntrepriseView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // ── Contrôleurs texte ──
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
  final _numeroTvaIntraController = TextEditingController();
  final _tauxPenalitesController = TextEditingController();

  // ── État dropdowns / toggles ──
  FrequenceCotisation _frequenceCotisation = FrequenceCotisation.mensuelle;
  TypeEntreprise _typeEntreprise = TypeEntreprise.microEntrepreneur;
  RegimeFiscal? _regimeFiscal;
  CaisseRetraite _caisseRetraite = CaisseRetraite.ssi;
  bool _tvaApplicable = false;
  PdfTheme _pdfTheme = PdfTheme.moderne;
  String? _pdfPrimaryColor;
  ModeFacturation _modeFacturation = ModeFacturation.global;
  bool _modeDiscret = false;
  bool _escompteApplicable = false;
  bool _estImmatricule = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _chargerProfil());
  }

  Future<void> _chargerProfil() async {
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
      _numeroTvaIntraController.text = p.numeroTvaIntra ?? "";
      _tauxPenalitesController.text = p.tauxPenalitesRetard.toString();
      setState(() {
        _frequenceCotisation = p.frequenceCotisation;
        _typeEntreprise = p.typeEntreprise;
        _regimeFiscal = p.regimeFiscal;
        _caisseRetraite = p.caisseRetraite;
        _tvaApplicable = p.tvaApplicable;
        _pdfTheme = p.pdfTheme;
        _pdfPrimaryColor = p.pdfPrimaryColor;
        _modeFacturation = p.modeFacturation;
        _modeDiscret = p.modeDiscret;
        _escompteApplicable = p.escompteApplicable;
        _estImmatricule = p.estImmatricule;
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
    _numeroTvaIntraController.dispose();
    _tauxPenalitesController.dispose();
    super.dispose();
  }

  // ── Sauvegarde ──

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    final existingId = vm.profil?.id;
    final existingLogo = vm.profil?.logoUrl;
    final existingSignature = vm.profil?.signatureUrl;

    final tauxPenalites =
        double.tryParse(_tauxPenalitesController.text.replaceAll(',', '.')) ??
            11.62;

    final profilToSave = ProfilEntreprise(
      id: existingId,
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
      tvaApplicable: _tvaApplicable,
      numeroTvaIntra: _numeroTvaIntraController.text.trim().isNotEmpty
          ? _numeroTvaIntraController.text.trim()
          : null,
      pdfTheme: _pdfTheme,
      pdfPrimaryColor: _pdfPrimaryColor,
      modeFacturation: _modeFacturation,
      modeDiscret: _modeDiscret,
      tauxPenalitesRetard: tauxPenalites,
      escompteApplicable: _escompteApplicable,
      estImmatricule: _estImmatricule,
    );

    final success = await vm.saveProfil(profilToSave);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? "Profil enregistré avec succès !"
          : "Erreur lors de l'enregistrement"),
      backgroundColor: success ? Colors.green.shade700 : AppTheme.error,
    ));
  }

  // ── Upload images ──

  Future<void> _pickAndUpload(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    final success = await vm.uploadImage(image, type);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? "Image mise à jour !" : "Erreur upload"),
    ));
  }

  Future<void> _drawAndUpload() async {
    final Uint8List? signatureBytes = await showDialog(
      context: context,
      builder: (context) => const SignatureDialog(),
    );
    if (signatureBytes == null || !mounted) return;

    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    final success = await vm.uploadSignatureBytes(signatureBytes);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? "Signature mise à jour !" : "Erreur upload"),
    ));
  }

  // ── Auto-fill mentions légales ──

  void _regenererMentions() {
    final vm = Provider.of<EntrepriseViewModel>(context, listen: false);
    setState(() {
      _mentionsController.text = vm.getLegalMentionsSuggestion(
        _typeEntreprise,
        estImmatricule: _estImmatricule,
        tvaApplicable: _tvaApplicable,
      );
    });
  }

  // ────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────

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
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── LOGO ──
                    _buildLogoSection(profil),
                    const SizedBox(height: 28),

                    // ── 1. IDENTITÉ ──
                    _buildSectionCard(
                      icon: Icons.badge_rounded,
                      title: "Identité",
                      children: [
                        CustomTextField(
                          label: "Nom de l'entreprise (Raison Sociale)",
                          controller: _nomEntController,
                          validator: (v) => v!.isEmpty ? "Nom requis" : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "Nom du Gérant",
                          controller: _nomGerantController,
                          validator: (v) => v!.isEmpty ? "Nom requis" : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "SIRET (14 chiffres)",
                          controller: _siretController,
                          keyboardType: TextInputType.number,
                          validator: ValidationUtils.validateSiret,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown<TypeEntreprise>(
                          label: "Type d'entreprise",
                          value: _typeEntreprise,
                          items: TypeEntreprise.values,
                          itemLabel: (e) => e.label,
                          onChanged: (v) {
                            setState(() => _typeEntreprise = v!);
                            if (_mentionsController.text.isEmpty) {
                              _regenererMentions();
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "Email contact",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: ValidationUtils.validateEmailRequired,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "Téléphone",
                          controller: _telController,
                          keyboardType: TextInputType.phone,
                          validator: ValidationUtils.validatePhone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 2. ADRESSE ──
                    _buildSectionCard(
                      icon: Icons.location_on_rounded,
                      title: "Adresse",
                      children: [
                        CustomTextField(
                          label: "Adresse complète",
                          controller: _adresseController,
                          validator: (v) => v!.isEmpty ? "Requis" : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: CustomTextField(
                                label: "Code Postal",
                                controller: _cpController,
                                keyboardType: TextInputType.number,
                                validator: ValidationUtils.validateCodePostal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                label: "Ville",
                                controller: _villeController,
                                validator: (v) => v!.isEmpty ? "Requis" : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 3. FACTURATION & BANCAIRE ──
                    _buildSectionCard(
                      icon: Icons.account_balance_rounded,
                      title: "Facturation & Bancaire",
                      children: [
                        CustomTextField(
                            label: "IBAN", controller: _ibanController),
                        const SizedBox(height: 12),
                        CustomTextField(
                            label: "BIC", controller: _bicController),
                        const SizedBox(height: 16),
                        _buildDropdown<FrequenceCotisation>(
                          label: "Fréquence déclaration URSSAF",
                          value: _frequenceCotisation,
                          items: FrequenceCotisation.values,
                          itemLabel: (e) => e.label,
                          onChanged: (v) =>
                              setState(() => _frequenceCotisation = v!),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownNullable<RegimeFiscal>(
                          label: "Régime fiscal",
                          hint: "Déterminé automatiquement",
                          value: _regimeFiscal,
                          items: RegimeFiscal.values,
                          itemLabel: (e) => e.label,
                          onChanged: (v) => setState(() => _regimeFiscal = v),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown<CaisseRetraite>(
                          label: "Caisse de retraite",
                          value: _caisseRetraite,
                          items: CaisseRetraite.values,
                          itemLabel: (e) => e.label,
                          onChanged: (v) =>
                              setState(() => _caisseRetraite = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 4. TVA ──
                    _buildSectionCard(
                      icon: Icons.percent_rounded,
                      title: "TVA",
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Assujetti à la TVA"),
                          subtitle: Text(
                            _tvaApplicable
                                ? "TVA collectée et déductible"
                                : "Franchise en base (art. 293 B du CGI)",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          value: _tvaApplicable,
                          activeTrackColor: AppTheme.primary,
                          onChanged: (v) => setState(() => _tvaApplicable = v),
                        ),
                        if (_tvaApplicable) ...[
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: "N° TVA Intracommunautaire",
                            controller: _numeroTvaIntraController,
                            validator: ValidationUtils.validateTvaIntra,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 5. MENTIONS LÉGALES ──
                    _buildSectionCard(
                      icon: Icons.gavel_rounded,
                      title: "Mentions Légales",
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Immatriculé RCS / RM"),
                          subtitle: Text(
                            _estImmatricule
                                ? "Numéro d'immatriculation affiché sur les PDF"
                                : "Mention « Dispensé d'immatriculation » sur les PDF",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          value: _estImmatricule,
                          activeTrackColor: AppTheme.primary,
                          onChanged: (v) => setState(() => _estImmatricule = v),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Escompte pour paiement anticipé"),
                          subtitle: Text(
                            _escompteApplicable
                                ? "Escompte mentionné sur les factures"
                                : "Pas d'escompte — mention obligatoire « Pas d'escompte »",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          value: _escompteApplicable,
                          activeTrackColor: AppTheme.primary,
                          onChanged: (v) =>
                              setState(() => _escompteApplicable = v),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "Taux pénalités de retard (%)",
                          controller: _tauxPenalitesController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: ValidationUtils.validatePourcentage,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: "Mentions légales libres",
                                controller: _mentionsController,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _regenererMentions,
                            icon: const Icon(Icons.auto_fix_high_rounded,
                                size: 18),
                            label: const Text("Régénérer automatiquement"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 6. PERSONNALISATION PDF ──
                    _buildSectionCard(
                      icon: Icons.palette_rounded,
                      title: "Personnalisation PDF",
                      children: [
                        _buildDropdown<PdfTheme>(
                          label: "Thème PDF",
                          value: _pdfTheme,
                          items: PdfTheme.values,
                          itemLabel: (e) => "${e.label} — ${e.description}",
                          onChanged: (v) => setState(() => _pdfTheme = v!),
                        ),
                        const SizedBox(height: 16),

                        // Couleur primaire personnalisée
                        Text("Couleur primaire du PDF",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade700)),
                        const SizedBox(height: 8),
                        _buildColorPicker(),
                        const SizedBox(height: 16),
                        _buildDropdown<ModeFacturation>(
                          label: "Mode de facturation",
                          value: _modeFacturation,
                          items: ModeFacturation.values,
                          itemLabel: (e) => "${e.label} — ${e.description}",
                          onChanged: (v) =>
                              setState(() => _modeFacturation = v!),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Mode discret"),
                          subtitle: Text(
                            "Masque le résumé financier dans l'éditeur",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          value: _modeDiscret,
                          activeTrackColor: AppTheme.primary,
                          onChanged: (v) => setState(() => _modeDiscret = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 7. SIGNATURE ──
                    _buildSectionCard(
                      icon: Icons.draw_rounded,
                      title: "Signature / Tampon",
                      children: [
                        Center(
                          child: Column(
                            children: [
                              if (profil?.signatureUrl != null)
                                Container(
                                  height: 100,
                                  width: 200,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Image.network(profil!.signatureUrl!,
                                      fit: BoxFit.contain),
                                ),
                              ElevatedButton.icon(
                                onPressed: _drawAndUpload,
                                icon: const Icon(Icons.draw, size: 20),
                                label: const Text("Dessiner ma Signature"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.textDark,
                                  side: BorderSide(color: Colors.grey.shade400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── BOUTON ENREGISTRER ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _sauvegarder,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text("ENREGISTRER LE PROFIL",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // WIDGETS HELPERS
  // ────────────────────────────────────────────────────────────────────────

  /// Sélecteur de couleur primaire pour les PDF
  Widget _buildColorPicker() {
    // Palette de couleurs prédéfinies
    const presetColors = <String, String>{
      '1E5572': 'Bleu Pétrole',
      '2C3E50': 'Bleu Nuit',
      '2A769E': 'Bleu Acier',
      '3498DB': 'Bleu Ciel',
      '1ABC9C': 'Turquoise',
      '27AE60': 'Vert Émeraude',
      '8E44AD': 'Violet',
      'E74C3C': 'Rouge Brique',
      'D35400': 'Orange Brûlé',
      '555555': 'Gris Anthracite',
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // Bouton "Par défaut"
        _buildColorChip(null, 'Défaut du thème'),
        ...presetColors.entries.map((e) => _buildColorChip(e.key, e.value)),
      ],
    );
  }

  Widget _buildColorChip(String? hex, String label) {
    final isSelected = _pdfPrimaryColor == hex;
    final displayColor =
        hex != null ? Color(int.parse('FF$hex', radix: 16)) : AppTheme.primary;

    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => setState(() => _pdfPrimaryColor = hex),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: displayColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppTheme.textDark : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected ? AppTheme.shadowSmall : null,
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }

  /// Section avec carte et titre.
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
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
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Logo section.
  Widget _buildLogoSection(ProfilEntreprise? profil) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickAndUpload('logo'),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (profil?.logoUrl != null)
                  ? NetworkImage(profil!.logoUrl!)
                  : null,
              child: (profil?.logoUrl == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded,
                            size: 26, color: Colors.grey.shade500),
                        const SizedBox(height: 2),
                        Text("Logo",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text("Appuyez pour changer le logo",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  /// Dropdown générique non-nullable.
  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e))))
          .toList(),
      onChanged: onChanged,
    );
  }

  /// Dropdown générique nullable (avec option "Auto").
  Widget _buildDropdownNullable<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T?>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: [
        const DropdownMenuItem<Null>(value: null, child: Text("Auto")),
        ...items
            .map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e)))),
      ],
      onChanged: onChanged,
    );
  }
}
