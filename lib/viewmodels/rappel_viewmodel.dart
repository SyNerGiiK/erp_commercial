import '../core/base_viewmodel.dart';
import '../models/rappel_model.dart';
import '../repositories/rappel_repository.dart';

/// ViewModel pour la gestion des rappels et échéances
class RappelViewModel extends BaseViewModel {
  final IRappelRepository _repository;

  RappelViewModel({IRappelRepository? repository})
      : _repository = repository ?? RappelRepository();

  List<Rappel> _items = [];
  List<Rappel> get items => _items;

  /// Rappels non complétés
  List<Rappel> get actifs => _items.where((r) => !r.estComplete).toList();

  /// Rappels en retard
  List<Rappel> get enRetard => _items.where((r) => r.estEnRetard).toList();

  /// Rappels proches (< 7 jours)
  List<Rappel> get proches => _items.where((r) => r.estProche).toList();

  /// Rappels complétés
  List<Rappel> get completes => _items.where((r) => r.estComplete).toList();

  /// Nombre total de rappels urgents (en retard + proches)
  int get nbUrgents => enRetard.length + proches.length;

  /// Rappels par type
  Map<TypeRappel, List<Rappel>> get parType {
    final map = <TypeRappel, List<Rappel>>{};
    for (final r in actifs) {
      map.putIfAbsent(r.typeRappel, () => []).add(r);
    }
    return map;
  }

  Future<void> loadAll() async {
    await executeOperation(() async {
      _items = await _repository.getAll();
    });
  }

  Future<void> loadActifs() async {
    await executeOperation(() async {
      _items = await _repository.getActifs();
    });
  }

  Future<bool> create(Rappel rappel) async {
    return executeOperation(() async {
      await _repository.create(rappel);
      _items = await _repository.getAll();
    });
  }

  Future<bool> update(Rappel rappel) async {
    return executeOperation(() async {
      await _repository.update(rappel);
      final idx = _items.indexWhere((e) => e.id == rappel.id);
      if (idx >= 0) _items[idx] = rappel;
    });
  }

  Future<bool> delete(String id) async {
    return executeOperation(() async {
      await _repository.delete(id);
      _items.removeWhere((e) => e.id == id);
    });
  }

  Future<bool> completer(String id) async {
    return executeOperation(() async {
      await _repository.completer(id);
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) _items[idx] = _items[idx].copyWith(estComplete: true);
    });
  }

  Future<bool> decompleter(String id) async {
    return executeOperation(() async {
      await _repository.decompleter(id);
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) _items[idx] = _items[idx].copyWith(estComplete: false);
    });
  }

  /// Génère les rappels URSSAF automatiques pour l'année courante
  /// Fréquence mensuelle = le dernier jour du mois (M+1)
  /// Fréquence trimestrielle = fin janvier, avril, juillet, octobre
  static List<Rappel> genererRappelsUrssaf({
    required int annee,
    bool trimestriel = false,
  }) {
    final rappels = <Rappel>[];

    if (trimestriel) {
      // Dates limites trimestrielles URSSAF
      final dates = [
        DateTime(annee, 2, 1), // T4 année précédente → 31 janv
        DateTime(annee, 5, 1), // T1 → 30 avril
        DateTime(annee, 8, 1), // T2 → 31 juillet
        DateTime(annee, 11, 1), // T3 → 31 octobre
      ];
      final labels = [
        'T4 ${annee - 1}',
        'T1 $annee',
        'T2 $annee',
        'T3 $annee',
      ];

      for (int i = 0; i < dates.length; i++) {
        // Dernier jour du mois précédent
        final echeance = dates[i].subtract(const Duration(days: 1));
        rappels.add(Rappel(
          titre: 'Déclaration URSSAF ${labels[i]}',
          description:
              'Déclarer le CA du trimestre ${labels[i]} avant le ${echeance.day}/${echeance.month}/$annee',
          typeRappel: TypeRappel.urssaf,
          dateEcheance: echeance,
          estRecurrent: true,
          frequenceRecurrence: 'trimestrielle',
          priorite: PrioriteRappel.haute,
        ));
      }
    } else {
      // Mensuel : déclaration avant la fin du mois M+1
      for (int mois = 1; mois <= 12; mois++) {
        final echeance = DateTime(annee, mois + 1, 0); // dernier jour du mois
        rappels.add(Rappel(
          titre: 'Déclaration URSSAF — ${_nomMois(mois)} $annee',
          description: 'Déclarer le CA de ${_nomMois(mois)} $annee',
          typeRappel: TypeRappel.urssaf,
          dateEcheance: echeance,
          estRecurrent: true,
          frequenceRecurrence: 'mensuelle',
          priorite: PrioriteRappel.haute,
        ));
      }
    }

    return rappels;
  }

  /// Génère le rappel CFE (15 décembre)
  static Rappel genererRappelCFE(int annee) {
    return Rappel(
      titre: 'Paiement CFE $annee',
      description:
          'Date limite de paiement de la Cotisation Foncière des Entreprises',
      typeRappel: TypeRappel.cfe,
      dateEcheance: DateTime(annee, 12, 15),
      estRecurrent: true,
      frequenceRecurrence: 'annuelle',
      priorite: PrioriteRappel.haute,
    );
  }

  /// Génère le rappel impôts (dates variables selon régime)
  static Rappel genererRappelImpots(int annee) {
    return Rappel(
      titre: 'Déclaration d\'impôts $annee',
      description:
          'N\'oubliez pas de déclarer vos revenus micro-entrepreneur (formulaire 2042-C-PRO)',
      typeRappel: TypeRappel.impots,
      dateEcheance: DateTime(annee, 6, 8), // date moyenne zone C
      estRecurrent: true,
      frequenceRecurrence: 'annuelle',
      priorite: PrioriteRappel.urgente,
    );
  }

  static String _nomMois(int mois) {
    const noms = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return noms[mois];
  }
}
