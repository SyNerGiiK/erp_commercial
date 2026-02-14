import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/client_viewmodel.dart';
import '../models/client_model.dart';
import '../config/theme.dart';

class ClientSelectionDialog extends StatefulWidget {
  const ClientSelectionDialog({super.key});

  @override
  State<ClientSelectionDialog> createState() => _ClientSelectionDialogState();
}

class _ClientSelectionDialogState extends State<ClientSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientVM = Provider.of<ClientViewModel>(context);

    final filteredList = clientVM.clients.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.nomComplet.toLowerCase().contains(q) ||
          c.ville.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Sélectionner un client"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text("Aucun client trouvé"))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredList.length,
                      separatorBuilder: (ctx, i) => const Divider(),
                      itemBuilder: (context, index) {
                        final client = filteredList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              client.nomComplet.isNotEmpty
                                  ? client.nomComplet[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            client.nomComplet,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${client.ville} • ${client.email}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.pop(context, client),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Annuler"),
        ),
      ],
    );
  }
}
