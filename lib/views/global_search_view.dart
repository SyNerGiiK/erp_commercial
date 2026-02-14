import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/global_search_viewmodel.dart';
import '../widgets/base_screen.dart';
import '../config/theme.dart';

class GlobalSearchView extends StatefulWidget {
  const GlobalSearchView({super.key});

  @override
  State<GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<GlobalSearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<GlobalSearchViewModel>(context);

    return BaseScreen(
      title: "Recherche Globale",
      menuIndex: -1,
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: "Rechercher (Client, Facture...)",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none)),
                onChanged: (val) => vm.search(val))),
        if (vm.isLoading) const LinearProgressIndicator(color: AppTheme.accent),
        Expanded(
            child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
              if (vm.clientsResults.isNotEmpty) ...[
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("CLIENTS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey))),
                ...vm.clientsResults.map((c) => Card(
                        child: ListTile(
                      leading: const CircleAvatar(
                          backgroundColor: AppTheme.primary,
                          child: Icon(Icons.person, color: Colors.white)),
                      title: Text(c.nomComplet),
                      subtitle: Text(c.ville),
                      onTap: () =>
                          context.go('/ajout_client/${c.id}', extra: c),
                    ))),
              ],
              if (vm.facturesResults.isNotEmpty) ...[
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("FACTURES",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey))),
                ...vm.facturesResults.map((f) => Card(
                        child: ListTile(
                      leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.euro, color: Colors.white)),
                      title: Text(f.numeroFacture),
                      subtitle: Text(f.objet),
                      onTap: () =>
                          context.go('/ajout_facture/${f.id}', extra: f),
                    ))),
              ],
              if (vm.devisResults.isNotEmpty) ...[
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("DEVIS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey))),
                ...vm.devisResults.map((d) => Card(
                        child: ListTile(
                      leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.description, color: Colors.white)),
                      title: Text(d.numeroDevis),
                      subtitle: Text(d.objet),
                      onTap: () => context.go('/ajout_devis/${d.id}', extra: d),
                    ))),
              ],
            ]))
      ]),
    );
  }
}
