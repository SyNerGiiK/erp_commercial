import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/paiement_model.dart';
import '../custom_text_field.dart';

class PaiementDialog extends StatefulWidget {
  final bool isAcompteDefault;
  const PaiementDialog({super.key, this.isAcompteDefault = false});

  @override
  State<PaiementDialog> createState() => _PaiementDialogState();
}

class _PaiementDialogState extends State<PaiementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montantCtrl = TextEditingController();
  final _commentaireCtrl = TextEditingController();
  DateTime _datePaiement = DateTime.now();
  String _typePaiement = 'virement';
  late bool _isAcompte;

  final List<String> _types = ['virement', 'cheque', 'especes', 'cb', 'autre'];

  @override
  void initState() {
    super.initState();
    _isAcompte = widget.isAcompteDefault;
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _commentaireCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final montant =
          Decimal.tryParse(_montantCtrl.text.replaceAll(',', '.')) ??
              Decimal.zero;

      final paiement = Paiement(
        factureId: '', // Sera défini par le parent
        montant: montant,
        datePaiement: _datePaiement,
        typePaiement: _typePaiement,
        commentaire: _commentaireCtrl.text,
        isAcompte: _isAcompte,
      );

      Navigator.pop(context, paiement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un règlement"),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _datePaiement,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (!mounted) return;
                  if (d != null) setState(() => _datePaiement = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date du règlement",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_datePaiement)),
                ),
              ),
              const SizedBox(height: 16),

              // Montant
              CustomTextField(
                label: "Montant (€)",
                controller: _montantCtrl,
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

              // Type
              DropdownButtonFormField<String>(
                initialValue: _typePaiement,
                decoration: const InputDecoration(
                  labelText: "Mode de règlement",
                  border: OutlineInputBorder(),
                ),
                items: _types.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _typePaiement = v!),
              ),
              const SizedBox(height: 16),

              // Commentaire
              CustomTextField(
                label: "Note / Commentaire",
                controller: _commentaireCtrl,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
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
          child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
