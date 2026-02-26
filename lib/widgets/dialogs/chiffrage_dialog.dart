// ignore_for_file: prefer_const_constructors

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/chiffrage_model.dart';
import '../../models/article_model.dart';
import '../../repositories/article_repository.dart';
import '../custom_text_field.dart';

/// Dialog enrichi pour ajouter/modifier un coût interne (matériel ou MO)
/// avec les champs Progress Billing : typeChiffrage, prixVenteInterne.
class ChiffrageDialog extends StatefulWidget {
  final String devisId;
  final String? ligneDevisId;
  final Decimal prixTotalLigne;
  final LigneChiffrage? ligneExistante;

  const ChiffrageDialog({
    super.key,
    required this.devisId,
    this.ligneDevisId,
    required this.prixTotalLigne,
    this.ligneExistante,
  });

  @override
  State<ChiffrageDialog> createState() => _ChiffrageDialogState();
}

class _ChiffrageDialogState extends State<ChiffrageDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _designationCtrl;
  late TextEditingController _quantiteCtrl;
  late TextEditingController _prixAchatCtrl;
  late TextEditingController _prixVenteInterneCtrl;
  String _unite = 'u';
  TypeChiffrage _typeChiffrage = TypeChiffrage.materiel;

  final List<String> _unites = ['u', 'm', 'm²', 'm³', 'kg', 'L', 'h'];

  @override
  void initState() {
    super.initState();
    final existing = widget.ligneExistante;
    _designationCtrl = TextEditingController(text: existing?.designation ?? '');
    _quantiteCtrl =
        TextEditingController(text: existing?.quantite.toString() ?? '1');
    _prixAchatCtrl = TextEditingController(
        text: existing?.prixAchatUnitaire.toString() ?? '');
    _prixVenteInterneCtrl = TextEditingController(
        text: existing?.prixVenteInterne != null &&
                existing!.prixVenteInterne != Decimal.zero
            ? existing.prixVenteInterne.toString()
            : '');
    _unite = existing?.unite ?? 'u';
    _typeChiffrage = existing?.typeChiffrage ?? TypeChiffrage.materiel;
  }

  @override
  void dispose() {
    _designationCtrl.dispose();
    _quantiteCtrl.dispose();
    _prixAchatCtrl.dispose();
    _prixVenteInterneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final prixVenteInterne = _prixVenteInterneCtrl.text.isNotEmpty
          ? Decimal.parse(_prixVenteInterneCtrl.text.replaceAll(',', '.'))
          : _calculerPrixVenteInterneAuto();

      final ligne = LigneChiffrage(
        id: widget.ligneExistante?.id,
        devisId: widget.devisId,
        linkedLigneDevisId: widget.ligneDevisId,
        designation: _designationCtrl.text,
        quantite: Decimal.parse(_quantiteCtrl.text.replaceAll(',', '.')),
        unite: _unite,
        prixAchatUnitaire:
            Decimal.parse(_prixAchatCtrl.text.replaceAll(',', '.')),
        typeChiffrage: _typeChiffrage,
        prixVenteInterne: prixVenteInterne,
      );
      Navigator.pop(context, ligne);
    }
  }

  /// Auto-calcul du prix de vente interne si non renseigné.
  /// Utilise le prix total de la ligne devis (prix de vente) comme base.
  Decimal _calculerPrixVenteInterneAuto() {
    // Fallback : valeur de vente de la ligne devis (pas le coût d'achat)
    return widget.prixTotalLigne;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ligneExistante != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.add_circle,
            color: AppTheme.primary,
            size: 22,
          ),
          SizedBox(width: 8),
          Text(isEditing ? "Modifier le coût" : "Ajouter un coût interne"),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Type de chiffrage ===
                const Text("Type de coût",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: TypeChiffrage.values.map((type) {
                    final isSelected = _typeChiffrage == type;
                    final isMat = type == TypeChiffrage.materiel;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: isMat ? 4 : 0, left: isMat ? 0 : 4),
                        child: InkWell(
                          onTap: () => setState(() => _typeChiffrage = type),
                          borderRadius: AppTheme.borderRadiusSmall,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isMat
                                      ? Colors.orange.withValues(alpha: 0.15)
                                      : Colors.blue.withValues(alpha: 0.15))
                                  : Colors.grey.shade50,
                              borderRadius: AppTheme.borderRadiusSmall,
                              border: Border.all(
                                color: isSelected
                                    ? (isMat
                                        ? Colors.orange.shade700
                                        : Colors.blue.shade700)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isMat ? Icons.inventory_2 : Icons.engineering,
                                  size: 18,
                                  color: isSelected
                                      ? (isMat
                                          ? Colors.orange.shade700
                                          : Colors.blue.shade700)
                                      : Colors.grey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? (isMat
                                            ? Colors.orange.shade700
                                            : Colors.blue.shade700)
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // === Désignation + bibliothèque ===
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "Désignation",
                        controller: _designationCtrl,
                        validator: (v) =>
                            v?.isEmpty ?? true ? "Désignation requise" : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.library_books),
                      tooltip: "Bibliothèque d'articles",
                      onPressed: _ouvrirBibliotheque,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // === Quantité + Unité ===
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: "Quantité",
                        controller: _quantiteCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Requis";
                          if (Decimal.tryParse(v.replaceAll(',', '.')) ==
                              null) {
                            return "Invalide";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_unite),
                        initialValue: _unite,
                        decoration: const InputDecoration(
                          labelText: "Unité",
                          border: OutlineInputBorder(),
                        ),
                        items: _unites
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setState(() => _unite = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // === Prix d'achat ===
                CustomTextField(
                  label: "Prix d'achat unitaire (€)",
                  controller: _prixAchatCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Requis";
                    if (Decimal.tryParse(v.replaceAll(',', '.')) == null) {
                      return "Invalide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // === Prix de vente interne (pour calcul d'avancement) ===
                CustomTextField(
                  label: "Valeur imputation (€)",
                  controller: _prixVenteInterneCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: "Vide = valeur ligne devis",
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      if (Decimal.tryParse(v.replaceAll(',', '.')) == null) {
                        return "Invalide";
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // === Résumé total ===
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySoft,
                    borderRadius: AppTheme.borderRadiusSmall,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total achat :", style: TextStyle(fontSize: 13)),
                          Text(_calculerTotalAchat(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Budget ligne devis :",
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.textLight)),
                          Text(
                            "${widget.prixTotalLigne.toDouble().toStringAsFixed(2)} €",
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Annuler"),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: Icon(isEditing ? Icons.save : Icons.add, size: 18),
          label: Text(isEditing ? "Enregistrer" : "Ajouter"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _calculerTotalAchat() {
    try {
      final qte = Decimal.parse(_quantiteCtrl.text.replaceAll(',', '.'));
      final prix = Decimal.parse(_prixAchatCtrl.text.replaceAll(',', '.'));
      return "${(qte * prix).toDouble().toStringAsFixed(2)} €";
    } catch (_) {
      return "-- €";
    }
  }

  Future<void> _ouvrirBibliotheque() async {
    try {
      final repo = ArticleRepository();
      final articles = await repo.getArticles();

      if (!mounted) return;

      final Article? selected = await showDialog<Article>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Sélectionner un article"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: articles.isEmpty
                ? const Center(
                    child: Text("Aucun article dans la bibliothèque"))
                : ListView.separated(
                    itemCount: articles.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final art = articles[i];
                      return ListTile(
                        title: Text(art.designation),
                        subtitle: Text(
                            "${art.prixAchat.toDouble().toStringAsFixed(2)}€ / ${art.unite}"),
                        onTap: () => Navigator.pop(ctx, art),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Fermer"),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (selected != null) {
        setState(() {
          _designationCtrl.text = selected.designation;
          _prixAchatCtrl.text =
              selected.prixAchat.toDouble().toStringAsFixed(2);
          if (_unites.contains(selected.unite)) {
            _unite = selected.unite;
          } else {
            _unite = 'u';
          }
        });
      }
    } catch (e) {
      debugPrint("Erreur biblio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement articles: $e")),
        );
      }
    }
  }
}
