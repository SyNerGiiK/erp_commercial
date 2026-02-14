import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/facture_viewmodel.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../config/theme.dart';
import '../utils/format_utils.dart';

class ArchivesView extends StatefulWidget {
  const ArchivesView({super.key});

  @override
  State<ArchivesView> createState() => _ArchivesViewState();
}

class _ArchivesViewState extends State<ArchivesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FactureViewModel>(context, listen: false).fetchArchives();
      Provider.of<DevisViewModel>(context, listen: false).fetchArchives();
    });
  }

  @override
  Widget build(BuildContext context) {
    final factureVM = Provider.of<FactureViewModel>(context);
    final devisVM = Provider.of<DevisViewModel>(context);

    return BaseScreen(
      menuIndex: 10, // INDEX IMPORTANT
      title: "Archives",
      appBarBottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: "Factures"),
          Tab(text: "Devis"),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          // FACTURES
          ListView.builder(
            itemCount: factureVM.archives.length,
            itemBuilder: (ctx, i) {
              final f = factureVM.archives[i];
              return AppCard(
                title: Text(f.numeroFacture),
                subtitle: Text(f.objet),
                trailing: Text(FormatUtils.currency(f.totalHt)),
                onTap: () {
                  _showRestoreDialog(context, 'facture', () {
                    factureVM.toggleArchive(f, false);
                  });
                },
              );
            },
          ),
          // DEVIS
          ListView.builder(
            itemCount: devisVM.archives.length,
            itemBuilder: (ctx, i) {
              final d = devisVM.archives[i];
              return AppCard(
                title: Text(d.numeroDevis),
                subtitle: Text(d.objet),
                trailing: Text(FormatUtils.currency(d.totalHt)),
                onTap: () {
                  _showRestoreDialog(context, 'devis', () {
                    devisVM.toggleArchive(d, false);
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(
      BuildContext context, String type, VoidCallback onRestore) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Restaurer ce $type ?"),
        content: const Text("Il réapparaîtra dans la liste principale."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              onRestore();
              Navigator.pop(c);
            },
            child: const Text("Restaurer"),
          )
        ],
      ),
    );
  }
}
