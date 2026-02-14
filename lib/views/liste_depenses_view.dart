import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/depense_viewmodel.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../utils/format_utils.dart';
import '../config/theme.dart';

class ListeDepensesView extends StatefulWidget {
  const ListeDepensesView({super.key});

  @override
  State<ListeDepensesView> createState() => _ListeDepensesViewState();
}

class _ListeDepensesViewState extends State<ListeDepensesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DepenseViewModel>(context, listen: false).fetchDepenses();
    });
  }

  IconData _getIcon(String categorie) {
    switch (categorie.toLowerCase()) {
      case 'carburant':
        return Icons.local_gas_station;
      case 'materiaux':
        return Icons.build;
      case 'outillage':
        return Icons.handyman;
      case 'repas':
        return Icons.restaurant;
      case 'assurance':
        return Icons.security;
      case 'bureau':
        return Icons.desktop_mac;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DepenseViewModel>(context);

    return BaseScreen(
      menuIndex: 5, // INDEX IMPORTANT
      title: "Dépenses",
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/ajout_depense'),
        child: const Icon(Icons.add),
      ),
      child: Column(children: [
        AppCard(
            title: const Text("Total Période"),
            trailing: Text("- ${FormatUtils.currency(vm.totalDepenses)}",
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18))),
        const SizedBox(height: 20),
        Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: vm.depenses.length,
                    itemBuilder: (context, index) {
                      final d = vm.depenses[index];
                      return AppCard(
                        // Navigation URL First
                        onTap: () =>
                            context.go('/ajout_depense/${d.id}', extra: d),
                        leading:
                            Icon(_getIcon(d.categorie), color: Colors.orange),
                        title: Text(d.titre),
                        subtitle: Text(FormatUtils.date(d.date)),
                        trailing: Text("- ${FormatUtils.currency(d.montant)}"),
                      );
                    }))
      ]),
    );
  }
}
