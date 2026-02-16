import 'package:flutter/material.dart';

class TopClientsCard extends StatelessWidget {
  final List<Map<String, dynamic>> clients;

  const TopClientsCard({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top Clients",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...clients.map((client) => ListTile(
                  leading: CircleAvatar(child: Text(client['name'][0])),
                  title: Text(client['name']),
                  trailing: Text("${client['ca']} €"),
                )),
          ],
        ),
      ),
    );
  }
}
