import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart'; // Import indispensable pour PdfPageFormat

import '../config/theme.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/article_model.dart';
import '../models/client_model.dart';
import '../models/chiffrage_model.dart';
import '../models/paiement_model.dart';

import '../viewmodels/facture_viewmodel.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';

import '../services/pdf_service.dart';

import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/client_selection_dialog.dart';
import '../widgets/article_selection_dialog.dart';
import '../widgets/ligne_editor.dart';
import '../utils/format_utils.dart';

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

  DateTime _dateEmission = DateTime.now();
  late DateTime _dateEcheance;

  Client? _selectedClient;
  List<LigneFacture> _lignes = [];
  List<LigneChiffrage> _chiffrage = [];
  List<Paiement> _paiements = [];

  Decimal _remiseTaux = Decimal.zero;
  final bool _useAcomptePercent = false;

  String _statut = 'brouillon';
  String _statutJuridique = 'brouillon';

  @override
  void initState() {
    super.initState();
    _dateEcheance = DateTime.now().add(const Duration(days: 30));
    _initData();
  }

  void _initData() {
    // Si modification
    if (widget.factureAModifier != null) {
      final f = widget.factureAModifier!;
      _numeroCtrl = TextEditingController(text: f.numeroFacture);
      _objetCtrl = TextEditingController(text: f.objet);
      _notesCtrl = TextEditingController(text: f.notesPubliques ?? "");
      _dateEmission = f.dateEmission;
      // CORRECTION : Suppression du '?? ...' car f.dateEcheance est non-nullable
      _dateEcheance = f.dateEcheance;

      _lignes = List.from(f.lignes);
      _chiffrage = List.from(f.chiffrage);
      _paiements = List.from(f.paiements);
      _remiseTaux = f.remiseTaux;
      _statut = f.statut;
      _statutJuridique = f.statutJuridique;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clientVM = Provider.of<ClientViewModel>(context, listen: false);
        try {
          _selectedClient =
              clientVM.clients.firstWhere((c) => c.id == f.clientId);
          setState(() {});
        } catch (_) {}
      });
    } else {
      // Nouvelle facture
      _numeroCtrl = TextEditingController(text: "PROVISOIRE");
      _objetCtrl = TextEditingController();
      _notesCtrl = TextEditingController();

      // Si création depuis Devis
      if (widget.sourceDevisId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final devisVM = Provider.of<DevisViewModel>(context, listen: false);
          try {
            final sourceDevis =
                devisVM.devis.firstWhere((d) => d.id == widget.sourceDevisId);

            _objetCtrl.text = sourceDevis.objet;
            _remiseTaux = sourceDevis.remiseTaux;
            _notesCtrl.text = sourceDevis.notesPubliques ?? "";

            _lignes = sourceDevis.lignes
                .map((ld) => LigneFacture(
                    description: ld.description,
                    quantite: ld.quantite,
                    prixUnitaire: ld.prixUnitaire,
                    totalLigne: ld.totalLigne,
                    typeActivite: ld.typeActivite,
                    unite: ld.unite,
                    type: ld.type,
                    ordre: ld.ordre,
                    estGras: ld.estGras,
                    estItalique: ld.estItalique,
                    estSouligne: ld.estSouligne))
                .toList();

            _chiffrage = List.from(sourceDevis.chiffrage);

            if (sourceDevis.acompteMontant > Decimal.zero) {
              _paiements.add(Paiement(
                  factureId: '',
                  montant: sourceDevis.acompteMontant,
                  datePaiement: sourceDevis.dateSignature ?? DateTime.now(),
                  typePaiement: 'virement',
                  commentaire: 'Acompte Devis ${sourceDevis.numeroDevis}',
                  isAcompte: true));
            }

            final clientVM =
                Provider.of<ClientViewModel>(context, listen: false);
            _selectedClient = clientVM.clients
                .firstWhere((c) => c.id == sourceDevis.clientId);
            setState(() {});
          } catch (e) {
            debugPrint("Erreur import devis: $e");
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _objetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // --- CALCULS (FIX TYPES) ---

  Decimal get _totalHT =>
      _lignes.fold(Decimal.zero, (sum, l) => sum + l.totalLigne);

  Decimal get _totalRemise =>
      ((_totalHT * _remiseTaux) / Decimal.fromInt(100)).toDecimal();

  Decimal get _netCommercial => _totalHT - _totalRemise;

  Decimal get _totalRegle =>
      _paiements.fold(Decimal.zero, (sum, p) => sum + p.montant);

  Decimal get _resteAPayer => _netCommercial - _totalRegle;

  Decimal get _historiqueReglements => Decimal.zero;

  // --- ACTIONS ---

  void _ajouterLigne(Article? article) {
    setState(() {
      _lignes.add(LigneFacture(
        description: article?.designation ?? "",
        quantite: Decimal.fromInt(1),
        prixUnitaire: article?.prixUnitaire ?? Decimal.zero,
        totalLigne: article?.prixUnitaire ?? Decimal.zero,
        unite: article?.unite ?? 'u',
        typeActivite: article?.typeActivite ?? 'service',
        type: article != null ? 'article' : 'titre',
      ));
    });
  }

  Future<void> _genererPDF() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner un client")));
      return;
    }

    final facturePDF = Facture(
      id: widget.id,
      numeroFacture: _numeroCtrl.text,
      objet: _objetCtrl.text,
      clientId: _selectedClient!.id!,
      dateEmission: _dateEmission,
      dateEcheance: _dateEcheance,
      lignes: _lignes,
      paiements: _paiements,
      remiseTaux: _remiseTaux,
      notesPubliques: _notesCtrl.text,
      statut: _statut,
      statutJuridique: _statutJuridique,
      totalHt: _totalHT,
      acompteDejaRegle: Decimal.zero,
    );

    final entVM = Provider.of<EntrepriseViewModel>(context, listen: false);
    if (entVM.profil == null) await entVM.fetchProfil();

    if (!mounted) return;

    final pdfBytes = await PdfService.generateFacture(
        facturePDF, _selectedClient!, entVM.profil);

    if (!mounted) return;

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Facture_${_numeroCtrl.text}.pdf');
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Client requis")));
      return;
    }

    final vm = Provider.of<FactureViewModel>(context, listen: false);

    String numeroFinal = _numeroCtrl.text;
    if (widget.id == null || numeroFinal == "PROVISOIRE") {
      numeroFinal = await vm.generateNextNumero();
    }

    final facture = Facture(
      id: widget.id,
      userId: widget.factureAModifier?.userId,
      numeroFacture: numeroFinal,
      objet: _objetCtrl.text,
      clientId: _selectedClient!.id!,
      devisSourceId:
          widget.sourceDevisId ?? widget.factureAModifier?.devisSourceId,
      dateEmission: _dateEmission,
      dateEcheance: _dateEcheance,
      statut: _statut,
      statutJuridique: _statutJuridique,
      totalHt: _totalHT,
      remiseTaux: _remiseTaux,
      lignes: _lignes,
      paiements: _paiements,
      chiffrage: _chiffrage,
      notesPubliques: _notesCtrl.text,
      acompteDejaRegle: Decimal.zero,
    );

    bool success;
    if (widget.id != null) {
      success = await vm.updateFacture(facture);
    } else {
      success = await vm.createFacture(facture);
    }

    if (success && mounted) {
      context.pop();
    }
  }

  Future<void> _pickDate(bool isEmission) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEmission ? _dateEmission : _dateEcheance,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        if (isEmission) {
          _dateEmission = picked;
          _dateEcheance = picked.add(const Duration(days: 30));
        } else {
          _dateEcheance = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.id != null ? "Modifier Facture" : "Nouvelle Facture",
      menuIndex: 2,
      headerActions: [
        IconButton(icon: const Icon(Icons.print), onPressed: _genererPDF),
        IconButton(icon: const Icon(Icons.save), onPressed: _sauvegarder),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(),
              const Divider(height: 30),
              _buildLignesSection(),
              const Divider(height: 30),
              _buildTotauxSection(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Numéro",
                    controller: _numeroCtrl,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(true),
                    child: InputDecorator(
                      decoration:
                          const InputDecoration(labelText: "Date Émission"),
                      child:
                          Text(DateFormat('dd/MM/yyyy').format(_dateEmission)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: "Objet",
              controller: _objetCtrl,
              validator: (v) => v!.isEmpty ? "Requis" : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final c = await showDialog<Client>(
                    context: context,
                    builder: (_) => const ClientSelectionDialog());
                if (c != null) setState(() => _selectedClient = c);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Client"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedClient?.nomComplet ??
                        "Sélectionner un client..."),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLignesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("LIGNES",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Article"),
                  onPressed: () async {
                    final a = await showDialog<Article>(
                        context: context,
                        builder: (_) => const ArticleSelectionDialog());
                    if (a != null) _ajouterLigne(a);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.title),
                  label: const Text("Titre"),
                  onPressed: () => _ajouterLigne(null),
                ),
              ],
            )
          ],
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _lignes.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) newIndex -= 1;
              final item = _lignes.removeAt(oldIndex);
              _lignes.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final l = _lignes[index];
            return LigneEditor(
              key: ValueKey(l.uiKey),
              description: l.description,
              quantite: l.quantite,
              prixUnitaire: l.prixUnitaire,
              unite: l.unite,
              type: l.type,
              estGras: l.estGras,
              estItalique: l.estItalique,
              showHandle: true,
              onChanged:
                  (desc, qte, pu, unite, type, gras, italique, souligne) {
                setState(() {
                  _lignes[index] = LigneFacture(
                      id: l.id,
                      description: desc,
                      quantite: qte,
                      prixUnitaire: pu,
                      totalLigne: type == 'article' ? qte * pu : Decimal.zero,
                      unite: unite,
                      typeActivite: l.typeActivite,
                      type: type,
                      estGras: gras,
                      estItalique: italique,
                      estSouligne: souligne,
                      uiKey: l.uiKey);
                });
              },
              onDelete: () => setState(() => _lignes.removeAt(index)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTotauxSection() {
    return Card(
        color: AppTheme.primary.withValues(alpha: 0.05),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Total HT"),
                Text(FormatUtils.currency(_totalHT)),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Remise (%)"),
                SizedBox(
                    width: 80,
                    child: _useAcomptePercent
                        ? Text("$_remiseTaux%")
                        : TextFormField(
                            initialValue: _remiseTaux.toString(),
                            onChanged: (v) => setState(() => _remiseTaux =
                                Decimal.tryParse(v) ?? Decimal.zero))),
                const Spacer(),
                Text("- ${FormatUtils.currency(_totalRemise)}",
                    style: const TextStyle(color: Colors.red))
              ]),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("NET À PAYER",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(FormatUtils.currency(_netCommercial),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18))
              ]),
              if (_historiqueReglements > Decimal.zero)
                Row(children: [
                  const Text("Déjà réglé (Ant.) : "),
                  Text(FormatUtils.currency(_historiqueReglements))
                ]),
              Row(children: [
                const Text("Règlements reçus : "),
                Text(FormatUtils.currency(_totalRegle))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                const Text("Reste à payer : "),
                Text(FormatUtils.currency(_resteAPayer),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange))
              ])
            ])));
  }
}
