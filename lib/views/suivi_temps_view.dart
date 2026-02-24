import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../viewmodels/temps_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../models/temps_activite_model.dart';
import '../widgets/base_screen.dart';
import '../widgets/aurora/glass_container.dart';
import 'package:decimal/decimal.dart';

/// Vue du suivi du temps d'activité
class SuiviTempsView extends StatefulWidget {
  const SuiviTempsView({super.key});

  @override
  State<SuiviTempsView> createState() => _SuiviTempsViewState();
}

class _SuiviTempsViewState extends State<SuiviTempsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TempsViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TempsViewModel>();
    final clientVM = context.watch<ClientViewModel>();

    return BaseScreen(
      menuIndex: 14,
      title: 'Suivi du temps',
      headerActions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              vm.totalHeuresMoisFormate,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, clientVM),
        icon: const Icon(Icons.add),
        label: const Text('Saisir du temps'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.items.isEmpty
              ? _buildEmptyState()
              : _buildContent(vm, clientVM),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucun temps enregistré',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'Suivez votre temps de travail pour mieux facturer',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TempsViewModel vm, ClientViewModel clientVM) {
    return Column(
      children: [
        // KPI Bar
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildKpi(
                'Ce mois',
                vm.totalHeuresMoisFormate,
                Icons.access_time_rounded,
                AppTheme.primary,
              ),
              _buildKpi(
                'CA potentiel',
                '${vm.caPotentiel.toDouble().toStringAsFixed(0)} €',
                Icons.euro,
                AppTheme.accent,
              ),
              _buildKpi(
                'Non facturé',
                '${vm.nonFactures.length}',
                Icons.pending_actions_rounded,
                AppTheme.warning,
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.items.length,
            itemBuilder: (context, index) {
              final item = vm.items[index];
              final clientName = clientVM.clients
                      .where((c) => c.id == item.clientId)
                      .map((c) => c.nomComplet)
                      .firstOrNull ??
                  'Sans client';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: item.estFacture
                          ? AppTheme.accent.withValues(alpha: 0.1)
                          : item.estFacturable
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                      radius: 20,
                      child: Icon(
                        item.estFacture
                            ? Icons.check_circle
                            : Icons.timer_outlined,
                        size: 20,
                        color: item.estFacture
                            ? AppTheme.accent
                            : item.estFacturable
                                ? AppTheme.primary
                                : Colors.grey,
                      ),
                    ),
                    title: Text(
                      item.description,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          '${item.dateActivite.day}/${item.dateActivite.month}/${item.dateActivite.year}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          clientName,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        if (item.projet.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.projet,
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.dureeFormatee,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (item.montant > Decimal.zero)
                          Text(
                            '${item.montant.toDouble().toStringAsFixed(2)} €',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                    onLongPress: () => _confirmDelete(item),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKpi(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(TempsActivite item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette entrée ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TempsViewModel>().delete(item.id!);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, ClientViewModel clientVM) {
    final descCtrl = TextEditingController();
    final dureeCtrl = TextEditingController();
    final tauxCtrl = TextEditingController(text: '50');
    final projetCtrl = TextEditingController();
    String? selectedClientId;
    bool facturable = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Saisir du temps'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: projetCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Projet',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(selectedClientId),
                  initialValue: selectedClientId,
                  decoration: const InputDecoration(
                    labelText: 'Client',
                    border: OutlineInputBorder(),
                  ),
                  items: clientVM.clients
                      .map((c) => DropdownMenuItem(
                          value: c.id, child: Text(c.nomComplet)))
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedClientId = val),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dureeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Durée (min) *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: tauxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Taux horaire (€)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Facturable'),
                  value: facturable,
                  activeTrackColor: AppTheme.primary,
                  onChanged: (val) => setDialogState(() => facturable = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (descCtrl.text.isEmpty || dureeCtrl.text.isEmpty) return;
                final temps = TempsActivite(
                  description: descCtrl.text,
                  projet: projetCtrl.text,
                  clientId: selectedClientId,
                  dateActivite: DateTime.now(),
                  dureeMinutes: int.tryParse(dureeCtrl.text) ?? 0,
                  tauxHoraire: Decimal.parse(
                      tauxCtrl.text.isEmpty ? '0' : tauxCtrl.text),
                  estFacturable: facturable,
                );
                Navigator.pop(ctx);
                context.read<TempsViewModel>().create(temps);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
