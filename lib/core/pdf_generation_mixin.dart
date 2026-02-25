import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client_model.dart';
import '../models/entreprise_model.dart';
import '../models/pdf_design_config.dart';
import '../services/pdf_service.dart';
import '../models/enums/entreprise_enums.dart';
import '../repositories/pdf_design_repository.dart';

/// Mixin pour la génération de PDF en temps réel
/// Utilisé par DevisViewModel et FactureViewModel
mixin PdfGenerationMixin on ChangeNotifier {
  bool _isRealTimePreviewEnabled = false;
  bool _isGeneratingPdf = false;
  Uint8List? _currentPdfData;
  Timer? _pdfDebounce;
  Map<String, Uint8List>? _cachedFonts;
  PdfDesignConfig? _cachedPdfConfig;

  bool get isRealTimePreviewEnabled => _isRealTimePreviewEnabled;
  bool get isGeneratingPdf => _isGeneratingPdf;
  Uint8List? get currentPdfData => _currentPdfData;

  /// Active/Désactive la prévisualisation en temps réel
  void toggleRealTimePreview(bool value) {
    _isRealTimePreviewEnabled = value;
    notifyListeners();
  }

  /// Nettoie l'état PDF (appeler lors de la fermeture/reset)
  void clearPdfState() {
    _currentPdfData = null;
    _isGeneratingPdf = false;
    _isRealTimePreviewEnabled = false;
    _pdfDebounce?.cancel();
    _cachedPdfConfig = null;
    _cachedFonts = null;
  }

  /// Charge (ou rafraîchit) la PdfDesignConfig depuis Supabase.
  /// Appelé une seule fois au premier usage, puis caché.
  Future<PdfDesignConfig> _loadPdfConfig(ProfilEntreprise? profil) async {
    if (_cachedPdfConfig != null) return _cachedPdfConfig!;

    try {
      final repo = PdfDesignRepository();
      // Résoudre l'entreprise_id réel depuis la table entreprises
      String? entrepriseId = profil?.id;
      if (entrepriseId == null || entrepriseId.isEmpty) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          final row = await Supabase.instance.client
              .from('entreprises')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();
          entrepriseId = row?['id'] as String?;
        }
      }
      if (entrepriseId != null && entrepriseId.isNotEmpty) {
        final loaded = await repo.getConfig(entrepriseId);
        if (loaded != null) {
          _cachedPdfConfig = loaded;
          return loaded;
        }
      }
    } catch (e) {
      developer.log(
          '⚠️ PdfGenerationMixin: impossible de charger PdfDesignConfig',
          error: e);
    }

    // Fallback : config par défaut
    _cachedPdfConfig = PdfDesignConfig.defaultConfig(profil?.id ?? 'default');
    return _cachedPdfConfig!;
  }

  /// Déclenche une mise à jour PDF avec debounce (1s)
  void triggerPdfUpdate(
    dynamic document,
    Client? client,
    ProfilEntreprise? profil, {
    required bool isTvaApplicable,
    required String documentType,
    required String docTypeLabel,
    String? factureSourceNumero,
    PdfDesignConfig? config,
  }) {
    if (!_isRealTimePreviewEnabled) return;
    if (_pdfDebounce?.isActive ?? false) _pdfDebounce!.cancel();

    _pdfDebounce = Timer(const Duration(milliseconds: 1000), () {
      _generatePdf(
        document,
        client,
        profil,
        isTvaApplicable: isTvaApplicable,
        documentType: documentType,
        docTypeLabel: docTypeLabel,
        factureSourceNumero: factureSourceNumero,
        config: config,
      );
    });
  }

  /// Force un refresh immédiat du PDF
  void forceRefreshPdf(
    dynamic document,
    Client? client,
    ProfilEntreprise? profil, {
    required bool isTvaApplicable,
    required String documentType,
    required String docTypeLabel,
    String? factureSourceNumero,
    PdfDesignConfig? config,
  }) {
    if (_pdfDebounce?.isActive ?? false) _pdfDebounce!.cancel();
    _generatePdf(
      document,
      client,
      profil,
      isTvaApplicable: isTvaApplicable,
      documentType: documentType,
      docTypeLabel: docTypeLabel,
      factureSourceNumero: factureSourceNumero,
      config: config,
    );
  }

  /// Génère le PDF dans un isolate, en chargeant d'abord la config BDD si nécessaire
  Future<void> _generatePdf(
    dynamic document,
    Client? client,
    ProfilEntreprise? profil, {
    required bool isTvaApplicable,
    required String documentType,
    required String docTypeLabel,
    String? factureSourceNumero,
    PdfDesignConfig? config,
  }) async {
    if (_isGeneratingPdf) return;

    _isGeneratingPdf = true;
    notifyListeners();

    try {
      // Charger la config depuis Supabase si non fournie explicitement
      final activeConfig = config ?? await _loadPdfConfig(profil);
      final pairing = activeConfig.fontPairing;

      // Invalider le cache de polices si le pairing a changé
      if (_cachedFonts != null &&
          _cachedPdfConfig?.fontPairing != activeConfig.fontPairing) {
        _cachedFonts = null;
      }

      _cachedFonts ??= await PdfService.prepareFonts(pairing);

      final request = PdfGenerationRequest(
        document: (document as dynamic).toMap(),
        documentType: documentType,
        client: client?.toMap(),
        profil: profil?.toMap(),
        docTypeLabel: docTypeLabel,
        isTvaApplicable: isTvaApplicable,
        factureSourceNumero: factureSourceNumero,
        fontPairing: pairing.name,
        // ↓ LA CLE : on passe la config complète sérialisée
        configJson: activeConfig.toJson(),
        fontRegular: _cachedFonts?['regular'],
        fontBold: _cachedFonts?['bold'],
        fontItalic: _cachedFonts?['italic'],
      );

      final result = await compute(PdfService.generatePdfIsolate, request);
      _currentPdfData = result;
    } catch (e) {
      developer.log("🔴 Error generating PDF", error: e);
    } finally {
      _isGeneratingPdf = false;
      notifyListeners();
    }
  }

  /// Dispose des timers (appeler dans @override dispose())
  void disposePdf() {
    _pdfDebounce?.cancel();
  }
}
