import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:erp_commercial/views/liste_clients_view.dart';
import 'package:erp_commercial/viewmodels/client_viewmodel.dart';
import 'package:erp_commercial/models/client_model.dart';
import '../mocks/repository_mocks.dart';

// Fake pour registerFallbackValue
class FakeClient extends Fake implements Client {}

void main() {
  late MockClientRepository mockRepository;
  late ClientViewModel clientViewModel;

  setUpAll(() {
    registerFallbackValue(FakeClient());
  });

  setUp(() {
    mockRepository = MockClientRepository();
    clientViewModel = ClientViewModel(repository: mockRepository);
  });

  Widget createListeClientsView() {
    return MaterialApp(
      home: ChangeNotifierProvider<ClientViewModel>.value(
        value: clientViewModel,
        child: const ListeClientsView(),
      ),
    );
  }

  group('ListeClientsView - Widget Tests', () {
    testWidgets('devrait afficher le titre "Clients"',
        (WidgetTester tester) async {
      // ARRANGE
      when(() => mockRepository.getClients()).thenAnswer((_) async => []);

      // ACT
      await tester.pumpWidget(createListeClientsView());
      await tester.pump(const Duration(milliseconds: 500));

      // ASSERT
      expect(find.text('Clients'), findsAtLeastNWidgets(1));
    });

    testWidgets('devrait afficher un champ de recherche',
        (WidgetTester tester) async {
      // ARRANGE
      when(() => mockRepository.getClients()).thenAnswer((_) async => []);

      // ACT
      await tester.pumpWidget(createListeClientsView());
      await tester.pump(const Duration(milliseconds: 500));

      // ASSERT
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Rechercher...'), findsOneWidget);
    });

    testWidgets('devrait afficher un FloatingActionButton pour ajouter',
        (WidgetTester tester) async {
      // ARRANGE
      when(() => mockRepository.getClients()).thenAnswer((_) async => []);

      // ACT
      await tester.pumpWidget(createListeClientsView());
      await tester.pump(const Duration(milliseconds: 500));

      // ASSERT
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('devrait afficher la liste des clients',
        (WidgetTester tester) async {
      // ARRANGE
      final clients = <Client>[
        Client(
          id: 'c1',
          userId: 'user-1',
          nomComplet: 'Dupont Jean',
          adresse: '1 rue Test',
          codePostal: '75001',
          ville: 'Paris',
          telephone: '0601',
          email: 'dupont@test.com',
        ),
        Client(
          id: 'c2',
          userId: 'user-1',
          nomComplet: 'Martin Sophie',
          adresse: '2 ave Test',
          codePostal: '69000',
          ville: 'Lyon',
          telephone: '0602',
          email: 'martin@test.com',
        ),
      ];

      when(() => mockRepository.getClients()).thenAnswer((_) async => clients);

      // ACT
      await tester.pumpWidget(createListeClientsView());
      await tester.pump(const Duration(milliseconds: 500));

      // ASSERT
      expect(find.text('Dupont Jean'), findsOneWidget);
      expect(find.text('Martin Sophie'), findsOneWidget);
    });

    testWidgets('devrait filtrer les clients par recherche',
        (WidgetTester tester) async {
      // ARRANGE
      final clients = <Client>[
        Client(
          id: 'c1',
          userId: 'user-1',
          nomComplet: 'Dupont Jean',
          adresse: '1 rue Test',
          codePostal: '75001',
          ville: 'Paris',
          telephone: '0601',
          email: 'dupont@test.com',
        ),
        Client(
          id: 'c2',
          userId: 'user-1',
          nomComplet: 'Martin Sophie',
          adresse: '2 ave Test',
          codePostal: '69000',
          ville: 'Lyon',
          telephone: '0602',
          email: 'martin@test.com',
        ),
      ];

      when(() => mockRepository.getClients()).thenAnswer((_) async => clients);

      // ACT
      await tester.pumpWidget(createListeClientsView());
      await tester.pump(const Duration(milliseconds: 500));

      // Taper "Dupont" dans la recherche
      await tester.enterText(find.byType(TextField), 'Dupont');
      await tester.pump();

      // ASSERT: Seul Dupont devrait être visible
      expect(find.text('Dupont Jean'), findsOneWidget);
      expect(find.text('Martin Sophie'), findsNothing);
    });

    testWidgets('devrait filtrer les clients par ville',
        (WidgetTester tester) async {
      // ARRANGE
      final clients = <Client>[
        Client(
          id: 'c1',
          userId: 'user-1',
          nomComplet: 'Dupont Jean',
          adresse: '1 rue Test',
          codePostal: '75001',
          ville: 'Paris',
          telephone: '0601',
          email: 'dupont@test.com',
        ),
        Client(
          id: 'c2',
          userId: 'user-1',
          nomComplet: 'Martin Sophie',
          adresse: '2 ave Test',
          codePostal: '69000',
          ville: 'Lyon',
          telephone: '0602',
          email: 'martin@test.com',
        ),
      ];

      when(() => mockRepository.getClients()).thenAnswer((_) async => clients);

      // ACT
      await tester.pumpWidget(createListeClientsView());
      await tester.pump(const Duration(milliseconds: 500));

      // Rechercher par ville
      await tester.enterText(find.byType(TextField), 'Lyon');
      await tester.pump();

      // ASSERT
      expect(find.text('Martin Sophie'), findsOneWidget);
      expect(find.text('Dupont Jean'), findsNothing);
    });

    testWidgets('devrait afficher un message si liste vide',
        (WidgetTester tester) async {
      // ARRANGE
      when(() => mockRepository.getClients()).thenAnswer((_) async => []);

      // ACT
      await tester.pumpWidget(createListeClientsView());
      await tester.pump(const Duration(milliseconds: 500));

      // ASSERT: Vérifier qu'il n'y a pas de clients affichés
      expect(find.byType(ListTile), findsNothing);
    });
  });

  group('ListeClientsView - Interactions', () {
    testWidgets('devrait effacer la recherche et afficher tous les clients',
        (WidgetTester tester) async {
      // ARRANGE
      final clients = <Client>[
        Client(
          id: 'c1',
          userId: 'user-1',
          nomComplet: 'Dupont Jean',
          adresse: '1 rue Test',
          codePostal: '75001',
          ville: 'Paris',
          telephone: '0601',
          email: 'dupont@test.com',
        ),
        Client(
          id: 'c2',
          userId: 'user-1',
          nomComplet: 'Martin Sophie',
          adresse: '2 ave Test',
          codePostal: '69000',
          ville: 'Lyon',
          telephone: '0602',
          email: 'martin@test.com',
        ),
      ];

      when(() => mockRepository.getClients()).thenAnswer((_) async => clients);

      // ACT
      await tester.pumpWidget(createListeClientsView());
      await tester.pump(const Duration(milliseconds: 500));

      // Rechercher
      await tester.enterText(find.byType(TextField), 'Dupont');
      await tester.pump();
      expect(find.text('Martin Sophie'), findsNothing);

      // Effacer la recherche
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // ASSERT: Les deux clients devraient être visibles
      expect(find.text('Dupont Jean'), findsOneWidget);
      expect(find.text('Martin Sophie'), findsOneWidget);
    });
  });
}
