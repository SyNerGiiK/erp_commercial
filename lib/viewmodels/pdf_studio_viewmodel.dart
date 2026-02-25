import 'dart:async';
import 'dart:typed_data';
import 'dart:developer' as developer;

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pdf_design_config.dart';
import '../models/enums/entreprise_enums.dart';
import '../repositories/pdf_design_repository.dart';
import '../services/pdf_service.dart';
import '../core/base_viewmodel.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/entreprise_model.dart';

class PdfStudioViewModel extends BaseViewModel {
  final IPdfDesignRepository _repository;

  PdfDesignConfig? _config;
  Uint8List? _previewPdfBytes;
  String? _entrepriseId;
  Timer? _previewDebounce;
  bool _isGeneratingPreview = false;

  PdfDesignConfig? get config => _config;
  Uint8List? get previewPdfBytes => _previewPdfBytes;
  bool get isGeneratingPreview => _isGeneratingPreview;

  PdfStudioViewModel({IPdfDesignRepository? repository})
      : _repository = repository ?? PdfDesignRepository();

  // ─── Load Config ────────────────────────────────────────────────────────
  Future<void> loadConfig([String? entrepriseId]) async {
    await executeOperation(() async {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      if (entrepriseId != null) {
        _entrepriseId = entrepriseId;
      } else {
        final row = await client
            .from('entreprises')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();
        _entrepriseId = row?['id'] as String?;
      }

      if (_entrepriseId == null) {
        _config = PdfDesignConfig.defaultConfig('');
      } else {
        _config = await _repository.getConfig(_entrepriseId!);
        _config ??= PdfDesignConfig.defaultConfig(_entrepriseId!);
      }
      notifyListeners();
      // Générer la preview initiale
      _schedulePreviewUpdate();
    }, logPrefix: 'PdfStudioViewModel.loadConfig');
  }

  // ─── Save Config ─────────────────────────────────────────────────────────
  Future<bool> saveConfig() async {
    if (_config == null) return false;
    if (_entrepriseId != null && _config!.entrepriseId.isEmpty) {
      _config = _config!.copyWith(entrepriseId: _entrepriseId);
    }
    final result = await executeOperation(() async {
      await _repository.saveConfig(_config!);
    }, logPrefix: 'PdfStudioViewModel.saveConfig');
    return result == true;
  }

  // ─── Update Field ────────────────────────────────────────────────────────
  void updateField({
    PdfFontPairing? fontPairing,
    String? primaryColor,
    String? secondaryColor,
    PdfTableStyle? tableStyle,
    PdfLayoutVariant? layoutVariant,
    String? headerBannerUrl,
    String? watermarkText,
    String? watermarkImageUrl,
    double? watermarkOpacity,
  }) {
    if (_config == null) return;
    _config = _config!.copyWith(
      fontPairing: fontPairing,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tableStyle: tableStyle,
      layoutVariant: layoutVariant,
      headerBannerUrl: headerBannerUrl,
      watermarkText: watermarkText,
      watermarkImageUrl: watermarkImageUrl,
      watermarkOpacity: watermarkOpacity != null
          ? Decimal.parse(watermarkOpacity.toStringAsFixed(2))
          : null,
    );
    notifyListeners();
    _schedulePreviewUpdate();
  }

  void updateConfig(PdfDesignConfig newConfig) {
    _config = newConfig;
    notifyListeners();
    _schedulePreviewUpdate();
  }

  void setPreviewPdfBytes(Uint8List bytes) {
    _previewPdfBytes = bytes;
    notifyListeners();
  }

  // ─── Upload Custom Banner ─────────────────────────────────────────────
  Future<void> uploadCustomBanner(XFile file) async {
    if (_config == null) return;
    await executeOperation(() async {
      final url = await _repository.uploadAsset(file, 'header_banner');
      _config = _config!.copyWith(headerBannerUrl: url);
      notifyListeners();
      _schedulePreviewUpdate();
    }, logPrefix: 'PdfStudioViewModel.uploadCustomBanner');
  }

  Future<void> uploadCustomWatermark(XFile file) async {
    if (_config == null) return;
    await executeOperation(() async {
      final url = await _repository.uploadAsset(file, 'watermark_image');
      _config = _config!.copyWith(watermarkImageUrl: url);
      notifyListeners();
      _schedulePreviewUpdate();
    }, logPrefix: 'PdfStudioViewModel.uploadCustomWatermark');
  }

