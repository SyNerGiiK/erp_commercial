// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

import '../config/theme.dart';
import '../models/enums/entreprise_enums.dart';
import '../viewmodels/pdf_studio_viewmodel.dart';
import '../widgets/aurora/glass_container.dart';
import '../widgets/base_screen.dart';

/// ─── PDF Design Studio ────────────────────────────────────────────────────
/// Interface Canva-like pour personnaliser vos PDFs en temps réel.
/// Layout : Panneau de contrôle gauche (380px) + Aperçu live à droite.
class PdfStudioView extends StatefulWidget {
  const PdfStudioView({super.key});

  @override
  State<PdfStudioView> createState() => _PdfStudioViewState();
}

class _PdfStudioViewState extends State<PdfStudioView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _kUnsplashBanners = [
    'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1600&q=80',
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=1600&q=80',
    'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1600&q=80',
    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=1600&q=80',
    'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=1600&q=80',
    'https://images.unsplash.com/photo-1448932223592-d1fc686e76ea?w=1600&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PdfStudioViewModel>().loadConfig();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🎨 PDF Design Studio',
      child: Consumer<PdfStudioViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.config == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return _buildWideLayout(context, vm);
              } else {
                return _buildNarrowLayout(context, vm);
              }
            },
          );
        },
      ),
    );
  }

  // ─── WIDE LAYOUT ───────────────────────────────────────────────────────
  Widget _buildWideLayout(BuildContext context, PdfStudioViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380,
          child: _buildControlPanel(context, vm),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildPreviewPanel(context, vm)),
      ],
    );
  }

  // ─── NARROW LAYOUT ─────────────────────────────────────────────────────
  Widget _buildNarrowLayout(BuildContext context, PdfStudioViewModel vm) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMedium,
            indicatorColor: AppTheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.tune), text: 'Design'),
              Tab(icon: Icon(Icons.picture_as_pdf), text: 'Aperçu'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildControlPanel(context, vm),
                _buildPreviewPanel(context, vm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CONTROL PANEL ─────────────────────────────────────────────────────
  Widget _buildControlPanel(BuildContext context, PdfStudioViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildSaveButton(context, vm),
          const SizedBox(height: 16),
          _buildFontSection(context, vm),
          const SizedBox(height: 8),
          _buildColorSection(context, vm),
          const SizedBox(height: 8),
          _buildTableStyleSection(context, vm),
          const SizedBox(height: 8),
          _buildBannerSection(context, vm),
          const SizedBox(height: 8),
          _buildWatermarkSection(context, vm),
        ],
      ),
    );
  }

  // ─── SAVE BUTTON ───────────────────────────────────────────────────────
  Widget _buildSaveButton(BuildContext context, PdfStudioViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: vm.isLoading
            ? null
            : () async {
                final messenger = ScaffoldMessenger.of(context);
                final success = await vm.saveConfig();
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(
                  content: Text(success
                      ? '✅ Configuration sauvegardée !'
                      : '❌ Erreur lors de la sauvegarde.'),
                  backgroundColor: success ? AppTheme.primary : AppTheme.error,
                ));
              },
        icon: vm.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.cloud_upload_rounded),
        label: Text(vm.isLoading ? 'Sauvegarde...' : 'Sauvegarder le Design'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ─── FONT PAIRING SECTION ──────────────────────────────────────────────
  Widget _buildFontSection(BuildContext context, PdfStudioViewModel vm) {
    return _buildAccordion(
      icon: Icons.font_download_rounded,
      title: 'Typographie',
      child: Column(
        children: PdfFontPairing.values.map((pair) {
          final selected = vm.config?.fontPairing == pair;
          return _buildOptionTile(
            title: pair.label,
            subtitle: _fontPreviewText(pair),
            selected: selected,
            onTap: () => vm.updateField(fontPairing: pair),
          );
        }).toList(),
      ),
    );
  }

  String _fontPreviewText(PdfFontPairing p) {
    switch (p) {
      case PdfFontPairing.modern:
        return 'Inter • Sans-Serif moderne et lisible';
      case PdfFontPairing.luxury:
        return 'Playfair Display • Élégant et sophistiqué';
      case PdfFontPairing.classic:
        return 'Merriweather • Serif traditionnel';
      case PdfFontPairing.tech:
        return 'Roboto Mono • Précis et technique';
    }
  }

  // ─── COLOR SECTION ─────────────────────────────────────────────────────
  Widget _buildColorSection(BuildContext context, PdfStudioViewModel vm) {
    final presets = [
      ('#4F46E5', 'Indigo'),
      ('#0EA5E9', 'Bleu Ciel'),
      ('#10B981', 'Émeraude'),
      ('#F59E0B', 'Ambre'),
      ('#EF4444', 'Rouge'),
      ('#8B5CF6', 'Violet'),
      ('#1E5572', 'Marine'),
      ('#2C3E50', 'Ardoise'),
    ];

    return _buildAccordion(
      icon: Icons.palette_rounded,
      title: 'Palette de Couleurs',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: presets.map((p) {
          final hex = p.$1;
          final name = p.$2;
          final color = _hexToColor(hex);
          final selected = vm.config?.primaryColor == hex;
          return GestureDetector(
            onTap: () => vm.updateField(primaryColor: hex),
            child: Tooltip(
              message: name,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.divider,
                    width: 3,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8)
                        ]
                      : [],
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── TABLE STYLE SECTION ───────────────────────────────────────────────
  Widget _buildTableStyleSection(BuildContext context, PdfStudioViewModel vm) {
    return _buildAccordion(
      icon: Icons.table_chart_rounded,
      title: 'Style de Tableau',
      child: Column(
        children: PdfTableStyle.values.map((style) {
          final selected = vm.config?.tableStyle == style;
          return _buildOptionTile(
            title: style.label,
            subtitle: _tableStyleDescription(style),
            selected: selected,
            onTap: () => vm.updateField(tableStyle: style),
          );
        }).toList(),
      ),
    );
  }

  String _tableStyleDescription(PdfTableStyle s) {
    switch (s) {
      case PdfTableStyle.minimal:
        return 'Lignes sobres, bordures discrètes';
      case PdfTableStyle.zebra:
        return 'Lignes alternées grises pour lisibilité';
      case PdfTableStyle.solid:
        return 'Grille complète avec encadrements';
      case PdfTableStyle.rounded:
        return 'Coins arrondis, look moderne';
      case PdfTableStyle.filledHeader:
        return 'En-tête remplie, lignes séparées';
    }
  }

  // ─── BANNER SECTION ────────────────────────────────────────────────────
  Widget _buildBannerSection(BuildContext context, PdfStudioViewModel vm) {
    return _buildAccordion(
      icon: Icons.image_rounded,
      title: 'Bannière d\'En-tête',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Banners prêts à l\'emploi (Unsplash)',
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _kUnsplashBanners.length,
              itemBuilder: (context, index) {
                final url = _kUnsplashBanners[index];
                final selected = vm.config?.headerBannerUrl == url;
                return GestureDetector(
                  onTap: () => vm.updateField(headerBannerUrl: url),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 130,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                          image: NetworkImage(url), fit: BoxFit.cover),
                      border: Border.all(
                        color: selected ? AppTheme.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: selected
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppTheme.primary.withValues(alpha: 0.4),
                            ),
                            child: const Icon(Icons.check_circle,
                                color: Colors.white, size: 30),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: vm.config?.headerBannerUrl != null
                ? () => vm.updateField(headerBannerUrl: null)
                : null,
            icon: const Icon(Icons.clear, size: 14),
            label: const Text('Supprimer la bannière'),
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.error, padding: EdgeInsets.zero),
          ),
        ],
      ),
    );
  }

  // ─── WATERMARK SECTION ─────────────────────────────────────────────────
  Widget _buildWatermarkSection(BuildContext context, PdfStudioViewModel vm) {
    final controller =
        TextEditingController(text: vm.config?.watermarkText ?? '');

    return _buildAccordion(
      icon: Icons.water_drop_rounded,
      title: 'Filigrane',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            style: TextStyle(color: AppTheme.textDark),
            decoration: InputDecoration(
              hintText: 'Ex: CONFIDENTIEL, BROUILLON…',
              hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 12),
              filled: true,
              fillColor: AppTheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.divider),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) =>
                vm.updateField(watermarkText: v.isEmpty ? null : v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Opacité',
                  style: GoogleFonts.inter(
                      color: AppTheme.textMedium, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: vm.config?.watermarkOpacity.toDouble() ?? 0.1,
                  min: 0.05,
                  max: 0.5,
                  divisions: 9,
                  activeColor: AppTheme.primary,
                  onChanged: (v) {
                    vm.updateField(watermarkOpacity: v);
                  },
                ),
              ),
              Text(
                '${((vm.config?.watermarkOpacity.toDouble() ?? 0.1) * 100).round()}%',
                style:
                    GoogleFonts.inter(color: AppTheme.textMedium, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── PDF PREVIEW PANEL ─────────────────────────────────────────────────
  Widget _buildPreviewPanel(BuildContext context, PdfStudioViewModel vm) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.preview_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Aperçu en Temps Réel',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                // Indicateur de génération
                if (vm.isGeneratingPreview)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 6),
                      Text('Génération...',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppTheme.textMedium)),
                    ],
                  )
                else
                  _buildThemeBadge(vm),
              ],
            ),
          ),
          Expanded(
            child: vm.previewPdfBytes != null
                ? PdfPreview(
                    // La key force le rechargement complet à chaque nouvelle version
                    key: ValueKey(vm.previewPdfBytes!.lengthInBytes),
                    build: (_) async => vm.previewPdfBytes!,
                    allowSharing: false,
                    allowPrinting: false,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    pdfFileName: 'apercu_studio.pdf',
                    loadingWidget:
                        const Center(child: CircularProgressIndicator()),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (vm.isGeneratingPreview)
                          Column(
                            children: [
                              CircularProgressIndicator(
                                  color: AppTheme.primary),
                              const SizedBox(height: 16),
                              Text(
                                'Génération de l\'aperçu...',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          Icon(Icons.picture_as_pdf_outlined,
                              size: 72, color: AppTheme.textLight),
                          const SizedBox(height: 16),
                          Text(
                            'Chargement de l\'aperçu...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── THEME BADGE ───────────────────────────────────────────────────────
  Widget _buildThemeBadge(PdfStudioViewModel vm) {
    final color = _hexToColor(vm.config?.primaryColor ?? '#4F46E5');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            vm.config?.fontPairing.label ?? 'Modern',
            style: GoogleFonts.inter(
                fontSize: 11, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ─── SHARED HELPERS ────────────────────────────────────────────────────

  /// Accordéon réutilisable — couleurs adaptées au thème clair
  Widget _buildAccordion({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.divider),
      ),
      color: AppTheme.surface,
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primary, size: 20),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
        iconColor: AppTheme.textMedium,
        collapsedIconColor: AppTheme.textLight,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [child],
      ),
    );
  }

  /// Tuile d'option sélectionnable (radio-like) — thème clair
  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.08)
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.6)
                : AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          color: AppTheme.textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textMedium, fontSize: 11)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: AppTheme.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF4F46E5);
    }
  }
}
