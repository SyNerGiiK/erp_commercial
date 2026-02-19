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
import '../viewmodels/facture_viewmodel.dart'; // Added for history
import '../repositories/chiffrage_repository.dart';
import '../utils/calculations_utils.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/statut_badge.dart';
import '../utils/format_utils.dart';
import '../config/theme.dart';
import '../services/email_service.dart';

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
    _tabController = TabController(length: 6, vsync: this); // 6 Tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contextRef = context;
      Future.wait([
        Provider.of<DevisViewModel>(contextRef, listen: false)
            .checkExpiredDevis(),
        Provider.of<DevisViewModel>(contextRef, listen: false).fetchDevis(),
        Provider.of<ClientViewModel>(contextRef, listen: false)
            .fetchClients(), // Important pour le PDF
        Provider.of<EntrepriseViewModel>(contextRef, listen: false)
            .fetchProfil()
      ]);
    });
  }

  Future<void> _genererPDF(Devis d, {String docType = "DEVIS"}) async {
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

    final bytes = await PdfService.generateDocument(d, client, entVM.profil,
        docType: docType, isTvaApplicable: entVM.isTvaApplicable);

    if (!mounted) return;

    await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: '${docType.replaceAll(" ", "_")}_${d.numeroDevis}.pdf');
  }

  Future<void> _envoyerDevisParEmail(Devis d) async {
    final clientVM = Provider.of<ClientViewModel>(context, listen: false);
    final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);

    Client? client;
    try {
      client = clientVM.clients.firstWhere((c) => c.id == d.clientId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Client introuvable pour ce devis")));
      return;
    }

    final result = await EmailService.envoyerDevis(
        devis: d, client: client, profil: entVM.profil);

    if (!mounted) return;

    if (result.success) {
      // Marquer comme envoyé si encore brouillon
      if (d.statut == 'brouillon') {
        final vm = Provider.of<DevisViewModel>(context, listen: false);
        await vm.markAsSent(d.id!);
        if (!mounted) return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Client email ouvert avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? "Erreur email")));
    }
  }

  void _showTransformationDialog(Devis d) async {
    final factureVM = Provider.of<FactureViewModel>(context, listen: false);

    // Calculer l'historique des règlements AVANT d'afficher le dialog
    // pour pouvoir afficher le montant déjà réglé dans le dialog
    Decimal dejaRegle = Decimal.zero;
    if (d.id != null) {
      try {
        dejaRegle = await factureVM.calculateHistoriqueReglements(d.id!, "");
      } catch (e) {
        debugPrint("Erreur calcul historique: $e");
      }
    }

    // Garantir que l'acompte théorique du devis est toujours inclus
    // même si le paiement correspondant n'a pas encore été saisi
    if (d.acompteMontant > dejaRegle) {
      dejaRegle = d.acompteMontant;
    }

    if (!mounted) return;

    final result = await showDialog<TransformationResultWrapper>(
      context: context,
      builder: (ctx) => TransformationDialog(
        totalTTC: d.totalTtc,
        acomptePercentage: d.acomptePercentage,
        acompteMontant: d.acompteMontant,
        dejaRegle: dejaRegle,
      ),
    );

    if (result == null || !mounted) return;

    final vm = Provider.of<DevisViewModel>(context, listen: false);

    try {
      // Pour la situation : charger les avancements depuis le suivi de rentabilité
      Map<String, Decimal>? avancementsChiffrage;
      if (result.type.name == 'situation' && d.id != null) {
        try {
          final chiffrageRepo = ChiffrageRepository();
          final chiffrages = await chiffrageRepo.getByDevisId(d.id!);
          if (chiffrages.isNotEmpty) {
            avancementsChiffrage =
                CalculationsUtils.calculateAllLignesAvancement(
              lignesDevis: d.lignes,
              tousChiffrages: chiffrages,
            );
          }
        } catch (e) {
          debugPrint("Erreur chargement avancements chiffrage: $e");
        }
        if (!mounted) return;
      }

      final draftFacture = vm.prepareFacture(
          d,
          result.type.name, // 'standard', 'acompte', ...
          result.value,
          result.isPercent,
          dejaRegle: dejaRegle,
          avancementsChiffrage: avancementsChiffrage);

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

    // Filtrage
    final brouillons = vm.devis.where((d) => d.statut == 'brouillon').toList();
    final envoyes = vm.devis.where((d) => d.statut == 'envoye').toList();
    final signes = vm.devis.where((d) => d.statut == 'signe').toList();
    final refusesExpires = vm.devis
        .where((d) => d.statut == 'refuse' || d.statut == 'expire')
        .toList();
    final annules = vm.devis.where((d) => d.statut == 'annule').toList();

    return BaseScreen(
      menuIndex: 1,
      title: "Mes Devis",
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/app/ajout_devis'),
        child: const Icon(Icons.add),
      ),
      appBarBottom: TabBar(
        controller: _tabController,
        isScrollable: true, // Scrollable si petit écran
        tabs: const [
          Tab(text: "Tous"),
          Tab(text: "Brouillons"),
          Tab(text: "Envoyés"),
          Tab(text: "Signés"),
          Tab(text: "Refusés / Expirés"),
          Tab(text: "Annulés"),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildList(vm.devis, clientVM),
          _buildList(brouillons, clientVM),
          _buildList(envoyes, clientVM),
          _buildList(signes, clientVM),
          _buildList(refusesExpires, clientVM),
          _buildList(annules, clientVM),
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
        if (d.statut == 'refuse') statusColor = Colors.red;
        if (d.statut == 'expire') statusColor = Colors.orange;
        if (d.statut == 'annule') statusColor = Colors.black45;

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
                        if (d.isAvenant) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.purple.shade300),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.edit_note,
                                  size: 12, color: Colors.purple.shade700),
                              const SizedBox(width: 3),
                              Text("Avenant",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ],
                        if (d.chiffrage.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.analytics,
                                  size: 12, color: Colors.green.shade700),
                              const SizedBox(width: 3),
                              Text("Analysé",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ],
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
                onSelected: (val) async {
                  if (val == 'pdf') _genererPDF(d);
                  if (val == 'email') _envoyerDevisParEmail(d);
                  if (val == 'bl') _genererPDF(d, docType: "BON DE LIVRAISON");
                  if (val == 'bc') _genererPDF(d, docType: "BON DE COMMANDE");
                  if (val == 'facture') _showTransformationDialog(d);
                  if (val == 'refuser') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Refuser ce devis ?"),
                        content: const Text(
                            "Le devis sera marqué comme refusé par le client."),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Non")),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Oui, refuser")),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await Provider.of<DevisViewModel>(context, listen: false)
                          .refuserDevis(d.id!);
                    }
                  } else if (val == 'annuler') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Annuler ce devis ?"),
                        content:
                            const Text("Le devis sera définitivement annulé."),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Non")),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Oui, annuler")),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await Provider.of<DevisViewModel>(context, listen: false)
                          .annulerDevis(d.id!);
                    }
                  }
                  if (val == 'avenant') {
                    if (context.mounted) {
                      final vm =
                          Provider.of<DevisViewModel>(context, listen: false);
                      final avenant = await vm.creerAvenant(d.id!);
                      if (avenant != null && context.mounted) {
                        context.go('/app/ajout_devis/${avenant.id}',
                            extra: avenant);
                      }
                    }
                  }
                  if (val == 'duplicate') {
                    if (context.mounted) {
                      final vm =
                          Provider.of<DevisViewModel>(context, listen: false);
                      final dup = vm.duplicateDevis(d);
                      context.go('/app/ajout_devis', extra: dup);
                    }
                  }
                  if (val == 'archive') {
                    if (context.mounted) {
                      Provider.of<DevisViewModel>(context, listen: false)
                          .toggleArchive(d, true);
                    }
                  }
                  if (val == 'delete') {
                    if (context.mounted) {
                      Provider.of<DevisViewModel>(context, listen: false)
                          .deleteDevis(d.id!);
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  // PDF toujours disponible
                  const PopupMenuItem(value: 'pdf', child: Text("Voir PDF")),

                  // Email : brouillon et envoyé
                  if (d.statut == 'brouillon' || d.statut == 'envoye')
                    const PopupMenuItem(
                        value: 'email',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.email_rounded, size: 20),
                          title: Text("Envoyer par email"),
                        )),

                  // Brouillon : dupliquer, supprimer
                  if (d.statut == 'brouillon') ...[
                    const PopupMenuItem(
                        value: 'duplicate', child: Text("Dupliquer")),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text("Supprimer",
                            style: TextStyle(color: Colors.red))),
                  ],

                  // Envoyé : refuser, annuler, créer facture
                  if (d.statut == 'envoye') ...[
                    const PopupMenuItem(
                        value: 'refuser', child: Text("Marquer Refusé")),
                    const PopupMenuItem(
                        value: 'annuler',
                        child: Text("Annuler",
                            style: TextStyle(color: Colors.red))),
                    const PopupMenuItem(
                        value: 'facture', child: Text("Créer Facture")),
                  ],

                  // Signé : BL, BC, facture, avenant
                  if (d.statut == 'signe') ...[
                    const PopupMenuItem(
                        value: 'facture', child: Text("Créer Facture")),
                    const PopupMenuItem(
                        value: 'bl', child: Text("Bon de Livraison")),
                    const PopupMenuItem(
                        value: 'bc', child: Text("Bon de Commande")),
                    const PopupMenuItem(
                        value: 'avenant', child: Text("Créer un Avenant")),
                  ],

                  // Refusé / Expiré : annuler
                  if (d.statut == 'refuse' || d.statut == 'expire')
                    const PopupMenuItem(
                        value: 'annuler',
                        child: Text("Annuler",
                            style: TextStyle(color: Colors.red))),

                  // Archiver (tous sauf brouillon)
                  if (d.statut != 'brouillon')
                    const PopupMenuItem(
                        value: 'archive', child: Text("Archiver")),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
