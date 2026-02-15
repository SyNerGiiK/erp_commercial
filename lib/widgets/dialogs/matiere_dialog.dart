import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/chiffrage_model.dart';
import '../custom_text_field.dart';

/// Dialog pour ajouter ou modifier une ligne de matière première
class MatiereDialog extends StatefulWidget {
  final LigneChiffrage? ligneExistante;

  const MatiereDialog({super.key, this.ligneExistante});

  @override
  State<MatiereDialog> createState() => _MatiereDialogState();
}

class _MatiereDialogState extends State<MatiereDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _designationCtrl;
  late TextEditingController _quantiteCtrl;
  late TextEditingController _prixAchatCtrl;
  String _unite = 'u';

  final List<String> _unites = ['u', 'm', 'm²', 'm³', 'kg', 'L', 'h'];

  @override
  void initState() {
    super.initState();
    _designationCtrl =
        TextEditingController(text: widget.ligneExistante?.designation ?? '');
    _quantiteCtrl = TextEditingController(
        text: widget.ligneExistante?.quantite.toString() ?? '1');
    _prixAchatCtrl = TextEditingController(
        text: widget.ligneExistante?.prixAchatUnitaire.toString() ?? '');
    _unite = widget.ligneExistante?.unite ?? 'u';
  }

  @override
  void dispose() {
    _designationCtrl.dispose();
    _quantiteCtrl.dispose();
    _prixAchatCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final ligne = LigneChiffrage(
        id: widget.ligneExistante?.id,
        designation: _designationCtrl.text,
        quantite: Decimal.parse(_quantiteCtrl.text.replaceAll(',', '.')),
        unite: _unite,
        prixAchatUnitaire:
            Decimal.parse(_prixAchatCtrl.text.replaceAll(',', '.')),
      );
      Navigator.pop(context, ligne);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ligneExistante == null
          ? "Ajouter matière première"
          : "Modifier matière première"),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: "Désignation",
                controller: _designationCtrl,
                validator: (v) =>
                    v?.isEmpty ?? true ? "Désignation requise" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      label: "Quantité",
                      controller: _quantiteCtrl,
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unite,
                      decoration: const InputDecoration(
                        labelText: "Unité",
                        border: OutlineInputBorder(),
                      ),
                      items: _unites
                          .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => _unite = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              // Affichage du total calculé
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total :",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      _calculerTotal(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text("Valider", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  String _calculerTotal() {
    try {
      final qte = Decimal.parse(_quantiteCtrl.text.replaceAll(',', '.'));
      final prix = Decimal.parse(_prixAchatCtrl.text.replaceAll(',', '.'));
      final total = qte * prix;
      return "${total.toStringAsFixed(2)} €";
    } catch (e) {
      return "-- €";
    }
  }
}
