import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/facture_recurrente_viewmodel.dart';
import 'package:erp_commercial/models/facture_recurrente_model.dart';
import '../mocks/repository_mocks.dart';

class _FakeFactureRecurrente extends Fake implements FactureRecurrente {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeFactureRecurrente());
  });
  group('FactureRecurrenteViewModel - état initial', () {
    late FactureRecurrenteViewModel vm;
    late MockFactureRecurrenteRepository mockRepo;

    setUp(() {
      mockRepo = MockFactureRecurrenteRepository();
      vm = FactureRecurrenteViewModel(repository: mockRepo);
    });

    test('devrait avoir des listes vides initialement', () {
      expect(vm.items, isEmpty);
      expect(vm.actives, isEmpty);
      expect(vm.inactives, isEmpty);
      expect(vm.aGenerer, isEmpty);
      expect(vm.totalGeneres, 0);
      expect(vm.isLoading, false);
    });
  });

  group('FactureRecurrenteViewModel - loadAll', () {
    late FactureRecurrenteViewModel vm;
    late MockFactureRecurrenteRepository mockRepo;

    final testItems = [
      FactureRecurrente(
        id: '1',
        clientId: 'c1',
        objet: 'Maintenance mensuelle',
        frequence: FrequenceRecurrence.mensuelle,
        prochaineEmission: DateTime.now().subtract(const Duration(days: 1)),
        totalHt: Decimal.fromInt(500),
        totalTva: Decimal.fromInt(100),
        totalTtc: Decimal.fromInt(600),
        remiseTaux: Decimal.zero,
        estActive: true,
        nbFacturesGenerees: 3,
      ),
      FactureRecurrente(
        id: '2',
        clientId: 'c2',
        objet: 'Hébergement web',
        frequence: FrequenceRecurrence.annuelle,
        prochaineEmission: DateTime.now().add(const Duration(days: 30)),
        totalHt: Decimal.fromInt(200),
        totalTva: Decimal.fromInt(40),
        totalTtc: Decimal.fromInt(240),
        remiseTaux: Decimal.zero,
        estActive: false,
        nbFacturesGenerees: 1,
      ),
    ];

    setUp(() {
      mockRepo = MockFactureRecurrenteRepository();
      vm = FactureRecurrenteViewModel(repository: mockRepo);
    });

    test('devrait charger les factures récurrentes', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.items, hasLength(2));
      expect(vm.items[0].objet, 'Maintenance mensuelle');
    });

    test('devrait filtrer les actives', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.actives, hasLength(1));
      expect(vm.actives[0].id, '1');
    });

    test('devrait filtrer les inactives', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.inactives, hasLength(1));
      expect(vm.inactives[0].id, '2');
    });

    test('devrait identifier les factures à générer', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      // La première a une date passée et est active → à générer
      expect(vm.aGenerer, hasLength(1));
      expect(vm.aGenerer[0].id, '1');
    });

    test('devrait calculer le total des factures générées', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.totalGeneres, 4); // 3 + 1
    });
  });

  group('FactureRecurrenteViewModel - CRUD', () {
    late FactureRecurrenteViewModel vm;
    late MockFactureRecurrenteRepository mockRepo;

    setUp(() {
      mockRepo = MockFactureRecurrenteRepository();
      vm = FactureRecurrenteViewModel(repository: mockRepo);
    });

    test('devrait créer une facture récurrente', () async {
      final newItem = FactureRecurrente(
        clientId: 'c1',
        objet: 'Nouveau contrat',
        frequence: FrequenceRecurrence.trimestrielle,
        prochaineEmission: DateTime.now().add(const Duration(days: 90)),
        totalHt: Decimal.fromInt(1000),
        totalTva: Decimal.fromInt(200),
        totalTtc: Decimal.fromInt(1200),
        remiseTaux: Decimal.zero,
      );

      when(() => mockRepo.create(any()))
          .thenAnswer((_) async => newItem.copyWith(id: 'new-id'));
      when(() => mockRepo.getAll()).thenAnswer((_) async => [newItem]);

      await vm.create(newItem);

      verify(() => mockRepo.create(any())).called(1);
    });

    test('devrait supprimer une facture récurrente', () async {
      when(() => mockRepo.delete('1')).thenAnswer((_) async {});
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);

      await vm.delete('1');

      verify(() => mockRepo.delete('1')).called(1);
    });

    test('devrait basculer l\'état actif', () async {
      // Le VM a besoin d'items chargés pour trouver l'item et calculer newState
      final item = FactureRecurrente(
        id: '1',
        clientId: 'c1',
        objet: 'Test toggle',
        frequence: FrequenceRecurrence.mensuelle,
        prochaineEmission: DateTime.now(),
        totalHt: Decimal.fromInt(100),
        totalTva: Decimal.fromInt(20),
        totalTtc: Decimal.fromInt(120),
        remiseTaux: Decimal.zero,
        estActive: true,
      );
      when(() => mockRepo.getAll()).thenAnswer((_) async => [item]);
      await vm.loadAll();

      when(() => mockRepo.toggleActive(any(), any())).thenAnswer((_) async {});

      await vm.toggleActive('1');

      // estActive était true → newState = false
      verify(() => mockRepo.toggleActive('1', false)).called(1);
    });
  });

  group('FactureRecurrenteViewModel - calculerProchaineDate', () {
    test('devrait calculer la prochaine date mensuelle', () {
      final current = DateTime(2026, 1, 15);
      final next = FactureRecurrenteViewModel.calculerProchaineDate(
        current,
        FrequenceRecurrence.mensuelle,
      );
      expect(next, DateTime(2026, 2, 15));
    });

    test('devrait calculer la prochaine date trimestrielle', () {
      final current = DateTime(2026, 1, 10);
      final next = FactureRecurrenteViewModel.calculerProchaineDate(
        current,
        FrequenceRecurrence.trimestrielle,
      );
      expect(next, DateTime(2026, 4, 10));
    });

    test('devrait calculer la prochaine date annuelle', () {
      final current = DateTime(2026, 6, 1);
      final next = FactureRecurrenteViewModel.calculerProchaineDate(
        current,
        FrequenceRecurrence.annuelle,
      );
      expect(next, DateTime(2027, 6, 1));
    });

    test('devrait calculer la prochaine date hebdomadaire', () {
      final current = DateTime(2026, 3, 1);
      final next = FactureRecurrenteViewModel.calculerProchaineDate(
        current,
        FrequenceRecurrence.hebdomadaire,
      );
      expect(next, DateTime(2026, 3, 8));
    });
  });
}
