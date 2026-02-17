import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/planning_viewmodel.dart';
import 'package:erp_commercial/models/planning_model.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/devis_model.dart';
import '../mocks/repository_mocks.dart';

// Fake pour les types complexes
class FakePlanningEvent extends Fake implements PlanningEvent {}

void main() {
  late MockPlanningRepository mockRepository;
  late PlanningViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakePlanningEvent());
  });

  setUp(() {
    mockRepository = MockPlanningRepository();
    viewModel = PlanningViewModel(repository: mockRepository);
  });

  group('fetchEvents', () {
    test('devrait récupérer les événements manuels et les exposer', () async {
      // ARRANGE
      final manualEvents = <PlanningEvent>[
        PlanningEvent(
          id: 'event-1',
          userId: 'user-1',
          titre: 'Chantier Lyon',
          dateDebut: DateTime(2024, 3, 15),
          dateFin: DateTime(2024, 3, 20),
          type: 'chantier',
          isManual: true,
        ),
        PlanningEvent(
          id: 'event-2',
          userId: 'user-1',
          titre: 'RDV Client',
          dateDebut: DateTime(2024, 3, 10),
          dateFin: DateTime(2024, 3, 10),
          type: 'rdv',
          isManual: true,
        ),
      ];

      when(() => mockRepository.getManualEvents())
          .thenAnswer((_) async => manualEvents);

      // ACT
      await viewModel.fetchEvents([], []);

      // ASSERT
      expect(viewModel.events.length, 2);
      // Should be sorted by dateDebut
      expect(viewModel.events[0].titre, 'RDV Client'); // 10 mars
      expect(viewModel.events[1].titre, 'Chantier Lyon'); // 15 mars
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.getManualEvents()).called(1);
    });

    test('devrait agréger les échéances de factures (statut envoyee/partielle)',
        () async {
      // ARRANGE
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Prestation',
          clientId: 'c1',
          dateEmission: DateTime(2024, 3, 1),
          dateEcheance: DateTime(2024, 4, 1),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'envoyee', // Should be included
        ),
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-002',
          objet: 'Autre',
          clientId: 'c2',
          dateEmission: DateTime(2024, 3, 1),
          dateEcheance: DateTime(2024, 5, 1),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'brouillon', // Should NOT be included
        ),
        Facture(
          id: 'f3',
          userId: 'user-1',
          numeroFacture: 'FAC-003',
          objet: 'Partielle',
          clientId: 'c3',
          dateEmission: DateTime(2024, 3, 1),
          dateEcheance: DateTime(2024, 3, 15),
          totalHt: Decimal.parse('750'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'partielle', // Should be included
        ),
      ];

      when(() => mockRepository.getManualEvents()).thenAnswer((_) async => []);

      // ACT
      await viewModel.fetchEvents(factures, []);

      // ASSERT
      expect(viewModel.events.length, 2); // Only f1 and f3
      expect(viewModel.events[0].titre, 'Échéance Facture FAC-003');
      expect(viewModel.events[0].type, 'facture_echeance');
      expect(viewModel.events[1].titre, 'Échéance Facture FAC-001');
    });

    test('devrait agréger les dates de validité des devis (statut envoye)',
        () async {
      // ARRANGE
      final devis = <Devis>[
        Devis(
          id: 'd1',
          userId: 'user-1',
          numeroDevis: 'DEV-001',
          objet: 'Projet A',
          clientId: 'c1',
          dateEmission: DateTime(2024, 3, 1),
          dateValidite: DateTime(2024, 4, 1),
          totalHt: Decimal.parse('5000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'envoye', // Should be included
        ),
        Devis(
          id: 'd2',
          userId: 'user-1',
          numeroDevis: 'DEV-002',
          objet: 'Projet B',
          clientId: 'c2',
          dateEmission: DateTime(2024, 3, 1),
          dateValidite: DateTime(2024, 5, 1),
          totalHt: Decimal.parse('3000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'brouillon', // Should NOT be included
        ),
      ];

      when(() => mockRepository.getManualEvents()).thenAnswer((_) async => []);

      // ACT
      await viewModel.fetchEvents([], devis);

      // ASSERT
      expect(viewModel.events.length, 1); // Only d1
      expect(viewModel.events[0].titre, 'Exp. Devis DEV-001');
      expect(viewModel.events[0].type, 'devis_fin');
      expect(viewModel.events[0].dateDebut, DateTime(2024, 4, 1));
    });

    test('devrait agréger tous les types d\'événements et trier par dateDebut',
        () async {
      // ARRANGE
      final manualEvents = <PlanningEvent>[
        PlanningEvent(
          id: 'event-1',
          titre: 'Chantier',
          dateDebut: DateTime(2024, 3, 20),
          dateFin: DateTime(2024, 3, 25),
          type: 'chantier',
        ),
      ];

      final factures = <Facture>[
        Facture(
          id: 'f1',
          numeroFacture: 'FAC-001',
          objet: 'Prestation',
          clientId: 'c1',
          dateEmission: DateTime(2024, 3, 1),
          dateEcheance: DateTime(2024, 3, 10), // Le plus tôt
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'envoyee',
        ),
      ];

      final devis = <Devis>[
        Devis(
          id: 'd1',
          numeroDevis: 'DEV-001',
          objet: 'Projet',
          clientId: 'c1',
          dateEmission: DateTime(2024, 3, 1),
          dateValidite: DateTime(2024, 3, 15), // Au milieu
          totalHt: Decimal.parse('5000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'envoye',
        ),
      ];

      when(() => mockRepository.getManualEvents())
          .thenAnswer((_) async => manualEvents);

      // ACT
      await viewModel.fetchEvents(factures, devis);

      // ASSERT
      expect(viewModel.events.length, 3);
      // Vérifier tri chronologique
      expect(viewModel.events[0].dateDebut, DateTime(2024, 3, 10)); // Facture
      expect(viewModel.events[1].dateDebut, DateTime(2024, 3, 15)); // Devis
      expect(viewModel.events[2].dateDebut, DateTime(2024, 3, 20)); // Chantier
    });

    test('devrait retourner une liste vide en cas d\'erreur', () async {
      // ARRANGE
      when(() => mockRepository.getManualEvents())
          .thenThrow(Exception('Network error'));

      // ACT
      await viewModel.fetchEvents([], []);

      // ASSERT
      expect(viewModel.events, isEmpty);
      expect(viewModel.isLoading, false);
    });
  });

  group('toggleFilter', () {
    test('devrait filtrer les chantiers quand le filtre est désactivé',
        () async {
      // ARRANGE
      final events = <PlanningEvent>[
        PlanningEvent(
          id: 'e1',
          titre: 'Chantier',
          dateDebut: DateTime(2024, 3, 10),
          dateFin: DateTime(2024, 3, 15),
          type: 'chantier',
        ),
        PlanningEvent(
          id: 'e2',
          titre: 'RDV',
          dateDebut: DateTime(2024, 3, 12),
          dateFin: DateTime(2024, 3, 12),
          type: 'rdv',
        ),
      ];

      when(() => mockRepository.getManualEvents())
          .thenAnswer((_) async => events);
      await viewModel.fetchEvents([], []);

      expect(viewModel.events.length, 2);

      // ACT
      viewModel.toggleFilter('chantier');

      // ASSERT
      expect(viewModel.showChantiers, false);
      expect(viewModel.events.length, 1); // Seulement RDV
      expect(viewModel.events[0].type, 'rdv');
    });

    test('devrait filtrer les RDV quand le filtre est désactivé', () async {
      // ARRANGE
      final events = <PlanningEvent>[
        PlanningEvent(
          id: 'e1',
          titre: 'RDV 1',
          dateDebut: DateTime(2024, 3, 10),
          dateFin: DateTime(2024, 3, 10),
          type: 'rdv',
        ),
        PlanningEvent(
          id: 'e2',
          titre: 'RDV 2',
          dateDebut: DateTime(2024, 3, 12),
          dateFin: DateTime(2024, 3, 12),
          type: 'rdv',
        ),
      ];

      when(() => mockRepository.getManualEvents())
          .thenAnswer((_) async => events);
      await viewModel.fetchEvents([], []);

      // ACT
      viewModel.toggleFilter('rdv');

      // ASSERT
      expect(viewModel.showRdv, false);
      expect(viewModel.events, isEmpty);
    });

    test('devrait filtrer les échéances factures', () async {
      // ARRANGE
      final factures = <Facture>[
        Facture(
          id: 'f1',
          numeroFacture: 'FAC-001',
          objet: 'Prestation',
          clientId: 'c1',
          dateEmission: DateTime(2024, 3, 1),
          dateEcheance: DateTime(2024, 4, 1),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'envoyee',
        ),
      ];

      when(() => mockRepository.getManualEvents()).thenAnswer((_) async => []);
      await viewModel.fetchEvents(factures, []);

      expect(viewModel.events.length, 1);

      // ACT
      viewModel.toggleFilter('facture');

      // ASSERT
      expect(viewModel.showFactures, false);
      expect(viewModel.events, isEmpty);
    });

    test('devrait filtrer les validités devis', () async {
      // ARRANGE
      final devis = <Devis>[
        Devis(
          id: 'd1',
          numeroDevis: 'DEV-001',
          objet: 'Projet',
          clientId: 'c1',
          dateEmission: DateTime(2024, 3, 1),
          dateValidite: DateTime(2024, 4, 1),
          totalHt: Decimal.parse('5000'),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'envoye',
        ),
      ];

      when(() => mockRepository.getManualEvents()).thenAnswer((_) async => []);
      await viewModel.fetchEvents([], devis);

      expect(viewModel.events.length, 1);

      // ACT
      viewModel.toggleFilter('devis');

      // ASSERT
      expect(viewModel.showDevis, false);
      expect(viewModel.events, isEmpty);
    });

    test('devrait réactiver un filtre quand on le toggle à nouveau', () async {
      // ARRANGE
      final events = <PlanningEvent>[
        PlanningEvent(
          id: 'e1',
          titre: 'Chantier',
          dateDebut: DateTime(2024, 3, 10),
          dateFin: DateTime(2024, 3, 15),
          type: 'chantier',
        ),
      ];

      when(() => mockRepository.getManualEvents())
          .thenAnswer((_) async => events);
      await viewModel.fetchEvents([], []);

      // ACT - Toggle OFF then ON
      viewModel.toggleFilter('chantier');
      expect(viewModel.events, isEmpty);

      viewModel.toggleFilter('chantier');

      // ASSERT
      expect(viewModel.showChantiers, true);
      expect(viewModel.events.length, 1);
    });
  });

  group('addEvent', () {
    test('devrait ajouter un événement et rafraîchir la liste', () async {
      // ARRANGE
      final newEvent = PlanningEvent(
        titre: 'Nouveau RDV',
        dateDebut: DateTime(2024, 3, 10),
        dateFin: DateTime(2024, 3, 10),
        type: 'rdv',
      );

      final updatedEvents = <PlanningEvent>[
        PlanningEvent(
          id: 'event-new',
          titre: 'Nouveau RDV',
          dateDebut: DateTime(2024, 3, 10),
          dateFin: DateTime(2024, 3, 10),
          type: 'rdv',
          isManual: true,
        ),
      ];

      when(() => mockRepository.addEvent(any())).thenAnswer((_) async {});
      when(() => mockRepository.getManualEvents())
          .thenAnswer((_) async => updatedEvents);

      // ACT
      final result = await viewModel.addEvent(newEvent);

      // ASSERT
      expect(result, true);
      verify(() => mockRepository.addEvent(any())).called(1);
      verify(() => mockRepository.getManualEvents()).called(1);
      expect(viewModel.events.length, 1);
      expect(viewModel.events[0].titre, 'Nouveau RDV');
    });

    test('devrait retourner false en cas d\'erreur', () async {
      // ARRANGE
      final newEvent = PlanningEvent(
        titre: 'RDV',
        dateDebut: DateTime(2024, 3, 10),
        dateFin: DateTime(2024, 3, 10),
      );

      when(() => mockRepository.addEvent(any()))
          .thenThrow(Exception('DB error'));

      // ACT
      final result = await viewModel.addEvent(newEvent);

      // ASSERT
      expect(result, false);
    });
  });

  group('updateEvent', () {
    test('devrait mettre à jour un événement existant et rafraîchir', () async {
      // ARRANGE
      final existingEvent = PlanningEvent(
        id: 'event-1',
        titre: 'RDV modifié',
        dateDebut: DateTime(2024, 3, 15),
        dateFin: DateTime(2024, 3, 15),
        type: 'rdv',
      );

      final updatedEvents = <PlanningEvent>[
        PlanningEvent(
          id: 'event-1',
          titre: 'RDV modifié',
          dateDebut: DateTime(2024, 3, 15),
          dateFin: DateTime(2024, 3, 15),
          type: 'rdv',
          isManual: true,
        ),
      ];

      when(() => mockRepository.updateEvent(any())).thenAnswer((_) async {});
      when(() => mockRepository.getManualEvents())
          .thenAnswer((_) async => updatedEvents);

      // ACT
      final result = await viewModel.updateEvent(existingEvent);

      // ASSERT
      expect(result, true);
      verify(() => mockRepository.updateEvent(existingEvent)).called(1);
      verify(() => mockRepository.getManualEvents()).called(1);
    });

    test('devrait retourner false si l\'event n\'a pas d\'id', () async {
      // ARRANGE
      final eventWithoutId = PlanningEvent(
        titre: 'RDV sans ID',
        dateDebut: DateTime(2024, 3, 10),
        dateFin: DateTime(2024, 3, 10),
      );

      // ACT
      final result = await viewModel.updateEvent(eventWithoutId);

      // ASSERT
      expect(result, false);
      verifyNever(() => mockRepository.updateEvent(any()));
    });

    test('devrait retourner false en cas d\'erreur', () async {
      // ARRANGE
      final event = PlanningEvent(
        id: 'event-1',
        titre: 'RDV',
        dateDebut: DateTime(2024, 3, 10),
        dateFin: DateTime(2024, 3, 10),
      );

      when(() => mockRepository.updateEvent(any()))
          .thenThrow(Exception('Update failed'));

      // ACT
      final result = await viewModel.updateEvent(event);

      // ASSERT
      expect(result, false);
    });
  });

  group('deleteEvent', () {
    test('devrait supprimer un événement et mettre à jour la liste', () async {
      // ARRANGE - First setup events
      final initialEvents = <PlanningEvent>[
        PlanningEvent(
          id: 'event-1',
          titre: 'A supprimer',
          dateDebut: DateTime(2024, 3, 10),
          dateFin: DateTime(2024, 3, 10),
          type: 'rdv',
          isManual: true,
        ),
        PlanningEvent(
          id: 'event-2',
          titre: 'A garder',
          dateDebut: DateTime(2024, 3, 12),
          dateFin: DateTime(2024, 3, 12),
          type: 'rdv',
          isManual: true,
        ),
      ];

      when(() => mockRepository.getManualEvents())
          .thenAnswer((_) async => initialEvents);
      await viewModel.fetchEvents([], []);
      expect(viewModel.events.length, 2);

      // Setup delete
      when(() => mockRepository.deleteEvent('event-1'))
          .thenAnswer((_) async {});

      // ACT
      final result = await viewModel.deleteEvent('event-1');

      // ASSERT
      expect(result, true);
      verify(() => mockRepository.deleteEvent('event-1')).called(1);
      // After delete, event-1 should be removed from _allEvents
      expect(viewModel.events.length, 1);
      expect(viewModel.events[0].titre, 'A garder');
    });

    test('devrait gérer les erreurs sans crash', () async {
      // ARRANGE
      const eventId = 'event-1';
      when(() => mockRepository.deleteEvent(eventId))
          .thenThrow(Exception('Delete failed'));

      // ACT & ASSERT - Should not throw
      final result = await viewModel.deleteEvent(eventId);
      expect(result, false);
      verify(() => mockRepository.deleteEvent(eventId)).called(1);
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après fetch', () async {
      // ARRANGE
      when(() => mockRepository.getManualEvents()).thenAnswer((_) async => []);

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.fetchEvents([], []);
      expect(viewModel.isLoading, false);
    });
  });

  group('Filter getters', () {
    test('devrait avoir tous les filtres activés par défaut', () {
      // ASSERT
      expect(viewModel.showChantiers, true);
      expect(viewModel.showRdv, true);
      expect(viewModel.showFactures, true);
      expect(viewModel.showDevis, true);
    });
  });
}
