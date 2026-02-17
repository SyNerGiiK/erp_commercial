import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/custom_text_field.dart';

class DevisStep2Details extends StatelessWidget {
  final TextEditingController objetCtrl;
  final TextEditingController? notesCtrl;
  final TextEditingController? conditionsCtrl;
  final DateTime dateEmission;
  final DateTime dateValidite;
  final Function(DateTime, DateTime) onDatesChanged;

  const DevisStep2Details({
    super.key,
    required this.objetCtrl,
    this.notesCtrl,
    this.conditionsCtrl,
    required this.dateEmission,
    required this.dateValidite,
    required this.onDatesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          title: const Text("Informations Générales"),
          child: Column(
            children: [
              CustomTextField(
                label: "Objet du devis",
                controller: objetCtrl,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDialog<DateTime>(
                          context: context,
                          builder: (context) => DatePickerDialog(
                            initialDate: dateEmission,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          ),
                        );
                        if (d != null) {
                          onDatesChanged(d, dateValidite);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Date émission",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child:
                            Text(DateFormat('dd/MM/yyyy').format(dateEmission)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDialog<DateTime>(
                          context: context,
                          builder: (context) => DatePickerDialog(
                            initialDate: dateValidite,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          ),
                        );
                        if (d != null) {
                          onDatesChanged(dateEmission, d);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Validité (Echéance)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        child:
                            Text(DateFormat('dd/MM/yyyy').format(dateValidite)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (notesCtrl != null || conditionsCtrl != null) ...[
          const SizedBox(height: 16),
          AppCard(
            title: const Text("Notes & Conditions"),
            child: Column(
              children: [
                if (conditionsCtrl != null)
                  CustomTextField(
                    label: "Conditions de règlement",
                    controller: conditionsCtrl!,
                    maxLines: 2,
                  ),
                if (conditionsCtrl != null && notesCtrl != null)
                  const SizedBox(height: 10),
                if (notesCtrl != null)
                  CustomTextField(
                    label: "Notes publiques (visibles sur le PDF)",
                    controller: notesCtrl!,
                    maxLines: 3,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
