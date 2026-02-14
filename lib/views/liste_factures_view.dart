import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/facture_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../models/client_model.dart';
import '../models/facture_model.dart';
import '../services/pdf_service.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/statut_badge.dart';
import '../utils/format_utils.dart';
import '../config/theme.dart';
import 'package:decimal/decimal.dart';

class ListeFacturesView extends StatefulWidget {
  const ListeFacturesView({super.key});

  @override
  State<ListeFacturesView> createState() => _ListeFacturesViewState();
}

class _ListeFacturesViewState extends State<ListeFacturesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context;
      Future.wait([
        Provider.of<FactureViewModel>(c, listen: false).fetchFactures(),
        Provider.of<ClientViewModel>(c, listen: false).fetchClients(),
        Provider.of<EntrepriseViewModel>(c, listen: false).fetchProfil()
      ]);
    });
  }

  Future<void> _genererPDF(Facture f) async {
    final clientVM = Provider.of<ClientViewModel>(context, listen: false);
    final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);

    Client? client;
    try {
      client = clientVM.clients.firstWhere((c) => c.id == f.clientId);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Client introuvable pour ce document")));
      return;
    }

    if (entVM.profil == null) await entVM.fetchProfil();

    if (!mounted) return;

    final bytes = await PdfService.generateFacture(f, client, entVM.profil);

    if (!mounted) return;

    await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Facture_${f.numeroFacture}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FactureViewModel>(context);
    final clientVM = Provider.of<ClientViewModel>(context);

    return BaseScreen(
      menuIndex: 2,
      title: "Mes Factures",
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/ajout_facture'),
        child: const Icon(Icons.add),
      ),
      appBarBottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: "Toutes"),
          Tab(text: "En attente"),
          Tab(text: "Payées"),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildList(vm.factures, clientVM),
          _buildList(
              vm.factures.where((f) => f.statut != 'payee').toList(), clientVM),
          _buildList(
              vm.factures.where((f) => f.statut == 'payee').toList(), clientVM),
        ],
      ),
    );
  }

  Widget _buildList(List<Facture> list, ClientViewModel clientVM) {
    if (list.isEmpty) return const Center(child: Text("Aucune facture"));

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final f = list[index];
        final client = clientVM.clients
            .cast<Client?>()
            .firstWhere((c) => c?.id == f.clientId, orElse: () => null);

        // Calculs locaux (FIX TYPE)
        final totalRegle =
            f.paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);

        final montantRemise =
            ((f.totalHt * f.remiseTaux) / Decimal.fromInt(100)).toDecimal();
        final netAPayer = f.totalHt - montantRemise;
        final reste = netAPayer - totalRegle;

        final isPayee = reste <= Decimal.zero || f.statut == 'payee';
        final itemColor = isPayee ? Colors.green : Colors.orange;

        return AppCard(
          onTap: () => context.go('/ajout_facture/${f.id}', extra: f),
          statusColor: itemColor,
          child: Row(
            children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                      children: [
                        Text(f.numeroFacture,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        StatutBadge(statut: f.statut, isSmall: true),
                      ],
                    ),
                    if (client != null)
                      Text("• ${client.nomComplet}",
                          style: const TextStyle(color: Colors.grey)),
                    Text(f.objet),
                  ])),
              Text(FormatUtils.currency(f.totalHt),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: itemColor)),
              PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'pdf') _genererPDF(f);
                    if (val == 'archive') {
                      Provider.of<FactureViewModel>(context, listen: false)
                          .toggleArchive(f, true);
                    }
                    if (val == 'delete') {
                      // Correction: deleteFacture ne prend qu'un argument
                      Provider.of<FactureViewModel>(context, listen: false)
                          .deleteFacture(f.id!);
                    }
                  },
                  itemBuilder: (ctx) => [
                        const PopupMenuItem(
                            value: 'pdf', child: Text("Voir PDF")),
                        const PopupMenuItem(
                            value: 'archive', child: Text("Archiver")),
                        if (f.statut == 'brouillon')
                          const PopupMenuItem(
                              value: 'delete', child: Text("Supprimer"))
                      ])
            ],
          ),
        );
      },
    );
  }
}
