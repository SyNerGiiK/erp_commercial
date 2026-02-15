import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/base_screen.dart';
import '../config/theme.dart';

class SettingsRootView extends StatelessWidget {
  const SettingsRootView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      menuIndex: 9, // INDEX IMPORTANT
      title: "Paramètres",
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuLink(
            context,
            "Mon Entreprise",
            "Logo, Coordonnées, SIRET, RIB",
            Icons.business,
            '/app/profil',
          ),
          _buildMenuLink(
            context,
            "Configuration URSSAF",
            "Taux de cotisations, ACRE, Plafonds",
            Icons.account_balance,
            '/app/config_urssaf',
          ),
          _buildMenuLink(
            context,
            "Bibliothèque de Prix",
            "Gérer vos articles et prestations",
            Icons.library_books,
            '/app/bibliotheque',
          ),
          const Divider(),
          _buildMenuLink(
            context,
            "Archives",
            "Anciens devis et factures",
            Icons.archive,
            '/app/archives',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuLink(BuildContext context, String title, String subtitle,
      IconData icon, String route) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => context.push(route),
      ),
    );
  }
}
