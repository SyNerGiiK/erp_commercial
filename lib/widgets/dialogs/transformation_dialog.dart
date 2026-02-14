import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../config/theme.dart';
import '../../utils/format_utils.dart';

enum TransformationType { standard, acompte, situation, solde }

class TransformationResult {
  final TransformationType type;
  final Decimal value; // Pourcentage ou Montant fixe pour l'acompte

  TransformationResult(this.type, {Decimal? value})
      : value = value ?? Decimal.zero;
}

class TransformationDialog extends StatefulWidget {
  final Decimal totalTTC; // Pour info

  const TransformationDialog({super.key, required this.totalTTC});

  @override
  State<TransformationDialog> createState() => _TransformationDialogState();
}

class _TransformationDialogState extends State<TransformationDialog> {
  TransformationType _selectedType = TransformationType.standard;
  final TextEditingController _valueCtrl = TextEditingController(text: "30");
  bool _isPercent = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Transformer en Facture"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Générer une facture :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildOption(
              TransformationType.standard,
              "Facture Standard",
              "Copie conforme du devis.",
              Icons.copy,
            ),
            _buildOption(
              TransformationType.acompte,
              "Facture d'Acompte",
              "Facturer un % du devis avant travaux.",
              Icons.savings,
            ),
            if (_selectedType == TransformationType.acompte)
              Padding(
                padding: const EdgeInsets.only(left: 40, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _valueCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: "Pourcentage (%)",
                              suffixText: "%",
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Montant calculé :",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                                Text(
                                  FormatUtils.currency(_calculateAmount()),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            _buildOption(
              TransformationType.situation,
              "Facture d'Avancement (Situation)",
              "Facturer un % d'avancement travaux.",
              Icons.timelapse,
            ),
            _buildOption(
              TransformationType.solde,
              "Facture de Solde",
              "Clôture du chantier (déduit les acomptes).",
              Icons.check_circle,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Créer Facture"),
        ),
      ],
    );
  }

  Widget _buildOption(
      TransformationType type, String title, String subtitle, IconData icon) {
    final bool isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : null,
          border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primary : null)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, size: 18, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Decimal _calculateAmount() {
    if (_selectedType != TransformationType.acompte) return Decimal.zero;
    final percent =
        Decimal.tryParse(_valueCtrl.text.replaceAll(',', '.')) ?? Decimal.zero;
    // Calcul sur le TTC global (car l'acompte est souvent perçu sur le total)
    // Mais pour la facture d'acompte (qui est une facture), on raisonne souvent en HT + TVA.
    // LE USer a dit "Montant de l'acompte".
    // Si on a le totalTTC du devis, on applique le % au TTC pour savoir combien le client paie.
    // MAIS la facture d'acompte générée sera en HT.
    // Ma méthode prepareFacture prend un %, calcule le HT.
    // Ici on affiche le montant TTC ou HT ?
    // Affichons simplement le % du TotalTTC pour info client.
    return ((widget.totalTTC * percent) / Decimal.fromInt(100)).toDecimal();
  }

  void _submit() {
    Decimal val = Decimal.zero;
    if (_selectedType == TransformationType.acompte) {
      val = Decimal.tryParse(_valueCtrl.text.replaceAll(',', '.')) ??
          Decimal.zero;
      // Toujours en pourcentage désormais
      _isPercent = true;
    }
    Navigator.pop(
        context, TransformationResultWrapper(_selectedType, val, _isPercent));
  }
}

class TransformationResultWrapper {
  final TransformationType type;
  final Decimal value;
  final bool isPercent;

  TransformationResultWrapper(this.type, this.value, this.isPercent);
}
