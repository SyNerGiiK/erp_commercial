import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/facture_recurrente_model.dart';
import '../viewmodels/facture_recurrente_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../widgets/custom_drawer.dart';

/// Vue de gestion des factures récurrentes
class FacturesRecurrentesView extends StatefulWidget {
  const FacturesRecurrentesView({super.key});

  @override
  State<FacturesRecurrentesView> createState() =>
      _FacturesRecurrentesViewState();
}

class _FacturesRecurrentesViewState extends State<FacturesRecurrentesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FactureRecurrenteViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FactureRecurrenteViewModel>();
    final clientVM = context.watch<ClientViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures Récurrentes'),
        actions: [
          if (vm.aGenerer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${vm.aGenerer.length} à générer'),
                backgroundColor: AppTheme.warning,
                labelStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      drawer: const CustomDrawer(selectedIndex: 13),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle récurrence'),
        backgroundColor: AppTheme.primary,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.items.isEmpty
              ? _buildEmptyState()
              : _buildList(vm, clientVM),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucune facture récurrente',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez des factures automatiques pour vos abonnements',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildList(FactureRecurrenteViewModel vm, ClientViewModel clientVM) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.items.length,
      itemBuilder: (context, index) {
        final item = vm.items[index];
        final clientName = clientVM.clients
                .where((c) => c.id == item.clientId)
                .map((c) => c.nomComplet)
                .firstOrNull ??
            'Client inconnu';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: item.estActive
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              child: Icon(
                Icons.repeat_rounded,
                color: item.estActive ? AppTheme.primary : Colors.grey,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.objet,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.estActive
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.estActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.estActive ? AppTheme.success : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(clientName, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      item.frequence.label,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.euro, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${item.totalTtc.toDouble().toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${item.nbFacturesGenerees} générée(s)',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleAction(value, item),
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'toggle', child: Text('Activer/Désactiver')),
                const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer',
                      style: TextStyle(color: AppTheme.error)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAction(String action, FactureRecurrente item) {
    final vm = Provider.of<FactureRecurrenteViewModel>(context, listen: false);
    switch (action) {
      case 'toggle':
        vm.toggleActive(item.id!);
        break;
      case 'edit':
        _showFormDialog(context, item);
        break;
      case 'delete':
        _confirmDelete(item);
        break;
    }
  }

  void _confirmDelete(FactureRecurrente item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la récurrence ?'),
        content: Text(
            'La facture récurrente "${item.objet}" sera supprimée définitivement.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FactureRecurrenteViewModel>().delete(item.id!);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, FactureRecurrente? existing) {
    // Formulaire simplifié — dans une vraie app, on ouvrirait un stepper complet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(existing == null
            ? 'Création de facture récurrente — Bientôt disponible en mode formulaire complet'
            : 'Modification de "${existing.objet}" — Bientôt disponible'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}
