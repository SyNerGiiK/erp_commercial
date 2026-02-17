import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/depense_viewmodel.dart';
import 'package:erp_commercial/models/depense_model.dart';
import '../mocks/repository_mocks.dart';

// Fake pour les types complexes
class FakeDepense extends Fake implements Depense {}

void main() {
  late MockDepenseRepository mockRepository;
  late DepenseViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeDepense());
  });

  setUp(() {
    mockRepository = MockDepenseRepository();
    viewModel = DepenseViewModel(repository: mockRepository);
  });

  group('fetchDepenses', () {
    test('devrait récupérer et exposer la liste des dépenses', () async {
      // ARRANGE
      final testDepenses = <Depense>[
        Depense(
          id: 'dep-1',
          userId: 'user-1',
          titre: 'Fournitures bureau',
          montant: Decimal.parse('150'),
          date: DateTime(2024, 1, 15),
          categorie: 'fournitures',
        ),
        Depense(
          id: 'dep-2',
          userId: 'user-1',
          titre: 'Transport',
          montant: Decimal.parse('50'),
          date: DateTime(2024, 1, 20),
          categorie: 'transport',
        ),
      ];

      when(() => mockRepository.getDepenses())
          .thenAnswer((_) async => testDepenses);

      // ACT
      await viewModel.fetchDepenses();

      // ASSERT
      expect(viewModel.depenses.length, 2);
      expect(viewModel.depenses[0].titre, 'Fournitures bureau');
      expect(viewModel.depenses[1].titre, 'Transport');
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.getDepenses()).called(1);
    });

    test('devrait gérer les erreurs sans crash', () async {
      // ARRANGE
      when(() => mockRepository.getDepenses())
          .thenThrow(Exception('Erreur réseau'));

      // ACT
      await viewModel.fetchDepenses();

      // ASSERT
      expect(viewModel.depenses, isEmpty);
      expect(viewModel.isLoading, false);
    });
  });

  group('addDepense', () {
    test('devrait ajouter une dépense et rafraîchir la liste', () async {
      // ARRANGE
      final newDepense = Depense(
        userId: 'user-1',
        titre: 'Nouvelle dépense',
        montant: Decimal.parse('200'),
        date: DateTime.now(),
        categorie: 'autre',
      );

      final updatedDepenses = <Depense>[
        Depense(
          id: 'dep-3',
          userId: 'user-1',
          titre: 'Nouvelle dépense',
          montant: Decimal.parse('200'),
          date: DateTime.now(),
          categorie: 'autre',
        ),
      ];

      when(() => mockRepository.createDepense(any())).thenAnswer((_) async {});
      when(() => mockRepository.getDepenses())
          .thenAnswer((_) async => updatedDepenses);

      // ACT
      final success = await viewModel.addDepense(newDepense);

      // ASSERT
      expect(success, true);
      expect(viewModel.depenses.length, 1);
      verify(() => mockRepository.createDepense(newDepense)).called(1);
      verify(() => mockRepository.getDepenses()).called(1);
    });

    test('devrait retourner false en cas d\'erreur', () async {
      // ARRANGE
      final newDepense = Depense(
        userId: 'user-1',
        titre: 'Error',
        montant: Decimal.parse('100'),
        date: DateTime.now(),
        categorie: 'autre',
      );

      when(() => mockRepository.createDepense(any()))
          .thenThrow(Exception('Creation failed'));

      // ACT
      final success = await viewModel.addDepense(newDepense);

      // ASSERT
      expect(success, false);
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.createDepense(newDepense)).called(1);
      verifyNever(() => mockRepository.getDepenses());
    });
  });

  group('updateDepense', () {
    test('devrait mettre à jour une dépense et rafraîchir', () async {
      // ARRANGE
      final updatedDepense = Depense(
        id: 'dep-1',
        userId: 'user-1',
        titre: 'Dépense modifiée',
        montant: Decimal.parse('250'),
        date: DateTime.now(),
        categorie: 'fournitures',
      );

      final resultDepenses = <Depense>[updatedDepense];

      when(() => mockRepository.updateDepense(any())).thenAnswer((_) async {});
      when(() => mockRepository.getDepenses())
          .thenAnswer((_) async => resultDepenses);

      // ACT
      final success = await viewModel.updateDepense(updatedDepense);

      // ASSERT
      expect(success, true);
      verify(() => mockRepository.updateDepense(updatedDepense)).called(1);
      verify(() => mockRepository.getDepenses()).called(1);
    });
  });

  group('deleteDepense', () {
    test('devrait supprimer une dépense et rafraîchir', () async {
      // ARRANGE
      const depenseIdToDelete = 'dep-1';
      final remainingDepenses = <Depense>[
        Depense(
          id: 'dep-2',
          userId: 'user-1',
          titre: 'Remaining',
          montant: Decimal.parse('50'),
          date: DateTime.now(),
          categorie: 'transport',
        ),
      ];

      when(() => mockRepository.deleteDepense(depenseIdToDelete))
          .thenAnswer((_) async {});
      when(() => mockRepository.getDepenses())
          .thenAnswer((_) async => remainingDepenses);

      // ACT
      await viewModel.deleteDepense(depenseIdToDelete);

      // ASSERT
      expect(viewModel.depenses.length, 1);
      verify(() => mockRepository.deleteDepense(depenseIdToDelete)).called(1);
    });
  });

  group('totalDepenses getter', () {
    test('devrait calculer le total des dépenses', () async {
      // ARRANGE
      final testDepenses = <Depense>[
        Depense(
          id: 'dep-1',
          userId: 'user-1',
          titre: 'Dépense 1',
          montant: Decimal.parse('100'),
          date: DateTime.now(),
          categorie: 'fournitures',
        ),
        Depense(
          id: 'dep-2',
          userId: 'user-1',
          titre: 'Dépense 2',
          montant: Decimal.parse('50'),
          date: DateTime.now(),
          categorie: 'transport',
        ),
        Depense(
          id: 'dep-3',
          userId: 'user-1',
          titre: 'Dépense 3',
          montant: Decimal.parse('75.50'),
          date: DateTime.now(),
          categorie: 'autre',
        ),
      ];

      when(() => mockRepository.getDepenses())
          .thenAnswer((_) async => testDepenses);

      // ACT
      await viewModel.fetchDepenses();

      // ASSERT
      // Total: 100 + 50 + 75.50 = 225.50
      expect(viewModel.totalDepenses, Decimal.parse('225.5'));
    });

    test('devrait retourner zéro si pas de dépenses', () {
      // ASSERT
      expect(viewModel.totalDepenses, Decimal.zero);
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après fetch réussi', () async {
      // ARRANGE
      when(() => mockRepository.getDepenses()).thenAnswer((_) async => []);

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.fetchDepenses();
      expect(viewModel.isLoading, false);
    });
  });
}
