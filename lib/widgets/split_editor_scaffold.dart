import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import '../viewmodels/editor_state_provider.dart';
import '../config/theme.dart';

class SplitEditorScaffold extends StatefulWidget {
  final String title;
  final Widget editorForm;

  final Uint8List? pdfData;
  final bool isPdfLoading;
  final bool isRealTime;
  final ValueChanged<bool>? onToggleRealTime;
  final VoidCallback? onRefreshPdf;

  final VoidCallback? onSave;
  final VoidCallback? onBack; // NEW
  final bool isSaving;
  final dynamic draftData;
  final String draftType;
  final String? draftId;
  final String? sourceDevisId;

  const SplitEditorScaffold({
    super.key,
    required this.title,
    required this.editorForm,
    required this.draftData,
    required this.draftType,
    this.pdfData,
    this.isPdfLoading = false,
    this.isRealTime = false,
    this.onToggleRealTime,
    this.onRefreshPdf,
    this.draftId,
    this.sourceDevisId,
    this.onSave,
    this.onBack,
    this.isSaving = false,
  });

  @override
  State<SplitEditorScaffold> createState() => _SplitEditorScaffoldState();
}

class _SplitEditorScaffoldState extends State<SplitEditorScaffold> {
  // Mode Live Preview désactivé par défaut pour perf
  // Mode Live Preview désactivé par défaut pour perf
  // bool _isLivePreview = false; // MOVED TO VM
  // int _refreshKey = 0; // REMOVED

  void _minimize(BuildContext context) {
    final editorState =
        Provider.of<EditorStateProvider>(context, listen: false);
    editorState.minimize(
      draft: widget.draftData,
      type: widget.draftType,
      id: widget.draftId,
      sourceDevisId: widget.sourceDevisId,
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/app/home');
    }
  }

  // void _refreshPdf() { ... } // MOVED TO PARENT

  @override
  Widget build(BuildContext context) {
    // Breakpoint Desktop
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis, maxLines: 1),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/app/home');
            }
          },
          tooltip: "Annuler et fermer",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: () => _minimize(context),
            tooltip: "Réduire le brouillon",
          ),
          const SizedBox(width: 10),
          if (widget.onSave != null)
            ElevatedButton.icon(
              onPressed: widget.isSaving ? null : widget.onSave,
              icon: widget.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label:
                  Text(widget.isSaving ? "Enregistrement..." : "Enregistrer"),
            ),
          const SizedBox(width: 20),
        ],
      ),
      body: isDesktop ? _buildSplitLayout() : _buildTabLayout(),
    );
  }

  Widget _buildSplitLayout() {
    return Row(
      children: [
        // Zone Gauche : Formulaire
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.white,
            child: widget.editorForm,
          ),
        ),
        // Séparateur vertical
        const VerticalDivider(width: 1, color: Colors.grey),
        // Zone Droite : PDF Preview
        Expanded(
          flex: 6,
          child: _buildPdfZone(),
        ),
      ],
    );
  }

  Widget _buildTabLayout() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit), text: "Édition"),
              Tab(icon: Icon(Icons.description), text: "Aperçu PDF"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                widget.editorForm,
                _buildPdfZone(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfZone() {
    return Container(
      color: Colors.grey[100],
      child: Stack(
        children: [
          // Le PdfPreview
          // On affiche le PDF data s'il existe
          // 1. Loading active (Spinner)
          if (widget.isPdfLoading)
            const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Génération de l'aperçu...",
                    style: TextStyle(color: Colors.grey)),
              ],
            ))
          // 2. Data available (Preview)
          else if (widget.pdfData != null)
            PdfPreview(
              key: ValueKey(widget.pdfData.hashCode),
              build: (format) => Future.value(widget.pdfData!),
              useActions: false,
              loadingWidget: const SizedBox(),
              initialPageFormat: PdfPageFormat.a4,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              maxPageWidth: 700,
            )
          // 3. Fallback (Empty state)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("L'aperçu s'affichera ici",
                      style: TextStyle(color: Colors.grey[500])),
                  TextButton.icon(
                      onPressed: () {}, // No action generic here, handled by VM
                      icon: const Icon(Icons.refresh),
                      label: const Text("Actualiser"))
                ],
              ),
            ),

          // LOADING OVERLAY
          if (widget.isPdfLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Contrôles Flottants
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bouton Refresh Manuel
                if (!widget.isRealTime && widget.onRefreshPdf != null)
                  FloatingActionButton.extended(
                    onPressed: widget.onRefreshPdf,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Actualiser l'aperçu"),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),

                const SizedBox(height: 10),

                // Toggle Live Preview
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: widget.isRealTime,
                        onChanged: (val) {
                          widget.onToggleRealTime?.call(val ?? false);
                        },
                      ),
                      const Text("Aperçu temps réel",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
