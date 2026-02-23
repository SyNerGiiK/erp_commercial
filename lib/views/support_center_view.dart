import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/support_viewmodel.dart';
import '../models/support_ticket_model.dart';
import '../config/theme.dart';
// Note: We use the AppLayout if it exists, or just a Scaffold.
// Often there is a custom AppBar/Drawer depending on the app's structure.
// I will just return a Scaffold here, and the app's navigation structure can wrap it.

class SupportCenterView extends StatefulWidget {
  const SupportCenterView({super.key});

  @override
  State<SupportCenterView> createState() => _SupportCenterViewState();
}

class _SupportCenterViewState extends State<SupportCenterView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportViewModel>().fetchTickets();
    });
  }

  void _showNewTicketDialog() {
    final subjectCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau ticket Support',
              style: TextStyle(fontFamily: 'Space Grotesk')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(labelText: 'Sujet'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionCtrl,
                maxLines: 4,
                decoration:
                    const InputDecoration(labelText: 'Description (détaillée)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (subjectCtrl.text.isEmpty || descriptionCtrl.text.isEmpty) {
                  return;
                }

                final vm = context.read<SupportViewModel>();
                final nav = Navigator.of(context);

                final ticket = SupportTicket(
                  subject: subjectCtrl.text,
                  description: descriptionCtrl.text,
                );

                final success = await vm.createTicket(ticket);
                if (!context.mounted) return;

                if (success) {
                  nav.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Ticket envoyé ! L\'I.A. va vous répondre très vite.')),
                  );
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support AI & Centre d\'aide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nouveau ticket',
            onPressed: _showNewTicketDialog,
          ),
        ],
      ),
      body: Consumer<SupportViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.tickets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.support_agent, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Aucun ticket actif.',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showNewTicketDialog,
                    child: const Text('Demander de l\'aide à CraftOS IA'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.tickets.length,
            itemBuilder: (context, index) {
              final ticket = vm.tickets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(ticket.subject,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Chip(
                            label: Text(ticket.status == 'resolved'
                                ? 'Résolu par IA'
                                : 'En attente'),
                            backgroundColor: ticket.status == 'resolved'
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.orange.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Vous: ${ticket.description}",
                          style: TextStyle(color: Colors.grey[700])),
                      if (ticket.aiResolution != null) ...[
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    "CraftOS AI: ${ticket.aiResolution!}")),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
