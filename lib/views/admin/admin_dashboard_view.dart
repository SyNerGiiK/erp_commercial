import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../config/theme.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().refreshAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: Colors.black, // Dark mode strict for God Mode
      appBar: AppBar(
        title: const Text('SUPER-COCKPIT (God Mode)'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/app/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.refreshAll(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Data & Metrics'),
            Tab(icon: Icon(Icons.view_kanban), text: 'Support Kanban'),
            Tab(icon: Icon(Icons.bug_report), text: 'Crash Logs'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMetricsTab(vm),
                _buildKanbanTab(vm),
                _buildCrashLogsTab(vm),
              ],
            ),
    );
  }

  Widget _buildMetricsTab(AdminViewModel vm) {
    final metrics = vm.dbMetrics;
    if (metrics == null) {
      return const Center(
          child: Text("Aucune métrique disponible",
              style: TextStyle(color: Colors.white)));
    }

    final dbSize = metrics['total_size_mb'] ?? 0;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text("État de la Base de Données",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: "Taille Totale",
                value: "$dbSize MB",
                icon: Icons.storage,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                title: "Crash Logs Enregistrés",
                value: "${vm.crashLogs.length}",
                icon: Icons.warning,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: "Tickets Support",
                value: "${vm.tickets.length}",
                icon: Icons.support_agent,
                color: Colors.orangeAccent,
              ),
            ),
            const Expanded(child: SizedBox()), // Placeholder
          ],
        )
      ],
    );
  }

  Widget _buildKanbanTab(AdminViewModel vm) {
    final tickets = vm.tickets;
    if (tickets.isEmpty) {
      return const Center(
          child: Text("Aucun ticket", style: TextStyle(color: Colors.white)));
    }

    final ouvert = tickets.where((t) => t['status'] == 'open').toList();
    final encours = tickets.where((t) => t['status'] == 'in_progress').toList();
    final resolu = tickets.where((t) => t['status'] == 'resolved').toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: _KanbanColumn(
                title: 'Ouvert',
                tickets: ouvert,
                vm: vm,
                color: Colors.redAccent)),
        const VerticalDivider(width: 1, color: Colors.grey),
        Expanded(
            child: _KanbanColumn(
                title: 'En Cours',
                tickets: encours,
                vm: vm,
                color: Colors.orangeAccent)),
        const VerticalDivider(width: 1, color: Colors.grey),
        Expanded(
            child: _KanbanColumn(
                title: 'Résolu',
                tickets: resolu,
                vm: vm,
                color: Colors.greenAccent)),
      ],
    );
  }

  Widget _buildCrashLogsTab(AdminViewModel vm) {
    final logs = vm.crashLogs;
    if (logs.isEmpty) {
      return const Center(
          child:
              Text("Aucun crash log", style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final isResolved = log['resolved'] == true;
        return Card(
          color: isResolved
              ? Colors.grey[900]
              : Colors.red[900]?.withValues(alpha: 0.3),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(log['error_message'] ?? 'Erreur Inconnue',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Date: ${log['created_at']} - v${log['app_version']}",
                style: const TextStyle(color: Colors.white70)),
            trailing: isResolved
                ? const Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    tooltip: 'Marquer comme résolu',
                    onPressed: () => vm.resolveCrashLog(log['id']),
                  ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                    log['stack_trace'] ?? 'Pas de stack trace',
                    style: const TextStyle(
                        color: Colors.grey, fontFamily: 'monospace')),
              )
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> tickets;
  final AdminViewModel vm;
  final Color color;

  const _KanbanColumn(
      {required this.title,
      required this.tickets,
      required this.vm,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: color.withValues(alpha: 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                CircleAvatar(
                    backgroundColor: color,
                    radius: 12,
                    child: Text('${tickets.length}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final t = tickets[index];
                return Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: color.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['subject'] ?? 'Sans Sujet',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(t['description'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                t['user_id']?.toString().substring(0, 8) ??
                                    'Inconnu',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 10)),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white, size: 16),
                              onSelected: (val) {
                                if (val == 'custom_resolve') {
                                  _showResolveDialog(context, vm, t['id']);
                                } else {
                                  vm.updateTicketStatus(t['id'], val);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'open', child: Text('Ouvert')),
                                const PopupMenuItem(
                                    value: 'in_progress',
                                    child: Text('En Cours')),
                                const PopupMenuItem(
                                    value: 'resolved',
                                    child: Text('Résolu (sans rps)')),
                                const PopupMenuItem(
                                    value: 'custom_resolve',
                                    child: Text('💬 Répondre & Résoudre')),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showResolveDialog(
      BuildContext context, AdminViewModel vm, String ticketId) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Répondre au ticket',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Saisissez la réponse à envoyer au client...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                vm.resolveTicketWithResponse(ticketId, controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Envoyer & Résoudre'),
          ),
        ],
      ),
    );
  }
}
