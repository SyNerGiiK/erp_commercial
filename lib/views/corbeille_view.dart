import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../widgets/base_screen.dart';
import '../viewmodels/corbeille_viewmodel.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/depense_model.dart';

/// Vue de la corbeille — affiche les éléments soft-deleted
/// avec possibilité de restaurer ou supprimer définitivement
class CorbeilleView extends StatefulWidget {
  const CorbeilleView({super.key});

  @override
  State<CorbeilleView> createState() => _CorbeilleViewState();
}

class _CorbeilleViewState extends State<CorbeilleView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CorbeilleViewModel>().fetchAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CorbeilleViewModel>(
      builder: (context, vm, _) {
        return BaseScreen(
          title: 'Corbeille',
          menuIndex: 12,
          headerActions: [
            if (!vm.isEmpty)
              TextButton.icon(
                onPressed: () => _confirmPurgeAll(context, vm),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Vider la corbeille',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        // Info bandeau
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: AppTheme.borderRadiusSmall,
                            border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange[700], size: 20),
                              const SizedBox(width: AppTheme.spacing8),
                              Expanded(
                                child: Text(
                                  'Les éléments dans la corbeille sont automatiquement supprimés après 30 jours.',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing16),

                        // Onglets
                        TabBar(
                          controller: _tabController,
                          labelColor: AppTheme.primary,
                          unselectedLabelColor: AppTheme.textLight,
                          indicatorColor: AppTheme.primary,
                          tabs: [
                            Tab(
                              text: 'Factures (${vm.deletedFactures.length})',
                              icon: const Icon(Icons.receipt_long, size: 20),
                            ),
                            Tab(
                              text: 'Devis (${vm.deletedDevis.length})',
                              icon: const Icon(Icons.description, size: 20),
                            ),
                            Tab(
                              text: 'Clients (${vm.deletedClients.length})',
                              icon: const Icon(Icons.people, size: 20),
                            ),
                            Tab(
                              text: 'Dépenses (${vm.deletedDepenses.length})',
                              icon: const Icon(Icons.shopping_bag, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing8),

                        // Contenu onglets
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildFacturesList(vm),
                              _buildDevisList(vm),
                              _buildClientsList(vm),
                              _buildDepensesList(vm),
                            ],
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline,
              size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'La corbeille est vide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Les éléments supprimés apparaîtront ici',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // --- Listes par type ---

  Widget _buildFacturesList(CorbeilleViewModel vm) {
    if (vm.deletedFactures.isEmpty) {
      return _buildTabEmpty('Aucune facture supprimée');
    }
    return ListView.builder(
      itemCount: vm.deletedFactures.length,
      itemBuilder: (context, index) {
        final f = vm.deletedFactures[index];
        return _buildItemCard(
          icon: Icons.receipt_long,
          iconColor: AppTheme.primary,
          title: f.numeroFacture.isNotEmpty ? f.numeroFacture : 'Brouillon',
          subtitle: f.objet,
          trailing: '${f.totalTtc.toDouble().toStringAsFixed(2)} €',
          onRestore: () async {
            if (f.id != null) {
              await vm.restoreFacture(f.id!);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Facture restaurée')),
              );
            }
          },
          onPurge: () => _confirmPurge(
            context,
            'cette facture',
            () async {
              if (f.id != null) await vm.purgeFacture(f.id!);
            },
          ),
        );
      },
    );
  }

  Widget _buildDevisList(CorbeilleViewModel vm) {
    if (vm.deletedDevis.isEmpty) {
      return _buildTabEmpty('Aucun devis supprimé');
    }
    return ListView.builder(
      itemCount: vm.deletedDevis.length,
      itemBuilder: (context, index) {
        final d = vm.deletedDevis[index];
        return _buildItemCard(
          icon: Icons.description,
          iconColor: Colors.teal,
          title: d.numeroDevis.isNotEmpty ? d.numeroDevis : 'Brouillon',
          subtitle: d.objet,
          trailing: '${d.totalTtc.toDouble().toStringAsFixed(2)} €',
          onRestore: () async {
            if (d.id != null) {
              await vm.restoreDevis(d.id!);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Devis restauré')),
              );
            }
          },
          onPurge: () => _confirmPurge(
            context,
            'ce devis',
            () async {
              if (d.id != null) await vm.purgeDevis(d.id!);
            },
          ),
        );
      },
    );
  }

  Widget _buildClientsList(CorbeilleViewModel vm) {
    if (vm.deletedClients.isEmpty) {
      return _buildTabEmpty('Aucun client supprimé');
    }
    return ListView.builder(
      itemCount: vm.deletedClients.length,
      itemBuilder: (context, index) {
        final c = vm.deletedClients[index];
        return _buildItemCard(
          icon: Icons.person,
          iconColor: Colors.indigo,
          title: c.nomComplet,
          subtitle: c.email.isNotEmpty ? c.email : c.telephone,
          trailing: c.typeClient,
          onRestore: () async {
            if (c.id != null) {
              await vm.restoreClient(c.id!);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Client restauré')),
              );
            }
          },
          onPurge: () => _confirmPurge(
            context,
            'ce client',
            () async {
              if (c.id != null) await vm.purgeClient(c.id!);
            },
          ),
        );
      },
    );
  }

  Widget _buildDepensesList(CorbeilleViewModel vm) {
    if (vm.deletedDepenses.isEmpty) {
      return _buildTabEmpty('Aucune dépense supprimée');
    }
    return ListView.builder(
      itemCount: vm.deletedDepenses.length,
      itemBuilder: (context, index) {
        final d = vm.deletedDepenses[index];
        return _buildItemCard(
          icon: Icons.shopping_bag,
          iconColor: Colors.deepOrange,
          title: d.titre,
          subtitle: d.categorie,
          trailing: '${d.montant.toDouble().toStringAsFixed(2)} €',
          onRestore: () async {
            if (d.id != null) {
              await vm.restoreDepense(d.id!);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dépense restaurée')),
              );
            }
          },
          onPurge: () => _confirmPurge(
            context,
            'cette dépense',
            () async {
              if (d.id != null) await vm.purgeDepense(d.id!);
            },
          ),
        );
      },
    );
  }

  // --- Widgets utilitaires ---

  Widget _buildTabEmpty(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildItemCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onRestore,
    required VoidCallback onPurge,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusMedium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailing,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(width: AppTheme.spacing8),
            IconButton(
              tooltip: 'Restaurer',
              icon: const Icon(Icons.restore, color: Colors.green, size: 20),
              onPressed: onRestore,
            ),
            IconButton(
              tooltip: 'Supprimer définitivement',
              icon:
                  const Icon(Icons.delete_forever, color: Colors.red, size: 20),
              onPressed: onPurge,
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialogues de confirmation ---

  Future<void> _confirmPurge(
    BuildContext context,
    String itemName,
    Future<void> Function() onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suppression définitive'),
        content: Text(
          'Supprimer définitivement $itemName ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await onConfirm();
    }
  }

  Future<void> _confirmPurgeAll(
    BuildContext context,
    CorbeilleViewModel vm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider la corbeille'),
        content: Text(
          'Supprimer définitivement ${vm.totalItems} élément${vm.totalItems > 1 ? 's' : ''} ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.purgeAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corbeille vidée')),
      );
    }
  }
}
