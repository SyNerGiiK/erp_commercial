import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:erp_commercial/viewmodels/rappel_viewmodel.dart';
import 'package:erp_commercial/models/rappel_model.dart';
import '../mocks/repository_mocks.dart';

class _FakeRappel extends Fake implements Rappel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRappel());
  });
  group('RappelViewModel - état initial', () {
    late RappelViewModel vm;
    late MockRappelRepository mockRepo;

    setUp(() {
      mockRepo = MockRappelRepository();
      vm = RappelViewModel(repository: mockRepo);
    });

    test('devrait avoir des listes vides initialement', () {
      expect(vm.items, isEmpty);
      expect(vm.actifs, isEmpty);
      expect(vm.enRetard, isEmpty);
      expect(vm.proches, isEmpty);
      expect(vm.completes, isEmpty);
      expect(vm.nbUrgents, 0);
      expect(vm.isLoading, false);
    });
  });

  group('RappelViewModel - loadAll & filtres', () {
    late RappelViewModel vm;
    late MockRappelRepository mockRepo;

    final testItems = [
      // En retard
      Rappel(
        id: '1',
        titre: 'URSSAF T1',
        typeRappel: TypeRappel.urssaf,
        dateEcheance: DateTime.now().subtract(const Duration(days: 5)),
        priorite: PrioriteRappel.urgente,
      ),
      // Proche (dans 3 jours)
      Rappel(
        id: '2',
        titre: 'CFE 2026',
        typeRappel: TypeRappel.cfe,
        dateEcheance: DateTime.now().add(const Duration(days: 3)),
        priorite: PrioriteRappel.haute,
      ),
      // Lointain (dans 60 jours)
      Rappel(
        id: '3',
        titre: 'Impôts 2026',
        typeRappel: TypeRappel.impots,
        dateEcheance: DateTime.now().add(const Duration(days: 60)),
        priorite: PrioriteRappel.normale,
      ),
      // Complété
      Rappel(
        id: '4',
        titre: 'URSSAF T4 2025',
        typeRappel: TypeRappel.urssaf,
        dateEcheance: DateTime.now().subtract(const Duration(days: 30)),
        estComplete: true,
      ),
    ];

    setUp(() {
      mockRepo = MockRappelRepository();
      vm = RappelViewModel(repository: mockRepo);
    });

    test('devrait charger tous les rappels', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.items, hasLength(4));
    });

    test('devrait filtrer les rappels actifs (non complétés)', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.actifs, hasLength(3));
    });

    test('devrait détecter les rappels en retard', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.enRetard, hasLength(1));
      expect(vm.enRetard[0].id, '1');
    });

    test('devrait détecter les rappels proches (< 7 jours)', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      // Le rappel en retard (id: 1) + le proche (id: 2)
      expect(vm.proches.length, greaterThanOrEqualTo(1));
    });

    test('devrait filtrer les complétés', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      expect(vm.completes, hasLength(1));
      expect(vm.completes[0].id, '4');
    });

    test('devrait compter les urgents non complétés', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      // id:1 en retard + id:2 proche = 2 urgents
      expect(vm.nbUrgents, 2);
    });

    test('devrait grouper par type', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => testItems);

      await vm.loadAll();

      final parType = vm.parType;
      // parType filtre sur actifs (non complétés) → id:4 exclu
      expect(parType[TypeRappel.urssaf], hasLength(1));
      expect(parType[TypeRappel.cfe], hasLength(1));
      expect(parType[TypeRappel.impots], hasLength(1));
    });
  });

  group('RappelViewModel - CRUD', () {
    late RappelViewModel vm;
    late MockRappelRepository mockRepo;

    setUp(() {
      mockRepo = MockRappelRepository();
      vm = RappelViewModel(repository: mockRepo);
    });

    test('devrait créer un rappel', () async {
      final rappel = Rappel(
        titre: 'Nouveau rappel',
        typeRappel: TypeRappel.custom,
        dateEcheance: DateTime.now().add(const Duration(days: 14)),
      );

      when(() => mockRepo.create(any())).thenAnswer((_) async => 'new-id');
      when(() => mockRepo.getAll()).thenAnswer((_) async => [rappel]);

      await vm.create(rappel);

      verify(() => mockRepo.create(any())).called(1);
    });

    test('devrait supprimer un rappel', () async {
      when(() => mockRepo.delete('1')).thenAnswer((_) async {});
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);

      await vm.delete('1');

      verify(() => mockRepo.delete('1')).called(1);
    });

    test('devrait compléter un rappel', () async {
      when(() => mockRepo.completer('1')).thenAnswer((_) async {});
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);

      await vm.completer('1');

      verify(() => mockRepo.completer('1')).called(1);
    });

    test('devrait décompléter un rappel', () async {
      when(() => mockRepo.decompleter('1')).thenAnswer((_) async {});
      when(() => mockRepo.getAll()).thenAnswer((_) async => []);

      await vm.decompleter('1');

      verify(() => mockRepo.decompleter('1')).called(1);
    });
  });
}
