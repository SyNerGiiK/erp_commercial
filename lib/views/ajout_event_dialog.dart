import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/planning_model.dart';
import '../models/client_model.dart';
import '../viewmodels/client_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/client_selection_dialog.dart';

class AjoutEventDialog extends StatefulWidget {
  final PlanningEvent? eventToEdit;
  final DateTime? initialDate;

  const AjoutEventDialog({super.key, this.eventToEdit, this.initialDate});

  @override
  State<AjoutEventDialog> createState() => _AjoutEventDialogState();
}

class _AjoutEventDialogState extends State<AjoutEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreCtrl;
  late TextEditingController _descCtrl;

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  String _type = 'chantier';
  Client? _selectedClient;

  @override
  void initState() {
    super.initState();
    final e = widget.eventToEdit;

    _titreCtrl = TextEditingController(text: e?.titre ?? "");
    _descCtrl = TextEditingController(text: e?.description ?? "");
    _startDate = e?.dateDebut ?? widget.initialDate ?? DateTime.now();
    _startTime = TimeOfDay.fromDateTime(_startDate);
    _endDate = e?.dateFin ?? _startDate.add(const Duration(hours: 2));
    _endTime = TimeOfDay.fromDateTime(_endDate);
    _type = e?.type ?? 'chantier';
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    if (pickedDate == null) return;

    if (!mounted) return;

    final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate));
    if (pickedTime == null) return;

    setState(() {
      final fullDate = DateTime(pickedDate.year, pickedDate.month,
          pickedDate.day, pickedTime.hour, pickedTime.minute);
      if (isStart) {
        _startDate = fullDate;
        _startTime = pickedTime;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(hours: 2));
          _endTime = TimeOfDay.fromDateTime(_endDate);
        }
      } else {
        _endDate = fullDate;
        _endTime = pickedTime;
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final start = DateTime(_startDate.year, _startDate.month, _startDate.day,
          _startTime.hour, _startTime.minute);
      final end = DateTime(_endDate.year, _endDate.month, _endDate.day,
          _endTime.hour, _endTime.minute);

      if (end.isBefore(start)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("La fin ne peut pas être avant le début")));
        return;
      }

      final newEvent = PlanningEvent(
        id: widget.eventToEdit?.id,
        titre: _titreCtrl.text,
        description: _descCtrl.text,
        dateDebut: start,
        dateFin: end,
        type: _type,
        clientId: _selectedClient?.id ?? widget.eventToEdit?.clientId,
        isManual: true,
      );

      Navigator.pop(context, newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.eventToEdit == null
          ? "Ajouter un événement"
          : "Modifier l'événement"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: "Titre",
                controller: _titreCtrl,
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                // RÈGLE : InitialValue + Key
                key: ValueKey(_type),
                initialValue: _type,
                decoration: const InputDecoration(labelText: "Type"),
                items: const [
                  DropdownMenuItem(value: 'chantier', child: Text("Chantier")),
                  DropdownMenuItem(value: 'rdv', child: Text("Rendez-vous")),
                  DropdownMenuItem(value: 'autre', child: Text("Autre")),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.primary),
                  title: Text(_selectedClient?.nomComplet ??
                      (widget.eventToEdit?.clientId != null
                          ? "Client #..."
                          : "Sélectionner un client (Optionnel)")),
                  trailing: const Icon(Icons.search),
                  onTap: () async {
                    final c = await showDialog<Client>(
                        context: context,
                        builder: (_) => const ClientSelectionDialog());
                    if (c != null && mounted) {
                      setState(() => _selectedClient = c);
                    }
                  },
                ),
              ),
              const Divider(height: 30),
              ListTile(
                title: const Text("Début"),
                trailing: Text(
                    "${DateFormat('dd/MM/yyyy').format(_startDate)} à ${_startTime.format(context)}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => _pickDateTime(true),
              ),
              ListTile(
                title: const Text("Fin"),
                trailing: Text(
                    "${DateFormat('dd/MM/yyyy').format(_endDate)} à ${_endTime.format(context)}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => _pickDateTime(false),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                  label: "Description", controller: _descCtrl, maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler")),
        ElevatedButton(onPressed: _submit, child: const Text("Enregistrer")),
      ],
    );
  }
}
