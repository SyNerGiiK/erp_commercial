import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/client_viewmodel.dart';
import '../models/client_model.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../config/theme.dart';

class ListeClientsView extends StatefulWidget {
  const ListeClientsView({super.key});

  @override
  State<ListeClientsView> createState() => _ListeClientsViewState();
}

class _ListeClientsViewState extends State<ListeClientsView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientViewModel>(context, listen: false).fetchClients();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientVM = Provider.of<ClientViewModel>(context);

    final filteredList = clientVM.clients.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.nomComplet.toLowerCase().contains(q) ||
          c.ville.toLowerCase().contains(q);
    }).toList();

    return BaseScreen(
      menuIndex: 3, // CORRECTION: Index Clients
      title: "Clients",
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/app/ajout_client'),
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: clientVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final client = filteredList[index];
                      return AppCard(
                        onTap: () => context.go(
                            '/app/ajout_client/${client.id}',
                            extra: client),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              AppTheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            client.nomComplet.isNotEmpty
                                ? client.nomComplet[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                        title: Text(client.nomComplet),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(client.ville.isNotEmpty
                                ? client.ville
                                : "Non renseigné"),
                          ],
                        ),
                        trailing:
                            const Icon(Icons.chevron_right, color: Colors.grey),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
