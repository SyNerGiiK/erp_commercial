import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../viewmodels/editor_state_provider.dart';

class SplitEditorScaffold extends StatefulWidget {
  final String title;
  final Widget editorForm;
  final Future<Uint8List> Function(PdfPageFormat) onGeneratePdf;
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
    required this.onGeneratePdf,
    required this.draftData,
    required this.draftType,
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
  bool _isLivePreview = false;
  int _refreshKey = 0; // Pour forcer le rebuild du PdfPreview

  void _minimize(BuildContext context) {
    final editorState =
        Provider.of<EditorStateProvider>(context, listen: false);
    editorState.minimize(
      draft: widget.draftData,
      type: widget.draftType,
      id: widget.draftId,
      sourceDevisId: widget.sourceDevisId,
    );
    Navigator.pop(context); // Retour dashboard
  }

  void _refreshPdf() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Breakpoint Desktop
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
          // On utilise une key pour forcer le refresh quand on clique sur le bouton manuel
          // Si Live Preview est activé, le widget parent doit gérer le rebuild via setState ou autre
          // Mais ici le PdfPreview de printing package gère lui même son build
          PdfPreview(
            key: ValueKey(_refreshKey),
            build: (format) => widget.onGeneratePdf(format),
            useActions:
                false, // On refait nos propres actions si besoin, ou true pour print/share
            loadingWidget: const Center(child: CircularProgressIndicator()),
            initialPageFormat: PdfPageFormat.a4,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            maxPageWidth: 700,

            // Pour le debounce/live, le package printing n'a pas de debounce intégré sur le parametre build.
            // C'est pourquoi on passe par _refreshKey pour le manuel.
            // Pour le live, on compte sur le parent qui rebuild ce widget.
          ),

          // Contrôles Flottants
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bouton Refresh Manuel
                if (!_isLivePreview)
                  FloatingActionButton.extended(
                    onPressed: _refreshPdf,
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
                        value: _isLivePreview,
                        onChanged: (val) {
                          setState(() {
                            _isLivePreview = val ?? false;
                            // TODO: Implémenter la logique Live réelle via callback parent si nécessaire
                            // Ici c'est juste l'UI
                          });
                          if (_isLivePreview) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  "Mode Temps Réel activé (peut ralentir sur les gros documents)"),
                              duration: Duration(seconds: 2),
                            ));
                          }
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
