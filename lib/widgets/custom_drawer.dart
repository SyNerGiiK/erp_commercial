import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../config/theme.dart';
import '../config/theme_notifier.dart';

/// Sidebar Forge 2030
class CustomDrawer extends StatefulWidget {
  final int selectedIndex;
  final bool isPermanent;

  const CustomDrawer({
    super.key,
    this.selectedIndex = -1,
    this.isPermanent = false,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigate(BuildContext context, String routeName) {
    if (!widget.isPermanent) Navigator.pop(context);
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

    final drawerBg = AppTheme.isDark
        ? const Color(0xFF0F0D0B).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.92);

    final borderRight = AppTheme.isDark
        ? AppTheme.borderGlass
        : AppTheme.divider.withValues(alpha: 0.3);

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: drawerBg,
              border: widget.isPermanent
                  ? Border(right: BorderSide(color: borderRight, width: 1))
                  : null,
            ),
            child: Column(
              children: [
                _buildHeader(context, profil, avatarImage),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: widget.isPermanent,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      children: [
                        _buildSectionLabel("TABLEAU DE BORD"),
                        _buildItem(context, 0, "Dashboard", Icons.grid_view_rounded, '/app/home'),
                        _buildItem(context, 8, "Rentabilit\u00E9", Icons.insights_rounded, '/app/rentabilite'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("COMMERCIAL"),
                        _buildItem(context, 1, "Devis", Icons.request_quote_rounded, '/app/devis'),
                        _buildItem(context, 2, "Factures", Icons.receipt_long_rounded, '/app/factures'),
                        _buildItem(context, 13, "R\u00E9currentes", Icons.repeat_rounded, '/app/recurrentes'),
                        _buildItem(context, 11, "Relances", Icons.notification_important_rounded, '/app/relances'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("CONTACTS & LOGISTIQUE"),
                        _buildItem(context, 3, "Clients", Icons.people_alt_rounded, '/app/clients'),
                        _buildItem(context, 5, "D\u00E9penses", Icons.account_balance_wallet_rounded, '/app/depenses'),
                        _buildItem(context, 6, "Courses", Icons.shopping_bag_rounded, '/app/courses'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("OUTILS"),
                        _buildItem(context, 4, "Planning", Icons.calendar_month_rounded, '/app/planning'),
                        _buildItem(context, 14, "Suivi du temps", Icons.timer_rounded, '/app/temps'),
                        _buildItem(context, 7, "Biblioth\u00E8que", Icons.auto_stories_rounded, '/app/bibliotheque'),
                        _buildItem(context, 15, "Rappels", Icons.notifications_active_rounded, '/app/rappels'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("SUPPORT"),
                        _buildItem(context, 16, "Centre d'aide I.A.", Icons.support_agent_rounded, '/app/support'),
                        const SizedBox(height: 12),
                        _buildSectionLabel("PARAM\u00C8TRES"),
                        _buildItem(context, 9, "Configuration", Icons.tune_rounded, '/app/parametres'),
                        _buildItem(context, 10, "Archives", Icons.inventory_2_rounded, '/app/archives'),
                        _buildItem(context, 12, "Corbeille", Icons.delete_outline_rounded, '/app/corbeille'),
                        if (profil?.isAdmin == true) ...[
                          const SizedBox(height: 12),
                          _buildSectionLabel("ADMINISTRATION"),
                          _buildItem(context, 99, "Super-Cockpit", Icons.admin_panel_settings_rounded, '/admin-panel'),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildThemeToggle(context),
                Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: borderRight))),
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

  Widget _buildHeader(BuildContext context, dynamic profil, ImageProvider? avatarImage) {
    final hasName = profil?.nomEntreprise.isNotEmpty ?? false;
    final initials = hasName ? profil!.nomEntreprise[0].toUpperCase() : "A";
    final name = profil?.nomEntreprise ?? "Mon Entreprise";
    final subtitle = profil?.email ?? "Configurez votre profil";

    return InkWell(
      onTap: () => _navigate(context, '/app/parametres'),
      hoverColor: AppTheme.primary.withValues(alpha: 0.04),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 20, right: 16, bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withValues(alpha: AppTheme.isDark ? 0.12 : 0.08),
              AppTheme.secondary.withValues(alpha: AppTheme.isDark ? 0.06 : 0.04),
            ],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border(bottom: BorderSide(color: AppTheme.borderGlass)),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 12, spreadRadius: -2)],
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primarySoft,
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Text(initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary))
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppTheme.primarySoft, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.chevron_right_rounded, color: AppTheme.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 6),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textGrey, letterSpacing: 1.5)),
    );
  }

  Widget _buildItem(BuildContext context, int index, String title, IconData icon, String route) {
    final isSelected = widget.selectedIndex == index;
    final selectedBg = AppTheme.primary.withValues(alpha: AppTheme.isDark ? 0.12 : 0.08);
    final selectedBorder = AppTheme.primary.withValues(alpha: AppTheme.isDark ? 0.20 : 0.12);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppTheme.primary.withValues(alpha: 0.06),
          onTap: () {
            if (isSelected) { if (!widget.isPermanent) Navigator.pop(context); }
            else { _navigate(context, route); }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: selectedBorder, width: 1) : Border.all(color: Colors.transparent, width: 1),
            ),
            child: Row(
              children: [
                if (isSelected)
                  Container(
                    width: 3, height: 18, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.forgeGradient,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 6)],
                    ),
                  ),
                Container(
                  decoration: isSelected
                      ? BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 8, spreadRadius: -2)])
                      : null,
                  child: Icon(icon, size: 20, color: isSelected ? AppTheme.primary : AppTheme.textGrey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: TextStyle(
                    fontSize: 13.5,
                    color: isSelected ? AppTheme.primary : AppTheme.textMedium,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: -0.1,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppTheme.primary.withValues(alpha: 0.06),
          onTap: () => themeNotifier.toggleTheme(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(themeNotifier.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  themeNotifier.isDark ? "Mode clair" : "Mode sombre",
                  style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w500, fontSize: 13.5),
                )),
                Container(
                  width: 36, height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppTheme.primary.withValues(alpha: themeNotifier.isDark ? 0.2 : 0.1),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: themeNotifier.isDark ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 16, height: 16, margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppTheme.primary,
                        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 4)],
                      ),
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

  Widget _buildLogoutTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppTheme.error.withValues(alpha: 0.04),
          onTap: () { Provider.of<AuthViewModel>(context, listen: false).signOut(); },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.logout_rounded, color: AppTheme.error.withValues(alpha: 0.8), size: 20),
                const SizedBox(width: 12),
                Text("Se d\u00E9connecter", style: TextStyle(color: AppTheme.error.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 13.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}