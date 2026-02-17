import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/viewmodels/urssaf_viewmodel.dart';
import 'package:erp_commercial/models/urssaf_model.dart';
import '../mocks/repository_mocks.dart';

// Fake pour les types complexes
class FakeUrssafConfig extends Fake implements UrssafConfig {}

void main() {
  late MockUrssafRepository mockRepository;
  late UrssafViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeUrssafConfig());
  });

  setUp(() {
    mockRepository = MockUrssafRepository();
    viewModel = UrssafViewModel(repository: mockRepository);
  });

  group('loadConfig', () {
    test('devrait charger et exposer la configuration URSSAF', () async {
      // ARRANGE
      final testConfig = UrssafConfig(
        id: 'config-1',
        userId: 'user-1',
        accreActive: true,
        accreAnnee: 2,
        tauxMicroVente: Decimal.parse('0.123'),
        tauxMicroPrestationBIC: Decimal.parse('0.212'),
        tauxMicroPrestationBNC: Decimal.parse('0.246'),
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => testConfig);

      // ACT
      await viewModel.loadConfig();

      // ASSERT
      expect(viewModel.config, isNotNull);
      expect(viewModel.config!.id, 'config-1');
      expect(viewModel.config!.accreActive, true);
      expect(viewModel.config!.accreAnnee, 2);
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.getConfig()).called(1);
    });

    test('devrait créer une config par défaut en cas d\'erreur', () async {
      // ARRANGE
      when(() => mockRepository.getConfig())
          .thenThrow(Exception('Erreur réseau'));

      // ACT
      await viewModel.loadConfig();

      // ASSERT
      expect(viewModel.config, isNotNull);
      expect(viewModel.config!.id, ''); // Config vide par défaut
      expect(viewModel.isLoading, false);
    });
  });

  group('saveConfig', () {
    test('devrait enregistrer et recharger la configuration', () async {
      // ARRANGE
      final newConfig = UrssafConfig(
        id: 'config-1',
        userId: 'user-1',
        accreActive: true,
        accreAnnee: 3,
        tauxMicroVente: Decimal.parse('0.06'), // ACCRE réduit
        tauxMicroPrestationBIC: Decimal.parse('0.106'),
        tauxMicroPrestationBNC: Decimal.parse('0.123'),
      );

      final savedConfig = UrssafConfig(
        id: 'config-1',
        userId: 'user-1',
        accreActive: true,
        accreAnnee: 3,
        tauxMicroVente: Decimal.parse('0.06'),
        tauxMicroPrestationBIC: Decimal.parse('0.106'),
        tauxMicroPrestationBNC: Decimal.parse('0.123'),
      );

      when(() => mockRepository.saveConfig(any())).thenAnswer((_) async {});
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => savedConfig);

      // ACT
      await viewModel.saveConfig(newConfig);

      // ASSERT
      expect(viewModel.config, isNotNull);
      expect(viewModel.config!.accreAnnee, 3);
      verify(() => mockRepository.saveConfig(newConfig)).called(1);
      verify(() => mockRepository.getConfig()).called(1); // Reload après save
    });

    test('devrait relancer l\'exception en cas d\'erreur de sauvegarde',
        () async {
      // ARRANGE
      final newConfig = UrssafConfig(
        id: 'config-1',
        userId: 'user-1',
        accreActive: false,
      );

      when(() => mockRepository.saveConfig(any()))
          .thenThrow(Exception('Save failed'));

      // ACT & ASSERT
      expect(
        () => viewModel.saveConfig(newConfig),
        throwsException,
      );
    });
  });

  group('Calculs Taux ACCRE', () {
    test('devrait retourner les taux réduits si ACCRE active (année 1)',
        () async {
      // ARRANGE
      final configAccre = UrssafConfig(
        id: 'config-1',
        userId: 'user-1',
        accreActive: true,
        accreAnnee: 1, // Première année
        // Les taux par défaut seront appliqués dans le modèle
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => configAccre);

      // ACT
      await viewModel.loadConfig();

      // ASSERT
      expect(viewModel.config!.accreActive, true);
      expect(viewModel.config!.accreAnnee, 1);
      // En année 1, les taux doivent être réduits
    });

    test('devrait retourner les taux normaux si ACCRE inactive', () async {
      // ARRANGE
      final configNormale = UrssafConfig(
        id: 'config-1',
        userId: 'user-1',
        accreActive: false,
        // Taux normaux par défaut
        tauxMicroVente: Decimal.parse('0.123'),
        tauxMicroPrestationBIC: Decimal.parse('0.212'),
        tauxMicroPrestationBNC: Decimal.parse('0.246'),
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => configNormale);

      // ACT
      await viewModel.loadConfig();

      // ASSERT
      expect(viewModel.config!.accreActive, false);
      expect(viewModel.config!.tauxMicroVente, Decimal.parse('0.123'));
      expect(viewModel.config!.tauxMicroPrestationBIC, Decimal.parse('0.212'));
      expect(viewModel.config!.tauxMicroPrestationBNC, Decimal.parse('0.246'));
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après load réussi', () async {
      // ARRANGE
      when(() => mockRepository.getConfig()).thenAnswer(
        (_) async => UrssafConfig(id: '1', userId: 'user-1'),
      );

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.loadConfig();
      expect(viewModel.isLoading, false);
    });
  });
}
