import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../config/theme.dart';
import '../models/facture_model.dart';
import '../models/article_model.dart';
import '../models/client_model.dart';
import '../models/chiffrage_model.dart';
import '../models/paiement_model.dart';

import '../viewmodels/facture_viewmodel.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../config/supabase_config.dart';

import '../services/pdf_service.dart';

import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/client_selection_dialog.dart';
import '../widgets/article_selection_dialog.dart';
import '../widgets/ligne_editor.dart';
import '../widgets/dialogs/paiement_dialog.dart'; // NEW: Import Dialog Paiement
import '../widgets/dialogs/signature_dialog.dart'; // NEW: Import Dialog Signature
import 'dart:typed_data';
import '../utils/format_utils.dart';
import '../utils/calculations_utils.dart';

class AjoutFactureView extends StatefulWidget {
  final String? id;
  final Facture? factureAModifier;
  final String? sourceDevisId;

  const AjoutFactureView(
      {super.key, this.id, this.factureAModifier, this.sourceDevisId});

  @override
  State<AjoutFactureView> createState() => _AjoutFactureViewState();
}

class _AjoutFactureViewState extends State<AjoutFactureView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _numeroCtrl;
  late TextEditingController _objetCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _conditionsCtrl;

  Client? _selectedClient;

  DateTime _dateEmission = DateTime.now();
  DateTime _dateEcheance = DateTime.now().add(const Duration(days: 30));

  List<LigneFacture> _lignes = [];
  List<LigneChiffrage> _chiffrage = [];
  List<Paiement> _paiements = [];

  String? _signatureUrl;
  DateTime? _dateSignature;

  String _typeFacture = 'standard';

  Decimal _remiseTaux = Decimal.zero;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    // Cas 1 : Modification Facture existante
    if (widget.factureAModifier != null) {
      Facture f = widget.factureAModifier!;

      // Tentative de récupération fraîche
      if (widget.id != null) {
        final vm = Provider.of<FactureViewModel>(context, listen: false);
        try {
          final fresh =
              vm.factures.firstWhere((element) => element.id == widget.id);
          f = fresh;
        } catch (_) {}
      }

      _numeroCtrl = TextEditingController(text: f.numeroFacture);
      _objetCtrl = TextEditingController(text: f.objet);
      _typeFacture = f.type;
      _notesCtrl = TextEditingController(text: f.notesPubliques ?? "");
      _conditionsCtrl = TextEditingController(text: f.conditionsReglement);
      _dateEmission = f.dateEmission;
      _dateEcheance = f.dateEcheance;
      _lignes = List.from(f.lignes);
      _chiffrage = List.from(f.chiffrage);
      _paiements = List.from(f.paiements);

      _remiseTaux = f.remiseTaux;

      // Init Signature (Clean URL handled display-side)
      _signatureUrl = f.signatureUrl;
      if (_signatureUrl != null && !_signatureUrl!.contains('?')) {
        // Add timestamp for display only
        _signatureUrl =
            "$_signatureUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      }
      _dateSignature = f.dateSignature;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clientVM = Provider.of<ClientViewModel>(context, listen: false);
        try {
          final client = clientVM.clients.firstWhere((c) => c.id == f.clientId);
          setState(() => _selectedClient = client);
        } catch (_) {}
      });
    }
    // Cas 2 : Création depuis Devis
    else if (widget.sourceDevisId != null) {
      final devisVM = Provider.of<DevisViewModel>(context, listen: false);
      try {
        final devis =
            devisVM.devis.firstWhere((d) => d.id == widget.sourceDevisId);
        _typeFacture = 'standard';
        _numeroCtrl = TextEditingController(text: "Brouillon");
        _objetCtrl =
            TextEditingController(text: "Facture pour ${devis.numeroDevis}");
        _notesCtrl = TextEditingController(text: devis.notesPubliques ?? "");
        _conditionsCtrl =
            TextEditingController(text: devis.conditionsReglement);
        _dateEmission = DateTime.now();
        _dateEcheance = DateTime.now().add(const Duration(days: 30));

        _lignes = devis.lignes
            .map((ld) => LigneFacture(
                description: ld.description,
                quantite: ld.quantite,
                prixUnitaire: ld.prixUnitaire,
                totalLigne: ld.totalLigne,
                unite: ld.unite,
                typeActivite: ld.typeActivite,
                type: ld.type,
                ordre: ld.ordre,
                estGras: ld.estGras,
                estItalique: ld.estItalique,
                estSouligne: ld.estSouligne))
            .toList();

        _chiffrage = List.from(devis.chiffrage);

        _remiseTaux = devis.remiseTaux;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final clientVM = Provider.of<ClientViewModel>(context, listen: false);
          try {
            final client =
                clientVM.clients.firstWhere((c) => c.id == devis.clientId);
            setState(() => _selectedClient = client);
          } catch (_) {}
        });
      } catch (e) {
        _numeroCtrl = TextEditingController(text: "Erreur Devis");
        _objetCtrl = TextEditingController();
        _notesCtrl = TextEditingController();
        _conditionsCtrl = TextEditingController();
      }
    }
    // Cas 3 : Nouvelle Facture Vierge
    else {
      _numeroCtrl = TextEditingController(text: "Brouillon");
      _objetCtrl = TextEditingController();
      _notesCtrl = TextEditingController();
      _conditionsCtrl = TextEditingController(text: "Paiement à réception");
      _typeFacture = 'standard';
    }
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _objetCtrl.dispose();
    _notesCtrl.dispose();
    _conditionsCtrl.dispose();
    super.dispose();
  }

  // --- CALCULS ---

  Decimal get _totalHT =>
      _lignes.fold(Decimal.zero, (sum, l) => sum + l.totalLigne);

  Decimal get _totalRemise {
    return ((_totalHT * _remiseTaux) / Decimal.fromInt(100)).toDecimal();
  }

  Decimal get _netCommercial => _totalHT - _totalRemise;

  Decimal get _totalRegle =>
      _paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);

  Decimal get _resteAPayer {
    // Logique simplifiée : Net Commercial - Paiements reçus
    return _netCommercial - _totalRegle;
  }

  // --- ACTIONS ---

  Future<void> _selectionnerClient() async {
    final client = await showDialog<Client>(
        context: context, builder: (_) => const ClientSelectionDialog());

    if (!mounted) return;

    if (client != null) {
      setState(() => _selectedClient = client);
    }
  }

  void _ajouterLigne() {
    setState(() {
      _lignes.add(LigneFacture(
        description: "",
        quantite: Decimal.one,
        prixUnitaire: Decimal.zero,
        totalLigne: Decimal.zero,
      ));
    });
  }

  void _ajouterLigneSpeciale(String type) {
    setState(() {
      _lignes.add(LigneFacture(
        description: "",
        quantite: Decimal.zero,
        prixUnitaire: Decimal.zero,
        totalLigne: Decimal.zero,
        type: type,
      ));
    });
  }

  // NEW: GESTION PAIEMENTS
  Future<void> _ajouterPaiement() async {
    final isAcompteInvoice = _typeFacture == 'acompte';
    final nouveauPaiement = await showDialog<Paiement>(
      context: context,
      builder: (_) => PaiementDialog(isAcompteDefault: isAcompteInvoice),
    );

    if (nouveauPaiement != null) {
      setState(() {
        _paiements.add(nouveauPaiement);
      });
    }
  }

  void _supprimerPaiement(int index) {
    setState(() {
      _paiements.removeAt(index);
    });
  }

  Future<void> _signerClient() async {
    if (widget.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Veuillez d'abord enregistrer la facture pour pouvoir la signer.")));
      return;
    }

    final Uint8List? signatureBytes = await showDialog(
      context: context,
      builder: (_) => const SignatureDialog(),
    );

    if (signatureBytes == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<FactureViewModel>(context, listen: false);

    // Upload via VM (qui update aussi le repository)
    // Note: Le VM update la facture dans la liste, mais ici on a un état local.
    // Il faut recharger l'URL ou l'attendre.
    // Ma méthode VM uploadSignature update la facture et refetch, donc c'est bon.
    // Mais on doit récupérer l'URL pour l'affichage local si on ne refetch pas tout le widget.
    // Le VM ne retourne pas l'URL pour l'instant, il retourne bool via _executeOperation ? Non, il retourne Future<bool>.
    // Je vais assumer que ça marche et recharger ou juste afficher un message.
    // Mieux: Le repo retourne l'URL, le VM l'utilise.
    // Je vais modifier le VM pour qu'il retourne l'URL au lieu de bool ? Non, je reste sur bool.
    // Je vais just fetchFactures et comme c'est un stateful widget qui init dans initState,
    // il ne se mettra pas à jour tout seul sauf si je relis le VM dans build ou si je force init.
    // Simplification: Je vais tricher et set _signatureUrl localement avec un timestamp pour forcer le refresh image si je l'avais
    // MAIS je n'ai pas l'URL ici facilement sans modifier le VM.
    // Je vais appeler upload et si succès, je set un state pour dire "Signé" (même si l'image met du temps).

    final success = await vm.uploadSignature(widget.id!, signatureBytes);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Pour l'affichage immédiat, on peut reconstruire l'URL théorique ou attendre re-init.
      // Le plus simple : Afficher un succès et peut-être recharger la vue (context.go).
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature enregistrée !")));

      // On recharge la page pour voir la signature
      // context.pushReplacement('/app/ajout_facture/${widget.id}', extra: vm.factures.firstWhere((f) => f.id == widget.id));
      // Ou plus simple, on met à jour l'état local si possible.
      // Je vais laisser l'utilisateur voir "Signé" via un switch UI ou rechargement.
      // Mieux:
      setState(() {
        // Je force un refresh visuel en supposant que l'URL est celle standard
        final userId = SupabaseConfig.userId;
        // On construit une URL théorique, mais idéalement on devrait récupérer celle du serveur si différente
        // Pour l'instant on fait comme AjoutDevis : on fetch pas, on force l'affichage
        // Mais attention : Si on save, il faut que l'URL soit clean.
        // On va tricher : on ne set PAS _signatureUrl ici car on ne veut pas l'afficher tant qu'on a pas rechargé ?
        // Non, on veut voir la signature.
        _signatureUrl =
            "${SupabaseConfig.client.storage.from('documents').getPublicUrl('$userId/factures/${widget.id}/signature.png')}?t=${DateTime.now().millisecondsSinceEpoch}";
        _dateSignature = DateTime.now();
      });

      // Petit hack pour recharger la facture depuis le serveur pour être sûr d'avoir les bonnes infos
      // le VM a déjà fait fetchFactures() ? Oui dans uploadSignature.
      // Donc on peut essayer de refresh depuis le VM
      try {
        final updated = vm.factures.firstWhere((f) => f.id == widget.id);
        setState(() {
          if (updated.signatureUrl != null) {
            _signatureUrl =
                "${updated.signatureUrl}?t=${DateTime.now().millisecondsSinceEpoch}";
          }
          _dateSignature = updated.dateSignature;
        });
      } catch (e) {
        // Ignorer si la facture n'est pas trouvée ou mis à jour
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la signature")));
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<FactureViewModel>(context, listen: false);

    final factureToSave = Facture(
      id: widget.id,
      userId: SupabaseConfig.userId,
      numeroFacture: _numeroCtrl.text,
      objet: _objetCtrl.text,
      clientId: _selectedClient!.id!,
      devisSourceId:
          widget.sourceDevisId ?? widget.factureAModifier?.devisSourceId,
      dateEmission: _dateEmission,
      dateEcheance: _dateEcheance,
      statut: widget.factureAModifier?.statut ?? 'brouillon',
      statutJuridique: widget.factureAModifier?.statutJuridique ?? 'brouillon',
      type: _typeFacture,
      totalHt: _totalHT,
      remiseTaux: _remiseTaux,
      // On initialise à zéro : ce champ n'est plus utilisé dans la nouvelle logique
      acompteDejaRegle: Decimal.zero,
      conditionsReglement: _conditionsCtrl.text,
      notesPubliques: _notesCtrl.text,
      tvaIntra: widget.factureAModifier?.tvaIntra ?? _selectedClient?.tvaIntra,
      lignes: _lignes,
      paiements: _paiements,
      chiffrage: _chiffrage,
      estArchive: widget.factureAModifier?.estArchive ?? false,
      signatureUrl: _signatureUrl?.split('?').first,
      dateSignature: _dateSignature,
    );

    bool success;
    if (widget.id == null) {
      success = await vm.addFacture(factureToSave);
      // Facture créée + paiements sauvegardés viaRepo
    } else {
      success = await vm.updateFacture(factureToSave);
      // Facture update ignore paiements -> On gère le delta ici
      if (success) {
        try {
          final oldPaiements = widget.factureAModifier?.paiements ?? [];

          // 1. Ajouter les nouveaux (id est null)
          for (var p in _paiements) {
            if (p.id == null) {
              // On associe l'ID facture
              await vm.addPaiement(p.copyWith(factureId: widget.id));
            }
          }

          // 2. Supprimer les absents (ceux qui étaient dans old mais plus dans new)
          // On compare via ID
          for (var oldP in oldPaiements) {
            final stillExists = _paiements.any((newP) => newP.id == oldP.id);
            if (!stillExists && oldP.id != null) {
              await vm.deletePaiement(oldP.id!, widget.id);
            }
          }
        } catch (e) {
          // Erreur non critique : La synchronisation des paiements a échoué partiellement,
          // mais la facture principale est sauvegardée. On ne bloque pas l'utilisateur.
          // developer.log("Erreur sync paiements", error: e);
        }
      }
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      context.go('/app/factures');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Facture enregistrée !")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erreur enregistrement")));
    }
  }

  Future<void> _finaliser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Valider la facture ?"),
        content:
            const Text("Un numéro officiel sera généré. Action irréversible."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Valider")),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    final vm = Provider.of<FactureViewModel>(context, listen: false);

    if (widget.factureAModifier != null) {
      await vm.finaliserFacture(widget.factureAModifier!);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    context.pop();
  }

  Future<void> _genererPDF() async {
    if (widget.factureAModifier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Veuillez d'abord enregistrer la facture.")));
      return;
    }

    final entrepriseVM =
        Provider.of<EntrepriseViewModel>(context, listen: false);
    final clientVM = Provider.of<ClientViewModel>(context, listen: false);

    if (entrepriseVM.profil == null) {
      await entrepriseVM.fetchProfil();
    }

    try {
      final client = clientVM.clients
          .firstWhere((c) => c.id == widget.factureAModifier!.clientId);

      final pdfBytes = await PdfService.generateFacture(
          widget.factureAModifier!, client, entrepriseVM.profil);

      if (!mounted) return;

      await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: "Facture_${widget.factureAModifier!.numeroFacture}.pdf");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur génération PDF : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: widget.id == null
            ? "Nouvelle Facture"
            : "Facture ${_numeroCtrl.text}",
        menuIndex: 2,
        useFullWidth: true,
        headerActions: [
          if (widget.factureAModifier != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: "Voir PDF",
              onPressed: _genererPDF,
            )
        ],
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // EN-TÊTE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    label: "Objet de la facture",
                                    controller: _objetCtrl,
                                    validator: (v) =>
                                        v!.isEmpty ? "Requis" : null,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final d = await showDatePicker(
                                                context: context,
                                                initialDate: _dateEmission,
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2030));
                                            if (d != null && mounted) {
                                              setState(() => _dateEmission = d);
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                                labelText: "Date émission",
                                                border: OutlineInputBorder(),
                                                filled: true,
                                                fillColor: Colors.white),
                                            child: Text(DateFormat('dd/MM/yyyy')
                                                .format(_dateEmission)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final d = await showDatePicker(
                                                context: context,
                                                initialDate: _dateEcheance,
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2030));
                                            if (d != null && mounted) {
                                              setState(() => _dateEcheance = d);
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                                labelText: "Échéance",
                                                border: OutlineInputBorder(),
                                                filled: true,
                                                fillColor: Colors.white),
                                            child: Text(DateFormat('dd/MM/yyyy')
                                                .format(_dateEcheance)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: AppCard(
                              onTap: _selectionnerClient,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("CLIENT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  if (_selectedClient != null) ...[
                                    Text(_selectedClient!.nomComplet,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text(_selectedClient!.ville),
                                  ] else
                                    const Row(
                                      children: [
                                        Icon(Icons.add_circle,
                                            color: AppTheme.primary),
                                        SizedBox(width: 8),
                                        Text("Sélectionner...",
                                            style: TextStyle(
                                                color: AppTheme.primary)),
                                      ],
                                    )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // LIGNES FACTURE
                      const Text("LIGNES DE LA FACTURE",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary)),
                      const SizedBox(height: 10),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _lignes.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _lignes.removeAt(oldIndex);
                            _lignes.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final ligne = _lignes[index];
                          final isSituation = _typeFacture == 'situation';

                          return Card(
                            key: ValueKey(ligne.uiKey),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: LigneEditor(
                              description: ligne.description,
                              quantite: ligne.quantite,
                              prixUnitaire: ligne.prixUnitaire,
                              unite: ligne.unite,
                              type: ligne.type,
                              estGras: ligne.estGras,
                              estItalique: ligne.estItalique,
                              estSouligne: ligne.estSouligne,
                              avancement: ligne.avancement,
                              isSituation: isSituation,
                              showHandle: true,
                              onChanged: (desc, qte, pu, unite, type, gras,
                                  ital, soul, av) {
                                setState(() {
                                  Decimal total;
                                  if (isSituation) {
                                    total =
                                        ((qte * pu * av) / Decimal.fromInt(100))
                                            .toDecimal();
                                  } else {
                                    total =
                                        CalculationsUtils.calculateTotalLigne(
                                            qte, pu);
                                  }

                                  _lignes[index] = ligne.copyWith(
                                    description: desc,
                                    quantite: qte,
                                    prixUnitaire: pu,
                                    totalLigne: total,
                                    unite: unite,
                                    type: type,
                                    estGras: gras,
                                    estItalique: ital,
                                    estSouligne: soul,
                                    avancement: av,
                                  );
                                });
                              },
                              onDelete: () {
                                setState(() {
                                  _lignes.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _ajouterLigne,
                            icon: const Icon(Icons.add),
                            label: const Text("Article"),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _ajouterLigneSpeciale('titre'),
                            icon: const Icon(Icons.title),
                            label: const Text("Titre"),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _ajouterLigneSpeciale('sous-titre'),
                            icon: const Icon(Icons.text_fields),
                            label: const Text("Sous-titre"),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _ajouterLigneSpeciale('texte'),
                            icon: const Icon(Icons.comment),
                            label: const Text("Note"),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _ajouterLigneSpeciale('saut_page'),
                            icon: const Icon(Icons.feed),
                            label: const Text("Saut Page"),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // SECTION TOTAUX
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total HT"),
                                  Text(FormatUtils.currency(_totalHT)),
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Remise (%)"),
                                  SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                          initialValue: _remiseTaux.toString(),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          onChanged: (v) => setState(() =>
                                              _remiseTaux =
                                                  Decimal.tryParse(v) ??
                                                      Decimal.zero))),
                                  Text(
                                      "- ${FormatUtils.currency(_totalRemise)}",
                                      style: const TextStyle(color: Colors.red))
                                ]),
                            const Divider(),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("NET À PAYER",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(FormatUtils.currency(_netCommercial),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))
                                ]),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // NEW: SECTION PAIEMENTS / RÈGLEMENTS
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text("RÈGLEMENTS / PAIEMENTS REÇUS",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textDark)),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: _ajouterPaiement,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text("Ajouter"),
                                )
                              ],
                            ),
                            const Divider(),
                            if (_paiements.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Aucun règlement enregistré",
                                    style: TextStyle(color: Colors.grey)),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _paiements.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final p = _paiements[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                        "${FormatUtils.currency(p.montant)} (${p.typePaiement})"),
                                    subtitle: Text(
                                        "${DateFormat('dd/MM/yyyy').format(p.datePaiement)} - ${p.commentaire}"),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      onPressed: () =>
                                          _supprimerPaiement(index),
                                    ),
                                  );
                                },
                              ),
                            const Divider(),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total Règlements : "),
                                  Text("- ${FormatUtils.currency(_totalRegle)}")
                                ]),
                            const SizedBox(height: 10),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text("RESTE À PAYER : ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(FormatUtils.currency(_resteAPayer),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: _resteAPayer > Decimal.zero
                                              ? Colors.orange
                                              : Colors.green))
                                ])
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // NEW: SECTION SIGNATURE CLIENT
                      AppCard(
                        title: const Text("SIGNATURE CLIENT"),
                        child: Column(
                          children: [
                            if (_signatureUrl != null)
                              Column(
                                children: [
                                  Container(
                                    height: 100,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.network(_signatureUrl!,
                                        fit: BoxFit.contain),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      "Signé le ${DateFormat('dd/MM/yyyy HH:mm').format(_dateSignature ?? DateTime.now())}",
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  const Text("Aucune signature client",
                                      style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: _signerClient,
                                    icon: const Icon(Icons.draw),
                                    label: const Text("Faire signer le client"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      // BOUTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.factureAModifier?.statut == 'brouillon')
                            OutlinedButton(
                              onPressed: _finaliser,
                              child: const Text("VALIDER FACTURE"),
                            ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _sauvegarder,
                            child: const Text("ENREGISTRER"),
                          )
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ));
  }
}
