import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../config/theme.dart';
import '../viewmodels/planning_viewmodel.dart';
import '../viewmodels/facture_viewmodel.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../models/planning_model.dart';
import '../widgets/base_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/ajout_event_dialog.dart';
import '../utils/format_utils.dart';

class PlanningView extends StatefulWidget {
  const PlanningView({super.key});

  @override
  State<PlanningView> createState() => _PlanningViewState();
}

class _PlanningViewState extends State<PlanningView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final factureVM = Provider.of<FactureViewModel>(context, listen: false);
    final devisVM = Provider.of<DevisViewModel>(context, listen: false);
    final planningVM = Provider.of<PlanningViewModel>(context, listen: false);
    final clientVM = Provider.of<ClientViewModel>(context, listen: false);

    // Chargement parallèle
    Future.wait([
      factureVM.fetchFactures(),
      devisVM.fetchDevis(),
      clientVM.fetchClients(),
    ]).then((_) {
      planningVM.fetchEvents(factureVM.factures, devisVM.devis);
    });
  }

  void _ajouterEvent() {
    showDialog(
      context: context,
      builder: (ctx) => AjoutEventDialog(initialDate: _selectedDay),
    ).then((val) {
      if (val == true) {
        _loadData(); // Rafraîchir
      }
    });
  }

  void _editerEvent(PlanningEvent event) {
    if (!event.isManual) return; // Seuls les événements manuels sont éditables
    showDialog(
      context: context,
      builder: (ctx) => AjoutEventDialog(eventToEdit: event),
    ).then((val) {
      if (val == true) _loadData();
    });
  }

  Future<void> _supprimerEvent(PlanningEvent event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: const Text("Cet événement sera effacé du planning."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Annuler")),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text("Oui")),
        ],
      ),
    );

    if (confirm == true && mounted && event.id != null) {
      await Provider.of<PlanningViewModel>(context, listen: false)
          .deleteEvent(event.id!);
      if (!mounted) return;
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PlanningViewModel>(context);
    final events = vm.events;

    // Récupérer les événements du jour sélectionné
    final eventsForSelectedDay = events.where((e) {
      return isSameDay(e.dateDebut, _selectedDay);
    }).toList();

    return BaseScreen(
      menuIndex: 4, // CORRECTION: Index Planning
      title: "Planning",
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterEvent,
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Chantiers", vm.showChantiers, AppTheme.accent,
                    () => vm.toggleFilter('chantier')),
                const SizedBox(width: 8),
                _buildFilterChip("RDV", vm.showRdv, Colors.purple,
                    () => vm.toggleFilter('rdv')),
                const SizedBox(width: 8),
                _buildFilterChip("Factures", vm.showFactures, Colors.orange,
                    () => vm.toggleFilter('facture')),
                const SizedBox(width: 8),
                _buildFilterChip("Devis", vm.showDevis, Colors.blue,
                    () => vm.toggleFilter('devis')),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Calendrier
          Card(
            margin: EdgeInsets.zero,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) {
                return events
                    .where((e) => isSameDay(e.dateDebut, day))
                    .toList();
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

          // Liste des événements du jour
          Expanded(
            child: eventsForSelectedDay.isEmpty
                ? const Center(
                    child: Text("Rien de prévu ce jour-là.",
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: eventsForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final event = eventsForSelectedDay[index];
                      Color dotColor = Colors.grey;
                      IconData icon = Icons.event;

                      if (event.type == 'chantier') {
                        dotColor = AppTheme.accent;
                        icon = Icons.handyman;
                      } else if (event.type == 'rdv') {
                        dotColor = Colors.purple;
                        icon = Icons.person;
                      } else if (event.type == 'facture_echeance') {
                        dotColor = Colors.orange;
                        icon = Icons.euro;
                      } else if (event.type == 'devis_fin') {
                        dotColor = Colors.blue;
                        icon = Icons.description;
                      }

                      return AppCard(
                        onTap: () => _editerEvent(event),
                        leading: CircleAvatar(
                          backgroundColor: dotColor.withValues(alpha: 0.1),
                          child: Icon(icon, color: dotColor, size: 20),
                        ),
                        title: Text(event.titre,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${DateFormat('HH:mm').format(event.dateDebut)} - ${DateFormat('HH:mm').format(event.dateFin)}"),
                            if (event.description != null &&
                                event.description!.isNotEmpty)
                              Text(event.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic)),
                          ],
                        ),
                        trailing: event.isManual
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.grey),
                                onPressed: () => _supprimerEvent(event))
                            : const Icon(Icons.chevron_right,
                                color: Colors.grey),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isActive, Color color, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
      checkmarkColor: Colors.white,
      selectedColor: color,
      labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isActive ? Colors.transparent : Colors.grey.shade300)),
    );
  }
}
