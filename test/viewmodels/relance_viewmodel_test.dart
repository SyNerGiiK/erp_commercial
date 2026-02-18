import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/relance_viewmodel.dart';
import 'package:erp_commercial/services/relance_service.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/client_model.dart';
import '../mocks/repository_mocks.dart';

// Tests unitaires pour RelanceViewModel — opérations pures (pas d'appels réseau)
void main() {
  group('RelanceViewModel - filtrage', () {
    late RelanceViewModel vm;
    late MockFactureRepository mockFactureRepo;
    late MockClientRepository mockClientRepo;

    setUp(() {
      mockFactureRepo = MockFactureRepository();
      mockClientRepo = MockClientRepository();
      vm = RelanceViewModel(
        factureRepo: mockFactureRepo,
        clientRepo: mockClientRepo,
      );
    });

    test('devrait avoir des listes vides initialement', () {
      expect(vm.relances, isEmpty);
      expect(vm.relancesFiltrees, isEmpty);
      expect(vm.totalRelances, 0);
      expect(vm.montantTotalImpaye, Decimal.zero);
      expect(vm.retardMoyen, 0.0);
      expect(vm.filtreNiveau, isNull);
    });

    test('devrait initialiser le filtre à null (toutes)', () {
      expect(vm.filtreNiveau, isNull);
    });

    test('devrait pouvoir changer le filtre', () {
      vm.filtrerParNiveau(NiveauRelance.amiable);
      expect(vm.filtreNiveau, NiveauRelance.amiable);

      vm.filtrerParNiveau(NiveauRelance.contentieux);
      expect(vm.filtreNiveau, NiveauRelance.contentieux);

      vm.filtrerParNiveau(null);
      expect(vm.filtreNiveau, isNull);
    });

    test('devrait être en loading false par défaut', () {
      expect(vm.isLoading, false);
    });
  });

  group('RelanceViewModel - stats', () {
    test('devrait retourner des stats vides quand pas de données', () {
      final vm = RelanceViewModel(
        factureRepo: MockFactureRepository(),
        clientRepo: MockClientRepository(),
      );
      expect(vm.montantTotalImpaye, Decimal.zero);
      expect(vm.retardMoyen, 0.0);
      expect(vm.totalRelances, 0);
    });
  });
}
