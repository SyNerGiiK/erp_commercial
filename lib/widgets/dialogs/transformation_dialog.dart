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
  final Decimal totalTTC;
  final Decimal? acomptePercentage;
  final Decimal? acompteMontant;
  final Decimal? dejaRegle;

  const TransformationDialog({
    super.key,
    required this.totalTTC,
    this.acomptePercentage,
    this.acompteMontant,
    this.dejaRegle,
  });

  @override
  State<TransformationDialog> createState() => _TransformationDialogState();
}

class _TransformationDialogState extends State<TransformationDialog> {
  TransformationType _selectedType = TransformationType.standard;
  late final TextEditingController _valueCtrl;
  bool _isPercent = true;

  @override
  void initState() {
    super.initState();
    // Utilise le taux d'acompte défini sur le devis comme valeur par défaut
    final defaultPercent = widget.acomptePercentage ?? Decimal.fromInt(30);
    _valueCtrl = TextEditingController(
      text: defaultPercent.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

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
              "Acompte de ${(widget.acomptePercentage ?? Decimal.fromInt(30)).toStringAsFixed(0)}% défini dans le devis.",
              Icons.savings,
            ),
            // Acompte : affichage en lecture seule du taux du devis
            if (_selectedType == TransformationType.acompte)
              Padding(
                padding: const EdgeInsets.only(left: 40, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Acompte de ${_valueCtrl.text}% — ${FormatUtils.currency(_calculateAmount())}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _buildOption(
              TransformationType.situation,
              "Facture d'Avancement (Situation)",
              "Avancement par ligne — ajustez les % dans l'éditeur.",
              Icons.timelapse,
            ),
            // Situation : info en lecture seule
            if (_selectedType == TransformationType.situation)
              Padding(
                padding: const EdgeInsets.only(left: 40, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((widget.dejaRegle ?? Decimal.zero) > Decimal.zero ||
                          (widget.acompteMontant ?? Decimal.zero) >
                              Decimal.zero)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.payments,
                                  size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Déjà réglé : ${FormatUtils.currency(_effectiveDejaRegle())}\n"
                                  "(sera déduit de la facture)",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Ajustez l'avancement de chaque ligne dans l'éditeur.\n"
                              "Les fournitures démarrent à 0% (couvertes par l'acompte).",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
    return ((widget.totalTTC * percent) / Decimal.fromInt(100)).toDecimal();
  }

  /// Calcule le montant effectivement déjà réglé (max entre acompte théorique et paiements réels)
  Decimal _effectiveDejaRegle() {
    final acompte = widget.acompteMontant ?? Decimal.zero;
    final paiements = widget.dejaRegle ?? Decimal.zero;
    return acompte > paiements ? acompte : paiements;
  }

  void _submit() {
    Decimal val = Decimal.zero;
    if (_selectedType == TransformationType.acompte) {
      val = Decimal.tryParse(_valueCtrl.text.replaceAll(',', '.')) ??
          Decimal.zero;
      _isPercent = true;
    }
    // Situation : pas de valeur globale, l'avancement est par ligne
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
