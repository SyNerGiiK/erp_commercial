import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';

import '../models/depense_model.dart';
import '../viewmodels/depense_viewmodel.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';
import '../config/theme.dart';

class AjoutDepenseView extends StatefulWidget {
  final String? id; // INDISPENSABLE POUR LE ROUTEUR
  final Depense? depenseAModifier;

  const AjoutDepenseView({super.key, this.id, this.depenseAModifier});

  @override
  State<AjoutDepenseView> createState() => _AjoutDepenseViewState();
}

class _AjoutDepenseViewState extends State<AjoutDepenseView> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _fournisseurController = TextEditingController();
  DateTime _date = DateTime.now();
  String _categorie = 'materiaux';
  String? _selectedDevisId;
  bool _isLoading = true;

  final List<String> _categories = [
    'materiaux',
    'carburant',
    'outillage',
    'repas',
    'assurance',
    'bureau',
    'autre',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DevisViewModel>(context, listen: false).fetchDevis();
    });
    _loadData();
  }

  Future<void> _loadData() async {
    Depense? d = widget.depenseAModifier;

    // F5 Refresh : Si on a l'ID mais pas l'objet
    if (d == null && widget.id != null) {
      final vm = Provider.of<DepenseViewModel>(context, listen: false);
      if (vm.depenses.isEmpty) await vm.fetchDepenses();
      try {
        d = vm.depenses.firstWhere((e) => e.id == widget.id);
      } catch (_) {}
    }

    if (d != null) {
      _titreController.text = d.titre;
      _montantController.text = d.montant.toString();
      _fournisseurController.text = d.fournisseur ?? "";
      _date = d.date;
      _categorie = d.categorie;
      _selectedDevisId = d.chantierDevisId;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titreController.dispose();
    _montantController.dispose();
    _fournisseurController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _sauvegarder() async {
    if (_titreController.text.isEmpty || _montantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Titre et Montant requis")));
      return;
    }

    final montant =
        Decimal.tryParse(_montantController.text.replaceAll(',', '.')) ??
            Decimal.zero;

    final newDepense = Depense(
      id: widget.id ?? widget.depenseAModifier?.id,
      userId: widget.depenseAModifier?.userId,
      titre: _titreController.text,
      montant: montant,
      date: _date,
      categorie: _categorie,
      fournisseur: _fournisseurController.text,
      chantierDevisId: _selectedDevisId,
    );

    setState(() => _isLoading = true); // Indicateur de chargement

    final vm = Provider.of<DepenseViewModel>(context, listen: false);
    bool success;
    try {
      if (newDepense.id == null) {
        success = await vm.addDepense(newDepense);
      } else {
        success = await vm.updateDepense(newDepense);
      }
    } catch (e) {
      success = false;
    }

    if (mounted) {
      setState(() => _isLoading = false); // Fin du chargement

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Dépense enregistrée avec succès")));

        // Petite pause pour laisser le temps à l'utilisateur de voir que ça a marché
        // et éviter l'effet "freeze" ressenti si la navigation est trop brutale pendant un rebuild
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) context.go('/app/depenses');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Erreur lors de l'enregistrement de la dépense. Vérifiez les logs.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final devisVM = Provider.of<DevisViewModel>(context);

    return BaseScreen(
      title: "Saisir Dépense",
      menuIndex: 5,
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              label: "Intitulé (ex: Sacs ciment)",
              controller: _titreController,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Montant TTC",
                    controller: _montantController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    icon: Icons.euro,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.primary),
                          const SizedBox(width: 10),
                          Text(DateFormat('dd/MM/yyyy').format(_date)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            CustomTextField(
              label: "Fournisseur (ex: Point P)",
              controller: _fournisseurController,
              icon: Icons.store,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              key: ValueKey(_categorie),
              initialValue: _categorie,
              decoration: InputDecoration(
                  labelText: "Catégorie",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white),
              items: _categories
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                  .toList(),
              onChanged: (v) => setState(() => _categorie = v!),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedDevisId),
              initialValue: _selectedDevisId,
              decoration: InputDecoration(
                  labelText: "Rattacher à un chantier",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white),
              items: [
                const DropdownMenuItem(value: null, child: Text("Aucun")),
                ...devisVM.devis
                    .where((d) => ['accepte', 'facture'].contains(d.statut))
                    .map((d) => DropdownMenuItem(
                        value: d.id,
                        child: Text("${d.numeroDevis} - ${d.objet}"))),
              ],
              onChanged: (v) => setState(() => _selectedDevisId = v),
            ),
            const SizedBox(height: 30),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _sauvegarder, child: const Text("ENREGISTRER"))),
          ],
        ),
      ),
    );
  }
}
