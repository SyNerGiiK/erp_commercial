import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/shopping_viewmodel.dart';
import 'package:erp_commercial/models/shopping_model.dart';
import '../mocks/repository_mocks.dart';

// Fake pour les types complexes
class FakeShoppingItem extends Fake implements ShoppingItem {}

void main() {
  late MockShoppingRepository mockRepository;
  late ShoppingViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeShoppingItem());
  });

  setUp(() {
    mockRepository = MockShoppingRepository();
    viewModel = ShoppingViewModel(repository: mockRepository);
  });

  group('fetchItems', () {
    test('devrait récupérer et exposer les items du panier', () async {
      // ARRANGE
      final testItems = <ShoppingItem>[
        ShoppingItem(
          id: 'item-1',
          userId: 'user-1',
          designation: 'Pain',
          quantite: Decimal.parse('2'),
          prixUnitaire: Decimal.parse('1.5'),
          unite: 'u',
          estAchete: false,
        ),
        ShoppingItem(
          id: 'item-2',
          userId: 'user-1',
          designation: 'Lait',
          quantite: Decimal.parse('1'),
          prixUnitaire: Decimal.parse('1.2'),
          unite: 'L',
          estAchete: true,
        ),
      ];

      when(() => mockRepository.getItems()).thenAnswer((_) async => testItems);

      // ACT
      await viewModel.fetchItems();

      // ASSERT
      expect(viewModel.items.length, 2);
      expect(viewModel.items[0].designation, 'Pain');
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.getItems()).called(1);
    });

    test('devrait gérer les erreurs sans crash (liste vide)', () async {
      // ARRANGE
      when(() => mockRepository.getItems())
          .thenThrow(Exception('Erreur réseau'));

      // ACT
      await viewModel.fetchItems();

      // ASSERT
      expect(viewModel.items, isEmpty);
      expect(viewModel.isLoading, false);
    });
  });

  group('addItem', () {
    test('devrait ajouter un item et rafraîchir la liste', () async {
      // ARRANGE
      final newItem = ShoppingItem(
        userId: 'user-1',
        designation: 'Fromage',
        quantite: Decimal.parse('1'),
        prixUnitaire: Decimal.parse('5'),
      );

      final updatedItems = <ShoppingItem>[
        ShoppingItem(
          id: 'item-1',
          userId: 'user-1',
          designation: 'Fromage',
          quantite: Decimal.parse('1'),
          prixUnitaire: Decimal.parse('5'),
        ),
      ];

      when(() => mockRepository.addItem(any())).thenAnswer((_) async {});
      when(() => mockRepository.getItems())
          .thenAnswer((_) async => updatedItems);

      // ACT
      await viewModel.addItem(newItem);

      // ASSERT
      expect(viewModel.items.length, 1);
      verify(() => mockRepository.addItem(newItem)).called(1);
      verify(() => mockRepository.getItems()).called(1);
    });
  });

  group('deleteItem', () {
    test('devrait supprimer un item et rafraîchir', () async {
      // ARRANGE
      const itemIdToDelete = 'item-1';
      final remaining = <ShoppingItem>[
        ShoppingItem(
          id: 'item-2',
          userId: 'user-1',
          designation: 'Lait',
          quantite: Decimal.parse('1'),
          prixUnitaire: Decimal.parse('1.2'),
        ),
      ];

      when(() => mockRepository.deleteItem(itemIdToDelete))
          .thenAnswer((_) async {});
      when(() => mockRepository.getItems()).thenAnswer((_) async => remaining);

      // ACT
      await viewModel.deleteItem(itemIdToDelete);

      // ASSERT
      expect(viewModel.items.length, 1);
      verify(() => mockRepository.deleteItem(itemIdToDelete)).called(1);
    });
  });

  group('toggleCheck', () {
    test('devrait faire un optimistic update puis appeler le repository',
        () async {
      // ARRANGE
      final initialItems = <ShoppingItem>[
        ShoppingItem(
          id: 'item-1',
          userId: 'user-1',
          designation: 'Pain',
          quantite: Decimal.parse('1'),
          prixUnitaire: Decimal.parse('1.5'),
          estAchete: false, // Non acheté
        ),
      ];

      when(() => mockRepository.getItems())
          .thenAnswer((_) async => initialItems);
      await viewModel.fetchItems(); // Load initial state

      when(() => mockRepository.updateItem(any())).thenAnswer((_) async {});

      // ACT
      await viewModel.toggleCheck(initialItems[0]);

      // ASSERT
      // Optimistic update should mark as checked
      expect(viewModel.items[0].estAchete, true);
      verify(() => mockRepository.updateItem(any())).called(1);
    });

    test('devrait rollback en cas d\'erreur (refresh depuis serveur)',
        () async {
      // ARRANGE
      final createInitialItems = () => <ShoppingItem>[
            ShoppingItem(
              id: 'item-1',
              userId: 'user-1',
              designation: 'Pain',
              quantite: Decimal.parse('1'),
              prixUnitaire: Decimal.parse('1.5'),
              estAchete: false,
            ),
          ];

      when(() => mockRepository.getItems())
          .thenAnswer((_) async => createInitialItems());
      await viewModel.fetchItems();

      final itemToToggle = viewModel.items[0];

      // Simulate update error -> rollback via fetchItems
      when(() => mockRepository.updateItem(any()))
          .thenThrow(Exception('Update failed'));

      // ACT
      await viewModel.toggleCheck(itemToToggle);

      // ASSERT
      // Should rollback to original state (false)
      expect(viewModel.items[0].estAchete, false);
      verify(() => mockRepository.getItems()).called(greaterThanOrEqualTo(2));
    });
  });

  group('totalPanier getter', () {
    test('devrait calculer le total du panier', () async {
      // ARRANGE
      final testItems = <ShoppingItem>[
        ShoppingItem(
          id: 'item-1',
          userId: 'user-1',
          designation: 'Pain',
          quantite: Decimal.parse('2'),
          prixUnitaire: Decimal.parse('1.5'),
        ), // 2 * 1.5 = 3
        ShoppingItem(
          id: 'item-2',
          userId: 'user-1',
          designation: 'Lait',
          quantite: Decimal.parse('1'),
          prixUnitaire: Decimal.parse('1.2'),
        ), // 1 * 1.2 = 1.2
      ];

      when(() => mockRepository.getItems()).thenAnswer((_) async => testItems);

      // ACT
      await viewModel.fetchItems();

      // ASSERT
      // Total: 3 + 1.2 = 4.2
      expect(viewModel.totalPanier, Decimal.parse('4.2'));
    });

    test('devrait retourner zéro si panier vide', () {
      // ACT & ASSERT
      expect(viewModel.totalPanier, Decimal.zero);
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après fetch réussi', () async {
      // ARRANGE
      when(() => mockRepository.getItems()).thenAnswer((_) async => []);

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.fetchItems();
      expect(viewModel.isLoading, false);
    });
  });
}
