import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/theme.dart';
import '../config/supabase_config.dart';
import '../models/devis_model.dart';
import '../models/article_model.dart';
import '../models/client_model.dart';
import '../models/chiffrage_model.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../services/pdf_service.dart';

import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/client_selection_dialog.dart';
import '../widgets/article_selection_dialog.dart';
import '../widgets/ligne_editor.dart';
import '../utils/format_utils.dart';
import 'signature_view.dart';

class AjoutDevisView extends StatefulWidget {
  final String? id;
  final Devis? devisAModifier;

  const AjoutDevisView({super.key, this.id, this.devisAModifier});

  @override
  State<AjoutDevisView> createState() => _AjoutDevisViewState();
}

class _AjoutDevisViewState extends State<AjoutDevisView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _numeroCtrl;
  late TextEditingController _objetCtrl;
  late TextEditingController _notesCtrl;

  DateTime _dateEmission = DateTime.now();
  late DateTime _dateValidite;

  Client? _selectedClient;
  List<LigneDevis> _lignes = [];
  List<LigneChiffrage> _chiffrage = [];

  Decimal _remiseTaux = Decimal.zero;
  Decimal _acompteMontant = Decimal.zero;
  final bool _useAcomptePercent = false;

  String _statut = 'brouillon';

  @override
  void initState() {
    super.initState();
    _dateValidite = DateTime.now().add(const Duration(days: 30));
    _initData();
  }

  void _initData() {
    if (widget.devisAModifier != null) {
      final d = widget.devisAModifier!;
      _numeroCtrl = TextEditingController(text: d.numeroDevis);
      _objetCtrl = TextEditingController(text: d.objet);
      _notesCtrl = TextEditingController(text: d.notesPubliques ?? "");
      _dateEmission = d.dateEmission;
      _dateValidite = d.dateValidite;
      _lignes = List.from(d.lignes);
      _chiffrage = List.from(d.chiffrage);
      _remiseTaux = d.remiseTaux;
      _acompteMontant = d.acompteMontant;
      _statut = d.statut;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clientVM = Provider.of<ClientViewModel>(context, listen: false);
        try {
          _selectedClient =
              clientVM.clients.firstWhere((c) => c.id == d.clientId);
          setState(() {});
        } catch (_) {}
      });
    } else {
      _numeroCtrl = TextEditingController(text: "PROVISOIRE");
      _objetCtrl = TextEditingController();
      _notesCtrl = TextEditingController();
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

  // --- ACTIONS ---

  void _ajouterLigne(Article? article) {
    setState(() {
      _lignes.add(LigneDevis(
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

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Client requis")));
      return;
    }

    final vm = Provider.of<DevisViewModel>(context, listen: false);

    // GESTION NUMÉROTATION
    String numeroFinal = _numeroCtrl.text;
    if (widget.id == null || numeroFinal == "PROVISOIRE") {
      // Pour un devis, on peut laisser PROVISOIRE ou générer.
      // Ici on suppose que le repo gère si nécessaire, ou on laisse l'utilisateur valider plus tard.
      // Pour l'exemple simple, on laisse PROVISOIRE.
    }

    final devis = Devis(
      id: widget.id,
      userId: widget.devisAModifier?.userId,
      numeroDevis: numeroFinal,
      objet: _objetCtrl.text,
      clientId: _selectedClient!.id!,
      dateEmission: _dateEmission,
      dateValidite: _dateValidite,
      statut: _statut,
      totalHt: _totalHT,
      remiseTaux: _remiseTaux,
      acompteMontant: _acompteMontant,
      lignes: _lignes,
      chiffrage: _chiffrage,
      notesPubliques: _notesCtrl.text,
    );

    bool success;
    if (widget.id != null) {
      success = await vm.updateDevis(devis);
    } else {
      success = await vm.addDevis(devis);
    }

    if (success && mounted) {
      context.pop();
    }
  }

  Future<void> _pickDate(bool isEmission) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEmission ? _dateEmission : _dateValidite,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        if (isEmission) {
          _dateEmission = picked;
          _dateValidite = picked.add(const Duration(days: 30));
        } else {
          _dateValidite = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      menuIndex: 1, // CORRECTION: Index Devis
      title: widget.id != null ? "Modifier Devis" : "Nouveau Devis",
      headerActions: [
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
                  _lignes[index] = LigneDevis(
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
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Total HT"),
              Text(FormatUtils.currency(_totalHT)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Remise (%)"),
              SizedBox(
                  width: 80,
                  child: TextFormField(
                      initialValue: _remiseTaux.toString(),
                      onChanged: (v) => setState(() =>
                          _remiseTaux = Decimal.tryParse(v) ?? Decimal.zero))),
              const Spacer(),
              Text("- ${FormatUtils.currency(_totalRemise)}",
                  style: const TextStyle(color: Colors.red))
            ]),
            const Divider(),
            _rowTotal("NET COMMERCIAL", _netCommercial, isBig: true),
          ],
        ),
      ),
    );
  }

  Widget _rowTotal(String label, Decimal val, {bool isBig = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBig ? FontWeight.bold : FontWeight.normal,
                fontSize: isBig ? 18 : 14)),
        Text(FormatUtils.currency(val),
            style: TextStyle(
                fontWeight: isBig ? FontWeight.bold : FontWeight.normal,
                fontSize: isBig ? 18 : 14,
                color: AppTheme.primary)),
      ],
    );
  }
}