  // ─── Preview Live ────────────────────────────────────────────────────────
  /// Déclenche une génération de prévisualisation PDF avec un debounce de 800ms
  void _schedulePreviewUpdate() {
    _previewDebounce?.cancel();
    _previewDebounce =
        Timer(const Duration(milliseconds: 800), _generatePreview);
  }

  Future<void> _generatePreview() async {
    if (_config == null || _isGeneratingPreview) return;
    _isGeneratingPreview = true;
    notifyListeners();

    try {
      final config = _config!;
      // Charger les polices adaptées au fontPairing sélectionné
      final fontBytes = await PdfService.prepareFonts(config.fontPairing);

      // Données de démo pour l'aperçu
      final request = PdfGenerationRequest(
        document: _buildDemoDevisMap(),
        documentType: 'devis',
        client: _buildDemoClientMap(),
        profil: _buildDemoProfilMap(),
        docTypeLabel: 'DEVIS',
        isTvaApplicable: true,
        fontPairing: config.fontPairing.name,
        configJson: config.toJson(),
        fontRegular: fontBytes['regular'],
        fontBold: fontBytes['bold'],
        fontItalic: fontBytes['italic'],
      );

      final bytes = await compute(PdfService.generatePdfIsolate, request);
      _previewPdfBytes = bytes;
    } catch (e) {
      developer.log('⚠️ PdfStudioViewModel: erreur génération preview',
          error: e);
    } finally {
      _isGeneratingPreview = false;
      notifyListeners();
    }
  }

  // ─── Données de démo pour la preview ─────────────────────────────────────
  static Map<String, dynamic> _buildDemoDevisMap() {
    final total1 = Decimal.parse('850.00') * Decimal.fromInt(3);
    final total2 = Decimal.parse('65.00') * Decimal.fromInt(8);
    final total3 = Decimal.parse('150.00') * Decimal.fromInt(1);

    final ligne1 = LigneDevis(
      id: '1',
      description: 'Fourniture et pose menuiseries aluminium',
      quantite: Decimal.fromInt(3),
      unite: 'ml',
      prixUnitaire: Decimal.parse('850.00'),
      totalLigne: total1,
      tauxTva: Decimal.parse('20.00'),
    );
    final ligne2 = LigneDevis(
      id: '2',
      description: "Main d'œuvre spécialisée (pose et finitions)",
      quantite: Decimal.fromInt(8),
      unite: 'h',
      prixUnitaire: Decimal.parse('65.00'),
      totalLigne: total2,
      tauxTva: Decimal.parse('10.00'),
    );
    final ligne3 = LigneDevis(
      id: '3',
      description: 'Nettoyage et évacuation des déchets',
      quantite: Decimal.fromInt(1),
      unite: 'fft',
      prixUnitaire: Decimal.parse('150.00'),
      totalLigne: total3,
      tauxTva: Decimal.parse('20.00'),
    );

    final totalHt = total1 + total2 + total3;
    final devis = Devis(
      id: 'demo-id',
      userId: 'demo-user',
      numeroDevis: 'DV-2025-0042',
      objet: 'Rénovation façade et menuiseries',
      clientId: 'demo-client',
      dateEmission: DateTime(2025, 3, 15),
      dateValidite: DateTime(2025, 4, 15),
      statut: 'brouillon',
      totalHt: totalHt,
      remiseTaux: Decimal.zero,
      acompteMontant: Decimal.zero,
      lignes: [ligne1, ligne2, ligne3],
    );

    return devis.toMap();
  }

  static Map<String, dynamic> _buildDemoClientMap() {
    final c = Client(
      id: 'c1',
      nomComplet: 'Dupont Construction SARL',
      typeClient: 'professionnel',
      nomContact: 'M. Pierre Dupont',
      adresse: '12 Rue des Bâtisseurs',
      codePostal: '75001',
      ville: 'Paris',
      telephone: '01 23 45 67 89',
      email: 'contact@dupont-construction.fr',
    );
    return c.toMap();
  }

  static Map<String, dynamic> _buildDemoProfilMap() {
    final p = ProfilEntreprise(
      id: 'demo-ent',
      userId: 'demo-user',
      nomEntreprise: 'Artisan & Co SAS',
      nomGerant: 'Jean Martin',
      adresse: '8 Avenue du Commerce',
      codePostal: '69001',
      ville: 'Lyon',
      siret: '123 456 789 00012',
      email: 'contact@artisan-co.fr',
      telephone: '04 72 00 00 00',
      pdfTheme: PdfTheme.moderne,
    );
    return p.toMap();
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    super.dispose();
  }
}
