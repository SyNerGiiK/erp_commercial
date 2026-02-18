import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/temps_viewmodel.dart';
import 'package:erp_commercial/models/temps_activite_model.dart';
import '../mocks/repository_mocks.dart';

class _FakeTempsActivite extends Fake implements TempsActivite {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeTempsActivite());
  });
  group('TempsViewModel - état initial', () {
    late TempsViewModel vm;
    late MockTempsRepository mockRepo;

    setUp(() {
      mockRepo = MockTempsRepository();
      vm = TempsViewModel(repository: mockRepo);
    });

    test('devrait avoir des listes vides initialement', () {
      expect(vm.items, isEmpty);
      expect(vm.nonFactures, isEmpty);
      expect(vm.totalMinutesMois, 0);
      expect(vm.caPotentiel, Decimal.zero);
      expect(vm.isLoading, false);
    });

    test('devrait retourner un format d\'heures vide', () {
      expect(vm.totalHeuresMoisFormate, '0h00');
    });
  });

  group('TempsViewModel - loadAll', () {
    late TempsViewModel vm;
    late MockTempsRepository mockRepo;

    final now = DateTime.now();
    final testItems = [
      TempsActivite(
        id: '1',
        clientId: 'c1',
        description: 'Développement feature A',
        projet: 'Projet X',
        dateActivite: now,
        dureeMinutes: 120,
        tauxHoraire: Decimal.fromInt(50),
        estFacturable: true,
        estFacture: false,
      ),
      TempsActivite(
        id: '2',
        clientId: 'c1',
        description: 'Réunion client',
        projet: 'Projet X',
        dateActivite: now,
        dureeMinutes: 60,
        tauxHoraire: Decimal.fromInt(50),
        estFacturable: true,
        estFacture: true,
        factureId: 'f1',
      ),
      TempsActivite(
        id: '3',
        clientId: 'c2',
        description: 'Formation interne',
        projet: '',
        dateActivite: now,
        dureeMinutes: 90,
        tauxHoraire: Decimal.fromInt(50),
        estFacturable: false,
        estFacture: false,
      ),
    ];

    setUp(() {
      mockRepo = MockTempsRepository();
      vm = TempsViewModel(repository: mockRepo);
    });

    test('devrait charger toutes les entrées de temps', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.items, hasLength(3));
    });

    test('devrait filtrer les entrées non facturées facturables', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      // Non facturés = facturables ET pas encore facturés
      expect(vm.nonFactures, hasLength(1));
      expect(vm.nonFactures[0].id, '1');
    });

    test('devrait calculer le total minutes du mois courant', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      // Tous les items ont la date now → même mois → 120 + 60 + 90 = 270
      expect(vm.totalMinutesMois, 270);
    });

    test('devrait formater le total heures', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      // 270 min = 4h30
      expect(vm.totalHeuresMoisFormate, '4h30');
    });

    test('devrait calculer le CA potentiel', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      // nonFactures = item 1 (120 min, 50€/h) → 120/60 * 50 = 100€
      expect(vm.caPotentiel, Decimal.fromInt(100));
    });

    test('devrait grouper par client', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      final parClient = vm.parClient;
      expect(parClient, hasLength(2));
      expect(parClient['c1'], hasLength(2));
      expect(parClient['c2'], hasLength(1));
    });

    test('devrait grouper par projet', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      final parProjet = vm.parProjet;
      expect(parProjet, hasLength(2));
      expect(parProjet['Projet X'], hasLength(2));
      expect(parProjet['Sans projet'], hasLength(1));
    });
  });

  group('TempsViewModel - CRUD', () {
    late TempsViewModel vm;
    late MockTempsRepository mockRepo;

    setUp(() {
      mockRepo = MockTempsRepository();
      vm = TempsViewModel(repository: mockRepo);
    });

    test('devrait créer une entrée de temps', () async {
      final newItem = TempsActivite(
        clientId: 'c1',
        description: 'Nouvelle tâche',
        dateActivite: DateTime.now(),
        dureeMinutes: 45,
        tauxHoraire: Decimal.fromInt(60),
      );

      when(() => mockRepo.create(any())).thenAnswer((_) async => 'new-id');
      when(() => mockRepo.getAll()).thenAnswer((_) async => [newItem]);

      await vm.create(newItem);

      verify(() => mockRepo.create(any())).called(1);
    });

    test('devrait supprimer une entrée de temps', () async {
      when(() => mockRepo.delete('1')).thenAnswer((_) async {});
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);

      await vm.delete('1');

      verify(() => mockRepo.delete('1')).called(1);
    });

    test('devrait marquer des entrées comme facturées', () async {
      when(() => mockRepo.marquerFacture(['1', '2'], 'f1'))
          .thenAnswer((_) async {});
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);

      await vm.marquerFacture(['1', '2'], 'f1');

      verify(() => mockRepo.marquerFacture(['1', '2'], 'f1')).called(1);
    });
  });
}
