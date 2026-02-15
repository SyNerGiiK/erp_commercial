import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../config/theme.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final bool isPermanent;

  const CustomDrawer({
    super.key,
    this.selectedIndex = -1,
    this.isPermanent = false,
  });

  void _navigate(BuildContext context, String routeName) {
    if (!isPermanent) {
      Navigator.pop(context);
    }
    context.go(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final entrepriseVM = Provider.of<EntrepriseViewModel>(context);
    final profil = entrepriseVM.profil;

    ImageProvider? avatarImage;
    // CORRECTION : Simplification pour éviter l'erreur 'unnecessary_non_null_assertion'
    final logoUrl = profil?.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      avatarImage = NetworkImage(logoUrl);
    } else {
      avatarImage = null;
    }

    return Drawer(
      backgroundColor: Colors.white,
      elevation: isPermanent ? 0 : 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
      ),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Text(
                      (profil?.nomEntreprise.isNotEmpty ?? false)
                          ? profil!.nomEntreprise[0].toUpperCase()
                          : "A",
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary),
                    )
                  : null,
            ),
            accountName: Text(
              profil?.nomEntreprise ?? "Mon Entreprise",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(profil?.email ?? "Configurez votre profil"),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildItem(context, 0, "Tableau de Bord", Icons.dashboard,
                    '/app/home'),
                const Divider(),
                _buildItem(
                    context, 1, "Devis", Icons.description, '/app/devis'),
                _buildItem(context, 2, "Factures", Icons.euro, '/app/factures'),
                _buildItem(context, 3, "Clients", Icons.people, '/app/clients'),
                _buildItem(context, 4, "Planning", Icons.calendar_month,
                    '/app/planning'),
                const Divider(),
                _buildItem(context, 5, "Dépenses", Icons.receipt_long,
                    '/app/depenses'),
                _buildItem(context, 6, "Liste de Courses", Icons.shopping_cart,
                    '/app/courses'),
                _buildItem(context, 7, "Bibliothèque", Icons.library_books,
                    '/app/bibliotheque'),
                const Divider(),
                _buildItem(context, 9, "Paramètres", Icons.settings,
                    '/app/parametres'),
                _buildItem(
                    context, 10, "Archives", Icons.archive, '/app/archives'),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: const Text(
              "Se déconnecter",
              style:
                  TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Provider.of<AuthViewModel>(context, listen: false).signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    String title,
    IconData icon,
    String route,
  ) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primary : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : const Color(0xFF2C3E50),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
}
