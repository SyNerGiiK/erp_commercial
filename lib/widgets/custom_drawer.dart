import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../config/theme.dart';

/// Drawer moderne Artisan 3.0 — sections regroupées logiquement.
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
      backgroundColor: Colors.white,
      elevation: isPermanent ? 0 : 8,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          // ── HEADER PROFIL ──
          _buildHeader(context, profil, avatarImage),

          // ── NAVIGATION ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Activité
                _buildSectionLabel("ACTIVITÉ"),
                _buildItem(context, 0, "Tableau de Bord",
                    Icons.dashboard_rounded, '/app/home'),
                _buildItem(context, 4, "Planning", Icons.calendar_month_rounded,
                    '/app/planning'),
                _buildItem(context, 8, "Rentabilité", Icons.insights_rounded,
                    '/app/rentabilite'),

                const SizedBox(height: 8),

                // Documents
                _buildSectionLabel("DOCUMENTS"),
                _buildItem(context, 1, "Devis", Icons.request_quote_rounded,
                    '/app/devis'),
                _buildItem(context, 2, "Factures", Icons.receipt_rounded,
                    '/app/factures'),
                _buildItem(context, 10, "Archives", Icons.inventory_2_rounded,
                    '/app/archives'),
                _buildItem(context, 11, "Relances",
                    Icons.notification_important_rounded, '/app/relances'),
                _buildItem(context, 13, "Récurrentes", Icons.repeat_rounded,
                    '/app/recurrentes'),

                const SizedBox(height: 8),

                // Gestion
                _buildSectionLabel("GESTION"),
                _buildItem(context, 3, "Clients", Icons.people_alt_rounded,
                    '/app/clients'),
                _buildItem(context, 5, "Dépenses",
                    Icons.account_balance_wallet_rounded, '/app/depenses'),
                _buildItem(context, 6, "Liste de Courses",
                    Icons.shopping_cart_rounded, '/app/courses'),

                const SizedBox(height: 8),

                // Outils
                _buildSectionLabel("OUTILS"),
                _buildItem(context, 7, "Bibliothèque Prix",
                    Icons.menu_book_rounded, '/app/bibliotheque'),
                _buildItem(context, 14, "Suivi du temps", Icons.timer_rounded,
                    '/app/temps'),
                _buildItem(context, 15, "Rappels", Icons.alarm_rounded,
                    '/app/rappels'),

                const SizedBox(height: 8),

                // Paramètres
                _buildSectionLabel("PARAMÈTRES"),
                _buildItem(context, 9, "Configuration", Icons.tune_rounded,
                    '/app/parametres'),
                _buildItem(context, 12, "Corbeille",
                    Icons.delete_outline_rounded, '/app/corbeille'),
              ],
            ),
          ),

          // ── FOOTER ──
          const Divider(height: 1),
          _buildLogoutTile(context),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
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
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24,
          left: 20,
          right: 16,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION LABEL ──

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 8, bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
        leading: Icon(
          icon,
          size: 22,
          color: isSelected ? AppTheme.primary : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? AppTheme.primary : AppTheme.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          if (isSelected) {
            if (!isPermanent) Navigator.pop(context);
          } else {
            _navigate(context, route);
          }
        },
      ),
    );
  }

  // ── LOGOUT ──

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      dense: true,
      leading:
          const Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
      title: const Text(
        "Se déconnecter",
        style: TextStyle(
          color: AppTheme.error,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Provider.of<AuthViewModel>(context, listen: false).signOut();
      },
    );
  }
}
