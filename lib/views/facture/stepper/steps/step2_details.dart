import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/custom_text_field.dart';

class Step2Details extends StatelessWidget {
  final TextEditingController objetCtrl;
  final TextEditingController? notesCtrl; // Optional
  final DateTime dateEmission;
  final DateTime dateEcheance;
  final Function(DateTime emission, DateTime echeance) onDatesChanged;

  const Step2Details({
    super.key,
    required this.objetCtrl,
    this.notesCtrl,
    required this.dateEmission,
    required this.dateEcheance,
    required this.onDatesChanged,
  });

  Future<void> _pickDate(BuildContext context, bool isEmission) async {
    final initialDate = isEmission ? dateEmission : dateEcheance;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isEmission) {
        onDatesChanged(picked, dateEcheance);
      } else {
        onDatesChanged(dateEmission, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: objetCtrl,
          label: "Objet de la facture",
          hint: "Ex: Rénovation Cuisine M. Dupont",
          validator: (v) => v?.isEmpty == true ? "Requis" : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date d'émission",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(dateEmission)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date d'échéance",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event_busy),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(dateEcheance)),
                ),
              ),
            ),
          ],
        ),
        if (notesCtrl != null) ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: notesCtrl!,
            label: "Notes (publiques)",
            maxLines: 3,
            hint: "Affichées sur le PDF",
          ),
        ],
      ],
    );
  }
}
