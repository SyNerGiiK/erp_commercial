import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../models/client_model.dart';
import '../models/entreprise_model.dart';
import '../services/pdf_service.dart';

/// Mixin pour la génération de PDF en temps réel
/// Utilisé par DevisViewModel et FactureViewModel
mixin PdfGenerationMixin on ChangeNotifier {
  bool _isRealTimePreviewEnabled = false;
  bool _isGeneratingPdf = false;
  Uint8List? _currentPdfData;
  Timer? _pdfDebounce;
  Map<String, Uint8List>? _cachedFonts;

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
    );
  }

  /// Génère le PDF dans un isolate
  Future<void> _generatePdf(
    dynamic document,
    Client? client,
    ProfilEntreprise? profil, {
    required bool isTvaApplicable,
    required String documentType,
    required String docTypeLabel,
    String? factureSourceNumero,
  }) async {
    if (_isGeneratingPdf) return;

    _isGeneratingPdf = true;
    notifyListeners();

    try {
      // Précharger les polices (une seule fois)
      _cachedFonts ??= await PdfService.prepareFonts();

      final request = PdfGenerationRequest(
        document: (document as dynamic).toMap(),
        documentType: documentType,
        client: client?.toMap(),
        profil: profil?.toMap(),
        docTypeLabel: docTypeLabel,
        isTvaApplicable: isTvaApplicable,
        factureSourceNumero: factureSourceNumero,
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
