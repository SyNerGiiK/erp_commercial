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
import '../widgets/dialogs/paiement_dialog.dart'; // Added
import '../utils/format_utils.dart';
import '../config/theme.dart';
import '../models/paiement_model.dart'; // Added
import '../services/email_service.dart';
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
    _tabController = TabController(length: 5, vsync: this); // 5 Tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context;
      Future.wait([
        Provider.of<FactureViewModel>(c, listen: false).fetchFactures(),
        Provider.of<ClientViewModel>(c, listen: false).fetchClients(),
        Provider.of<EntrepriseViewModel>(c, listen: false).fetchProfil()
      ]);
    });
  }

  // ... (Keep _genererPDF helper) ...
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

    // Résoudre le numéro de facture source pour les avoirs
    String? factureSourceNumero;
    if (f.type == 'avoir' && f.factureSourceId != null) {
      final factureVM = Provider.of<FactureViewModel>(context, listen: false);
      try {
        factureSourceNumero = factureVM.factures
            .firstWhere((x) => x.id == f.factureSourceId)
            .numeroFacture;
      } catch (_) {
        // Facture source non trouvée en cache — ignoré
      }
    }

    final bytes = await PdfService.generateDocument(f, client, entVM.profil,
        docType: "FACTURE",
        isTvaApplicable: entVM.isTvaApplicable,
        factureSourceNumero: factureSourceNumero);

    if (!mounted) return;

    await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Facture_${f.numeroFacture}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FactureViewModel>(context);
    final clientVM = Provider.of<ClientViewModel>(context);

    // Filters
    final brouillons = vm.factures
        .where((f) =>
            f.statut.toLowerCase() == 'brouillon' ||
            f.numeroFacture == 'Brouillon') // Fallback
        .toList();
    final validees =
        vm.factures.where((f) => f.statut.toLowerCase() == 'validee').toList();
    final envoyees = vm.factures.where((f) => f.statut == 'envoye').toList();
    final payees = vm.factures.where((f) => f.statut == 'payee').toList();

    return BaseScreen(
      menuIndex: 2,
      title: "Mes Factures",
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/app/ajout_facture'),
        child: const Icon(Icons.add),
      ),
      appBarBottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: "Toutes"),
          Tab(text: "Brouillons"),
          Tab(text: "Validées"),
          Tab(text: "Envoyées"),
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
          _buildList(brouillons, clientVM),
          _buildList(validees, clientVM),
          _buildList(envoyees, clientVM),
          _buildList(payees, clientVM),
        ],
      ),
    );
  }

  Future<void> _envoyerParEmail(Facture f) async {
    final clientVM = Provider.of<ClientViewModel>(context, listen: false);
    final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);

    Client? client;
    try {
      client = clientVM.clients.firstWhere((c) => c.id == f.clientId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Client introuvable pour ce document")));
      return;
    }

    final result = await EmailService.envoyerFacture(
        facture: f, client: client, profil: entVM.profil);

    if (!mounted) return;

    if (result.success) {
      // Marquer comme envoyé si encore en statut validée
      if (f.statut == 'validee') {
        final vm = Provider.of<FactureViewModel>(context, listen: false);
        await vm.markAsSent(f.id!);
        if (!mounted) return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Client email ouvert avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? "Erreur email")));
    }
  }

  Future<void> _showPaiementDialog(Facture f) async {
    final result = await showDialog<Paiement>(
      context: context,
      builder: (_) => const PaiementDialog(),
    );

    if (result != null && mounted) {
      if (f.id == null) return;

      final vm = Provider.of<FactureViewModel>(context, listen: false);
      final p = result.copyWith(factureId: f.id);

      final success = await vm.addPaiement(p);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Paiement ajouté avec succès")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Erreur lors de l'ajout")));
        }
      }
    }
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

        // Calculs locaux

        Color itemColor = Colors.orange;
        if (f.statut == 'payee') itemColor = Colors.green;
        if (f.statut == 'envoye') itemColor = Colors.blue;
        if (f.statut == 'validee') itemColor = Colors.indigo;
        if (f.statut == 'brouillon') itemColor = Colors.grey;

        return AppCard(
          onTap: () => context.go('/app/ajout_facture/${f.id}', extra: f),
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
                  onSelected: (val) async {
                    final vm =
                        Provider.of<FactureViewModel>(context, listen: false);
                    if (val == 'pdf') {
                      _genererPDF(f);
                      return;
                    }
                    if (val == 'email') {
                      _envoyerParEmail(f);
                      return;
                    }
                    if (val == 'sent') {
                      await vm.markAsSent(f.id!);
                      return;
                    }
                    if (val == 'paiement') {
                      _showPaiementDialog(f);
                      return;
                    }
                    if (val == 'archive') {
                      vm.toggleArchive(f, true);
                      return;
                    }
                    if (val == 'delete') {
                      await vm.deleteFacture(f.id!);
                      if (!mounted) return;
                      // errorMessage removed from FactureViewModel
                      return;
                    }
                    if (val == 'avoir') {
                      context.go(Uri(
                              path: '/app/ajout_facture',
                              queryParameters: {'source_facture': f.id})
                          .toString());
                      return;
                    }
                  },
                  itemBuilder: (ctx) => [
                        if (f.statut == 'validee')
                          const PopupMenuItem(
                              value: 'sent',
                              child: Text("Marquer comme envoyé")),
                        if (f.statut == 'validee' || f.statut == 'envoye')
                          const PopupMenuItem(
                              value: 'email',
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.email_rounded, size: 20),
                                title: Text("Envoyer par email"),
                              )),
                        if (f.statut != 'brouillon' && f.statut != 'annulee')
                          const PopupMenuItem(
                              value: 'paiement',
                              child: Text("Ajouter règlement")),
                        const PopupMenuItem(
                            value: 'pdf', child: Text("Voir PDF")),
                        const PopupMenuItem(
                            value: 'archive', child: Text("Archiver")),
                        if (f.statut != 'brouillon' && f.type != 'avoir')
                          const PopupMenuItem(
                              value: 'avoir', child: Text("Créer Avoir")),
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
