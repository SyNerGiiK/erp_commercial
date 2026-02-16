import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import '../viewmodels/editor_state_provider.dart';

class SplitEditorScaffold extends StatefulWidget {
  final String title;
  final Widget editorForm;
  // final Future<Uint8List> Function(PdfPageFormat) onGeneratePdf; // REMOVED

  final Uint8List? pdfData; // NEW
  final bool isPdfLoading; // NEW
  final bool isRealTime; // NEW
  final ValueChanged<bool>? onToggleRealTime; // NEW
  final VoidCallback? onRefreshPdf; // NEW

  final VoidCallback? onSave;
  final bool isSaving;
  final dynamic draftData; // Pour la minimisation
  final String draftType; // 'devis' ou 'facture'
  final String? draftId;
  final String? sourceDevisId;

  const SplitEditorScaffold({
    super.key,
    required this.title,
    required this.editorForm,
    // required this.onGeneratePdf, // REMOVED
    required this.draftData,
    required this.draftType,
    // NEW PARAMS
    this.pdfData,
    this.isPdfLoading = false,
    this.isRealTime = false,
    this.onToggleRealTime,
    this.onRefreshPdf,
    this.draftId,
    this.sourceDevisId,
    this.onSave,
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
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
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
          if (widget.pdfData != null)
            PdfPreview(
              key: ValueKey(widget.pdfData.hashCode), // Refresh on data change
              build: (format) => Future.value(widget.pdfData!),
              useActions: false,
              loadingWidget: const SizedBox(), // Managed by overlay
              initialPageFormat: PdfPageFormat.a4,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              maxPageWidth: 700,
            )
          else
            // Squelette de chargement (Shimmer-like)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text("Chargement de l'aperçu...",
                      style: TextStyle(color: Colors.grey[500])),
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
