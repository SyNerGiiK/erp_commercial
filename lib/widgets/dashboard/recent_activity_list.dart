import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import '../../models/facture_model.dart';
import '../../models/devis_model.dart';
import '../../utils/format_utils.dart';

class RecentActivityList extends StatelessWidget {
  final List<dynamic> items; // Mix of Facture and Devis
  final Function(dynamic) onTap;

  const RecentActivityList({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Activité Récente",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E5572),
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Aucune activité récente."),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildListItem(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(dynamic item) {
    IconData icon;
    Color color;
    String title;
    String subtitle;
    String amount;
    String date;

    if (item is Facture) {
      icon = Icons.receipt;
      color = item.statut == 'payee' ? Colors.green : Colors.orange;
      title = "Facture ${item.numeroFacture}";
      subtitle = item.objet;
      amount = FormatUtils.currency(item.totalHt *
          (Decimal.one +
              (Decimal.parse(
                  "0.20")))); // TTC approx ou HT ? Let's use HT for now as consistent with app
      // Actually app uses HT mostly. Let's show HT.
      amount = "${FormatUtils.currency(item.totalHt)} HT";
      date = DateFormat('dd/MM').format(item.dateEmission);
    } else if (item is Devis) {
      icon = Icons.description;
      color = item.statut == 'signe' ? Colors.green : Colors.blue;
      title = "Devis ${item.numeroDevis}";
      subtitle = item.objet;
      amount = "${FormatUtils.currency(item.totalHt)} HT";
      date = DateFormat('dd/MM').format(item.dateEmission);
    } else {
      return Container();
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      onTap: () => onTap(item),
      contentPadding: EdgeInsets.zero,
    );
  }
}
