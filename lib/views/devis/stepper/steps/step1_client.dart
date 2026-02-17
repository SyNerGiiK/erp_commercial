import 'package:flutter/material.dart';
import '../../../../models/client_model.dart';
import '../../../../widgets/client_selection_dialog.dart';
import '../../../../widgets/app_card.dart';

class DevisStep1Client extends StatelessWidget {
  final Client? selectedClient;
  final ValueChanged<Client?> onClientChanged;

  const DevisStep1Client({
    super.key,
    required this.selectedClient,
    required this.onClientChanged,
  });

  Future<void> _selectClient(BuildContext context) async {
    final client = await showDialog<Client>(
      context: context,
      builder: (_) => const ClientSelectionDialog(),
    );
    if (client != null) {
      onClientChanged(client);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sélectionnez le client pour ce devis",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (selectedClient != null) ...[
          AppCard(
            title: const Text("Client Sélectionné",
                style: TextStyle(color: Colors.green)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                    selectedClient!.nomComplet.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(selectedClient!.nomComplet,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selectedClient!.email),
                  if (selectedClient!.telephone.isNotEmpty)
                    Text(selectedClient!.telephone),
                  Text(
                      "${selectedClient!.adresse}, ${selectedClient!.codePostal} ${selectedClient!.ville}"),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => onClientChanged(null),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _selectClient(context),
            icon: Icon(
                selectedClient == null ? Icons.person_add : Icons.swap_horiz),
            label: Text(selectedClient == null
                ? "Sélectionner un Client"
                : "Changer de Client"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
