import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../utils/format_utils.dart';

class DevisStep2Details extends StatelessWidget {
  final TextEditingController objetCtrl;
  final TextEditingController? notesCtrl;
  final TextEditingController? conditionsCtrl;
  final DateTime dateEmission;
  final DateTime dateValidite;
  final Function(DateTime, DateTime) onDatesChanged;

  /// Pourcentage d'acompte (ex: 30 = 30%)
  final Decimal? acomptePercentage;

  /// Montant de l'acompte calculé (pour affichage)
  final Decimal? acompteMontant;

  /// Callback quand l'utilisateur change le pourcentage
  final ValueChanged<Decimal>? onAcompteChanged;

  const DevisStep2Details({
    super.key,
    required this.objetCtrl,
    this.notesCtrl,
    this.conditionsCtrl,
    required this.dateEmission,
    required this.dateValidite,
    required this.onDatesChanged,
    this.acomptePercentage,
    this.acompteMontant,
    this.onAcompteChanged,
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

        // ACOMPTE
        if (onAcompteChanged != null) ...[
          const SizedBox(height: 16),
          AppCard(
            title: const Text("Acompte demandé"),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pourcentage de l'acompte :",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [0, 10, 20, 30, 40, 50].map((p) {
                    final isSelected = acomptePercentage == Decimal.fromInt(p);
                    return ChoiceChip(
                      label: Text("$p%"),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          onAcompteChanged!(Decimal.fromInt(p));
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Personnalisé : "),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        key: ValueKey(
                            'acompte_${acomptePercentage?.toString()}'),
                        initialValue: acomptePercentage?.toString() ?? '30',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          suffixText: "%",
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        onChanged: (v) {
                          final parsed = Decimal.tryParse(v);
                          if (parsed != null &&
                              parsed >= Decimal.zero &&
                              parsed <= Decimal.fromInt(100)) {
                            onAcompteChanged!(parsed);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (acompteMontant != null) ...[
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Montant acompte :"),
                      Text(FormatUtils.currency(acompteMontant!),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
