import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../widgets/dialogs/transformation_dialog.dart';

import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../models/client_model.dart';
import '../models/devis_model.dart';
import '../services/pdf_service.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/statut_badge.dart';
import '../utils/format_utils.dart';
import '../config/theme.dart';

class ListeDevisView extends StatefulWidget {
  const ListeDevisView({super.key});

  @override
  State<ListeDevisView> createState() => _ListeDevisViewState();
}

class _ListeDevisViewState extends State<ListeDevisView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contextRef = context;
      Future.wait([
        Provider.of<DevisViewModel>(contextRef, listen: false).fetchDevis(),
        Provider.of<ClientViewModel>(contextRef, listen: false)
            .fetchClients(), // Important pour le PDF
        Provider.of<EntrepriseViewModel>(contextRef, listen: false)
            .fetchProfil()
      ]);
    });
  }

  Future<void> _genererPDF(Devis d) async {
    final clientVM = Provider.of<ClientViewModel>(context, listen: false);
    final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);

    // Récupération du client complet
    Client? client;
    try {
      client = clientVM.clients.firstWhere((c) => c.id == d.clientId);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur: Client introuvable")));
      return;
    }

    if (entVM.profil == null) await entVM.fetchProfil();

    if (!mounted) return;

    final bytes = await PdfService.generateDevis(d, client, entVM.profil);

    if (!mounted) return;

    await Printing.layoutPdf(
        onLayout: (format) async => bytes, name: 'Devis_${d.numeroDevis}.pdf');
  }

  void _showTransformationDialog(Devis d) async {
    final result = await showDialog<TransformationResultWrapper>(
      context: context,
      builder: (ctx) => TransformationDialog(
          totalTTC: d.totalHt *
              (Decimal.one +
                  (Decimal.parse(
                      d.tvaIntra != null ? "0" : "0.20")))), // Basic Approx TTC
    );

    if (result == null || !mounted) return;

    final vm = Provider.of<DevisViewModel>(context, listen: false);

    try {
      final draftFacture = vm.prepareFacture(
          d,
          result.type.name, // 'standard', 'acompte', ...
          result.value,
          result.isPercent);

      if (!mounted) return;

      // Stocker le draft dans le ViewModel au lieu de le passer via extra
      vm.setPendingDraftFacture(draftFacture);

      // Navigation avec flag simple
      context.push('/app/ajout_facture?from_transformation=true');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur préparation facture: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DevisViewModel>(context);
    final clientVM = Provider.of<ClientViewModel>(context);

    return BaseScreen(
      menuIndex: 1,
      title: "Mes Devis",
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/app/ajout_devis'),
        child: const Icon(Icons.add),
      ),
      appBarBottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: "Tous"),
          Tab(text: "En cours"),
          Tab(text: "Signés"),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildList(vm.devis, clientVM),
          _buildList(
              vm.devis
                  .where((d) => d.statut == 'brouillon' || d.statut == 'envoye')
                  .toList(),
              clientVM),
          _buildList(
              vm.devis.where((d) => d.statut == 'signe').toList(), clientVM),
        ],
      ),
    );
  }

  Widget _buildList(List<Devis> list, ClientViewModel clientVM) {
    if (list.isEmpty) {
      return const Center(child: Text("Aucun devis"));
    }
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final d = list[index];
        // Tentative de trouver le nom du client
        final client = clientVM.clients
            .cast<Client?>()
            .firstWhere((c) => c?.id == d.clientId, orElse: () => null);

        // Couleur statut
        Color statusColor = Colors.grey;
        if (d.statut == 'signe') statusColor = Colors.green;
        if (d.statut == 'envoye') statusColor = Colors.blue;

        return AppCard(
          onTap: () => context.go('/app/ajout_devis/${d.id}', extra: d),
          statusColor: statusColor,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(d.numeroDevis,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        StatutBadge(statut: d.statut, isSmall: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (client != null)
                      Text(client.nomComplet,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(d.objet,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(FormatUtils.currency(d.totalHt),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(FormatUtils.date(d.dateEmission),
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (val) {
                  if (val == 'pdf') _genererPDF(d);
                  if (val == 'facture') _showTransformationDialog(d);
                  if (val == 'archive') {
                    Provider.of<DevisViewModel>(context, listen: false)
                        .toggleArchive(d, true);
                  }
                  if (val == 'delete') {
                    Provider.of<DevisViewModel>(context, listen: false)
                        .deleteDevis(d.id!);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'pdf', child: Text("Voir PDF")),
                  if (d.statut == 'signe' || d.statut == 'envoye')
                    const PopupMenuItem(
                        value: 'facture', child: Text("Créer Facture")),
                  const PopupMenuItem(
                      value: 'archive', child: Text("Archiver")),
                  if (d.statut == 'brouillon')
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text("Supprimer",
                            style: TextStyle(color: Colors.red))),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
