import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../config/theme.dart';

/// Sidebar Aurora 2030 — Navigation glassmorphique avec lueur contextuelle.
class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final bool isPermanent;

  const CustomDrawer({
    super.key,
    this.selectedIndex = -1,
    this.isPermanent = false,
  });

  void _navigate(BuildContext context, String routeName) {
    if (!isPermanent) Navigator.pop(context);
    context.go(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final entrepriseVM = Provider.of<EntrepriseViewModel>(context);
    final profil = entrepriseVM.profil;

    ImageProvider? avatarImage;
    final logoUrl = profil?.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      avatarImage = NetworkImage(logoUrl);
    }

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isPermanent ? 0.88 : 0.92),
              border: isPermanent
                  ? Border(
                      right: BorderSide(
                        color: AppTheme.divider.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Column(
              children: [
                // ── HEADER PROFIL ──
                _buildHeader(context, profil, avatarImage),

                // ── NAVIGATION ──
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: isPermanent,
                    child: ListView(
                      primary: true,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      children: [
                        _buildSectionLabel("ACTIVITÉ"),
                        _buildItem(context, 0, "Tableau de Bord",
                            Icons.grid_view_rounded, '/app/home'),
                        _buildItem(context, 4, "Planning",
                            Icons.calendar_month_rounded, '/app/planning'),
                        _buildItem(context, 8, "Rentabilité",
                            Icons.insights_rounded, '/app/rentabilite'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("DOCUMENTS"),
                        _buildItem(context, 1, "Devis",
                            Icons.request_quote_rounded, '/app/devis'),
                        _buildItem(context, 2, "Factures",
                            Icons.receipt_long_rounded, '/app/factures'),
                        _buildItem(context, 10, "Archives",
                            Icons.inventory_2_rounded, '/app/archives'),
                        _buildItem(
                            context,
                            11,
                            "Relances",
                            Icons.notification_important_rounded,
                            '/app/relances'),
                        _buildItem(context, 13, "Récurrentes",
                            Icons.repeat_rounded, '/app/recurrentes'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("GESTION"),
                        _buildItem(context, 3, "Clients",
                            Icons.people_alt_rounded, '/app/clients'),
                        _buildItem(
                            context,
                            5,
                            "Dépenses",
                            Icons.account_balance_wallet_rounded,
                            '/app/depenses'),
                        _buildItem(context, 6, "Courses",
                            Icons.shopping_bag_rounded, '/app/courses'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("OUTILS"),
                        _buildItem(context, 7, "Bibliothèque",
                            Icons.auto_stories_rounded, '/app/bibliotheque'),
                        _buildItem(context, 14, "Suivi du temps",
                            Icons.timer_rounded, '/app/temps'),
                        _buildItem(context, 15, "Rappels",
                            Icons.notifications_active_rounded, '/app/rappels'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("SUPPORT"),
                        _buildItem(context, 16, "Centre d'aide I.A.",
                            Icons.support_agent_rounded, '/app/support'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("PARAMÈTRES"),
                        _buildItem(context, 9, "Configuration",
                            Icons.tune_rounded, '/app/parametres'),
                        _buildItem(context, 12, "Corbeille",
                            Icons.delete_outline_rounded, '/app/corbeille'),
                        if (profil?.isAdmin == true) ...[
                          const SizedBox(height: 12),
                          _buildSectionLabel("ADMINISTRATION"),
                          _buildItem(
                              context,
                              99,
                              "Super-Cockpit",
                              Icons.admin_panel_settings_rounded,
                              '/admin-panel'),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── FOOTER ──
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.divider.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: _buildLogoutTile(context),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ──

  Widget _buildHeader(
      BuildContext context, dynamic profil, ImageProvider? avatarImage) {
    final hasName = profil?.nomEntreprise.isNotEmpty ?? false;
    final initials = hasName ? profil!.nomEntreprise[0].toUpperCase() : "A";
    final name = profil?.nomEntreprise ?? "Mon Entreprise";
    final subtitle = profil?.email ?? "Configurez votre profil";

    return InkWell(
      onTap: () => _navigate(context, '/app/parametres'),
      hoverColor: AppTheme.primary.withValues(alpha: 0.04),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 16,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withValues(alpha: 0.08),
              AppTheme.secondary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.divider.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar avec glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primarySoft,
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Nom + Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION LABEL ──

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.textLight.withValues(alpha: 0.7),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── NAV ITEM ──

  Widget _buildItem(
    BuildContext context,
    int index,
    String title,
    IconData icon,
    String route,
  ) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppTheme.primary.withValues(alpha: 0.04),
          onTap: () {
            if (isSelected) {
              if (!isPermanent) Navigator.pop(context);
            } else {
              _navigate(context, route);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.12), width: 1)
                  : Border.all(color: Colors.transparent, width: 1),
            ),
            child: Row(
              children: [
                // Icône avec micro-glow si active
                Container(
                  decoration: isSelected
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? AppTheme.primary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      color:
                          isSelected ? AppTheme.primary : AppTheme.textMedium,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── LOGOUT ──

  Widget _buildLogoutTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppTheme.error.withValues(alpha: 0.04),
          onTap: () {
            Provider.of<AuthViewModel>(context, listen: false).signOut();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.logout_rounded,
                    color: AppTheme.error.withValues(alpha: 0.8), size: 20),
                const SizedBox(width: 12),
                Text(
                  "Se déconnecter",
                  style: TextStyle(
                    color: AppTheme.error.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
