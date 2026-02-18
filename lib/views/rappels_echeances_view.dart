import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/rappel_model.dart';
import '../viewmodels/rappel_viewmodel.dart';
import '../widgets/custom_drawer.dart';

/// Vue des rappels et échéances fiscales/documentaires
class RappelsEcheancesView extends StatefulWidget {
  const RappelsEcheancesView({super.key});

  @override
  State<RappelsEcheancesView> createState() => _RappelsEcheancesViewState();
}

class _RappelsEcheancesViewState extends State<RappelsEcheancesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RappelViewModel>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RappelViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rappels & Échéances'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('À venir'),
                  if (vm.nbUrgents > 0) ...[
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppTheme.error,
                      child: Text(
                        '${vm.nbUrgents}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Tous'),
            Tab(text: 'Complétés (${vm.completes.length})'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.auto_awesome),
            onSelected: (value) => _handleAutoGenerate(value),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'urssaf_mensuel',
                child: Text('Générer rappels URSSAF (mensuel)'),
              ),
              const PopupMenuItem(
                value: 'urssaf_trimestriel',
                child: Text('Générer rappels URSSAF (trimestriel)'),
              ),
              const PopupMenuItem(
                value: 'cfe',
                child: Text('Générer rappel CFE'),
              ),
              const PopupMenuItem(
                value: 'impots',
                child: Text('Générer rappel Impôts'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      drawer: const CustomDrawer(selectedIndex: 15),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(vm.actifs, showEmpty: 'Aucune échéance à venir'),
                _buildList(vm.items, showEmpty: 'Aucun rappel'),
                _buildList(vm.completes, showEmpty: 'Aucun rappel complété'),
              ],
            ),
    );
  }

  Widget _buildList(List<Rappel> items, {required String showEmpty}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(showEmpty,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final rappel = items[index];
        return _buildRappelCard(rappel);
      },
    );
  }

  Widget _buildRappelCard(Rappel rappel) {
    final Color color;
    if (rappel.estComplete) {
      color = Colors.grey;
    } else if (rappel.estEnRetard) {
      color = AppTheme.error;
    } else if (rappel.estProche) {
      color = AppTheme.warning;
    } else {
      color = AppTheme.primary;
    }

    final joursText = rappel.estComplete
        ? 'Complété'
        : rappel.joursRestants < 0
            ? '${-rappel.joursRestants}j de retard'
            : rappel.joursRestants == 0
                ? "Aujourd'hui"
                : 'Dans ${rappel.joursRestants}j';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: rappel.estEnRetard
              ? AppTheme.error.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              rappel.typeRappel.icon,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                rappel.titre,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration:
                      rappel.estComplete ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                joursText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rappel.description != null && rappel.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  rappel.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rappel.typeRappel.label,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${rappel.dateEcheance.day}/${rappel.dateEcheance.month}/${rappel.dateEcheance.year}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (rappel.priorite == PrioriteRappel.urgente) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.error),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: rappel.estComplete
            ? IconButton(
                icon: const Icon(Icons.undo, color: Colors.grey),
                onPressed: () =>
                    context.read<RappelViewModel>().decompleter(rappel.id!),
              )
            : IconButton(
                icon: Icon(Icons.check_circle_outline, color: color),
                onPressed: () =>
                    context.read<RappelViewModel>().completer(rappel.id!),
              ),
        onLongPress: () => _confirmDelete(rappel),
      ),
    );
  }

  void _handleAutoGenerate(String type) async {
    final vm = context.read<RappelViewModel>();
    final annee = DateTime.now().year;

    List<Rappel> rappels = [];
    switch (type) {
      case 'urssaf_mensuel':
        rappels = RappelViewModel.genererRappelsUrssaf(annee: annee);
        break;
      case 'urssaf_trimestriel':
        rappels = RappelViewModel.genererRappelsUrssaf(
            annee: annee, trimestriel: true);
        break;
      case 'cfe':
        rappels = [RappelViewModel.genererRappelCFE(annee)];
        break;
      case 'impots':
        rappels = [RappelViewModel.genererRappelImpots(annee)];
        break;
    }

    for (final r in rappels) {
      await vm.create(r);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${rappels.length} rappel(s) généré(s)'),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _confirmDelete(Rappel rappel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce rappel ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RappelViewModel>().delete(rappel.id!);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titreCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    TypeRappel selectedType = TypeRappel.custom;
    PrioriteRappel selectedPriorite = PrioriteRappel.normale;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau rappel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TypeRappel>(
                  key: ValueKey(selectedType),
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: TypeRappel.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text('${t.icon} ${t.label}')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedType = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PrioriteRappel>(
                  key: ValueKey(selectedPriorite),
                  initialValue: selectedPriorite,
                  decoration: const InputDecoration(
                    labelText: 'Priorité',
                    border: OutlineInputBorder(),
                  ),
                  items: PrioriteRappel.values
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p.label)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedPriorite = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Échéance : ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
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
                if (titreCtrl.text.isEmpty) return;
                final rappel = Rappel(
                  titre: titreCtrl.text,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                  typeRappel: selectedType,
                  dateEcheance: selectedDate,
                  priorite: selectedPriorite,
                );
                Navigator.pop(ctx);
                context.read<RappelViewModel>().create(rappel);
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}
