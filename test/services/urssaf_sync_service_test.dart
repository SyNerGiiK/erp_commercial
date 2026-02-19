// Tests P2-P6 : Modèle étendu, SyncService, répartition, simulation VL vs IR
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;

import 'package:erp_commercial/models/urssaf_model.dart';
import 'package:erp_commercial/models/enums/entreprise_enums.dart';
import 'package:erp_commercial/services/urssaf_sync_service.dart';
import 'package:erp_commercial/viewmodels/urssaf_viewmodel.dart';
import '../mocks/repository_mocks.dart';

// -- Mocks --
class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

class FakeUrssafConfig extends Fake implements UrssafConfig {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(FakeUrssafConfig());
  });

  // ═══════════════════════════════════════════════════════
  //  P2 : plafondVlRfr, lastSyncedAt, sourceApi
  // ═══════════════════════════════════════════════════════
  group('P2 — Champs plafondVlRfr, lastSyncedAt, sourceApi', () {
    test('devrait avoir plafondVlRfr = 29315 par défaut', () {
      final config = UrssafConfig(userId: 'u1');
      expect(config.plafondVlRfr, Decimal.parse('29315'));
    });

    test('devrait accepter un plafondVlRfr custom', () {
      final config = UrssafConfig(
        userId: 'u1',
        plafondVlRfr: Decimal.parse('30000'),
      );
      expect(config.plafondVlRfr, Decimal.parse('30000'));
    });

    test('devrait sérialiser lastSyncedAt et sourceApi dans toMap', () {
      final now = DateTime(2026, 2, 20, 14, 30);
      final config = UrssafConfig(
        userId: 'u1',
        lastSyncedAt: now,
        sourceApi: true,
      );

      final map = config.toMap();
      expect(map['last_synced_at'], now.toIso8601String());
      expect(map['source_api'], true);
      expect(map['plafond_vl_rfr'], '29315');
    });

    test('devrait désérialiser lastSyncedAt et sourceApi depuis fromMap', () {
      final map = {
        'user_id': 'u1',
        'last_synced_at': '2026-02-20T14:30:00.000',
        'source_api': true,
        'plafond_vl_rfr': '30000',
      };

      final config = UrssafConfig.fromMap(map);
      expect(config.lastSyncedAt, DateTime(2026, 2, 20, 14, 30));
      expect(config.sourceApi, true);
      expect(config.plafondVlRfr, Decimal.parse('30000'));
    });

    test('devrait copier correctement avec copyWith', () {
      final now = DateTime.now();
      final config = UrssafConfig(userId: 'u1');
      final updated = config.copyWith(
        plafondVlRfr: Decimal.parse('31000'),
        lastSyncedAt: now,
        sourceApi: true,
      );

      expect(updated.plafondVlRfr, Decimal.parse('31000'));
      expect(updated.lastSyncedAt, now);
      expect(updated.sourceApi, true);
      // Les autres champs doivent rester identiques
      expect(updated.tauxMicroVente, config.tauxMicroVente);
    });
  });

  // ═══════════════════════════════════════════════════════
  //  P1 : TFC calculerCotisations
  // ═══════════════════════════════════════════════════════
  group('P1 — TFC dans calculerCotisations', () {
    test('devrait calculer la TFC sur CA vente + BIC', () {
      final config = UrssafConfig(
        userId: 'u1',
        tauxTfcService: Decimal.parse('0.48'),
        tauxTfcVente: Decimal.parse('0.22'),
      );

      final result = config.calculerCotisations(
        Decimal.parse('10000'), // caVente
        Decimal.parse('20000'), // caPrestaBIC
        Decimal.zero, // caPrestaBNC
      );

      // TFC service = 20000 * 0.48% = 96
      // TFC vente = 10000 * 0.22% = 22
      expect(result['tfc'], Decimal.parse('118'));
      expect(result['total']! > Decimal.zero, true);
    });

    test('devrait retourner TFC = 0 si pas de CA', () {
      final config = UrssafConfig(userId: 'u1');
      final result = config.calculerCotisations(
        Decimal.zero,
        Decimal.zero,
        Decimal.zero,
      );
      expect(result['tfc'], Decimal.zero);
    });

    test('devrait retourner TFC = 0 pour un libéral même avec CA', () {
      final config = UrssafConfig(
        userId: 'u1',
        statut: StatutEntrepreneur.liberal,
        tauxTfcService: Decimal.parse('0.48'),
        tauxTfcVente: Decimal.parse('0.22'),
      );

      final result = config.calculerCotisations(
        Decimal.parse('10000'), // caVente
        Decimal.parse('20000'), // caPrestaBIC
        Decimal.parse('5000'), // caPrestaBNC
      );

      // TFC ne s'applique PAS aux professions libérales
      expect(result['tfc'], Decimal.zero);
    });

    test('devrait appliquer TFC pour un commerçant', () {
      final config = UrssafConfig(
        userId: 'u1',
        statut: StatutEntrepreneur.commercant,
        tauxTfcService: Decimal.parse('0.48'),
        tauxTfcVente: Decimal.parse('0.22'),
      );

      final result = config.calculerCotisations(
        Decimal.parse('10000'), // caVente
        Decimal.parse('20000'), // caPrestaBIC
        Decimal.zero,
      );

      // TFC doit s'appliquer : 96 + 22 = 118
      expect(result['tfc'], Decimal.parse('118'));
    });
  });

  // ═══════════════════════════════════════════════════════
  //  P5 : calculerRepartition
  // ═══════════════════════════════════════════════════════
  group('P5 — calculerRepartition', () {
    test('devrait retourner une map vide si CA = 0', () {
      final config = UrssafConfig(userId: 'u1');
      final result = config.calculerRepartition(
        Decimal.zero,
        Decimal.zero,
        Decimal.zero,
      );
      expect(result, isEmpty);
    });

    test('devrait ventiler les cotisations par branche pour BIC service', () {
      final config = UrssafConfig(userId: 'u1');
      final result = config.calculerRepartition(
        Decimal.zero, // caVente
        Decimal.parse('50000'), // caPrestaBIC
        Decimal.zero, // caPrestaBNC
      );

      expect(result.containsKey('maladie'), true);
      expect(result.containsKey('retraite_base'), true);
      expect(result.containsKey('retraite_complementaire'), true);
      expect(result.containsKey('invalidite_deces'), true);
      expect(result.containsKey('csg_crds'), true);
      expect(result.containsKey('cotisations_bnc'), false);

      // Maladie = 50000 * 2.13% = 1065
      expect(result['maladie'], Decimal.parse('1065'));
      // Retraite base = 50000 * 9.22% = 4610
      expect(result['retraite_base'], Decimal.parse('4610'));
    });

    test('devrait inclure cotisations_bnc si CA BNC > 0', () {
      final config = UrssafConfig(userId: 'u1');
      final result = config.calculerRepartition(
        Decimal.zero,
        Decimal.zero,
        Decimal.parse('30000'), // caPrestaBNC
      );

      expect(result.containsKey('cotisations_bnc'), true);
      // BNC = 30000 * 25.6% = 7680
      expect(result['cotisations_bnc'], Decimal.parse('7680'));
    });

    test('devrait combiner vente + BIC dans la sous-répartition', () {
      final config = UrssafConfig(userId: 'u1');
      final result = config.calculerRepartition(
        Decimal.parse('20000'), // caVente
        Decimal.parse('30000'), // caPrestaBIC
        Decimal.zero,
      );

      // Maladie = 30000*2.13% + 20000*1.24% = 639 + 248 = 887
      expect(result['maladie'], Decimal.parse('887'));
    });
  });

  // ═══════════════════════════════════════════════════════
  //  P3 : UrssafSyncService
  // ═══════════════════════════════════════════════════════
  group('P3 — UrssafSyncService', () {
    late MockHttpClient mockClient;
    late UrssafSyncService service;

    setUp(() {
      mockClient = MockHttpClient();
      service = UrssafSyncService(client: mockClient);
    });

    test('devrait retourner un UrssafSyncResult success si API OK', () async {
      // Préparer une réponse API simulée
      final apiResponse = {
        'evaluate': List.generate(23, (i) {
          switch (i) {
            case 0:
              return {'nodeValue': 12.3}; // taux vente
            case 1:
              return {'nodeValue': 21.2}; // taux BIC
            case 2:
              return {'nodeValue': 25.6}; // taux BNC
            case 5:
              return {'nodeValue': 0.48}; // TFC service
            case 6:
              return {'nodeValue': 0.22}; // TFC vente
            case 7:
              return {'nodeValue': 188700}; // plafond vente
            case 8:
              return {'nodeValue': 77700}; // plafond service
            case 9:
              return {'nodeValue': 29315}; // plafond VL RFR
            default:
              return {'nodeValue': null};
          }
        }),
      };

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(apiResponse),
            200,
          ));

      final config = UrssafConfig(
        userId: 'u1',
        statut: StatutEntrepreneur.artisan,
        typeActivite: TypeActiviteMicro.bicPrestation,
      );

      final result = await service.syncFromApi(config);

      expect(result.success, true);
      expect(result.config, isNotNull);
      expect(result.config!.sourceApi, true);
      expect(result.config!.lastSyncedAt, isNotNull);
      expect(result.config!.tauxMicroVente, Decimal.parse('12.3'));
      expect(result.config!.tauxMicroPrestationBIC, Decimal.parse('21.2'));
      expect(result.config!.tauxMicroPrestationBNC, Decimal.parse('25.6'));
      expect(result.config!.tauxTfcService, Decimal.parse('0.48'));
      expect(result.config!.tauxTfcVente, Decimal.parse('0.22'));
      expect(result.config!.plafondVlRfr, Decimal.parse('29315'));
    });

    test('devrait retourner erreur si HTTP != 200', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{}', 500));

      final config = UrssafConfig(userId: 'u1');
      final result = await service.syncFromApi(config);

      expect(result.success, false);
      expect(result.errorMessage, contains('500'));
    });

    test('devrait retourner erreur si situationError dans la réponse',
        () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'situationError': 'invalid rule', 'evaluate': []}),
            200,
          ));

      final config = UrssafConfig(userId: 'u1');
      final result = await service.syncFromApi(config);

      expect(result.success, false);
      expect(result.errorMessage, contains('situation'));
    });

    test('devrait retourner erreur en cas d\'exception réseau', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(Exception('Network unreachable'));

      final config = UrssafConfig(userId: 'u1');
      final result = await service.syncFromApi(config);

      expect(result.success, false);
      expect(result.errorMessage, contains('réseau'));
    });
  });

  // ═══════════════════════════════════════════════════════
  //  P6 : VlVsIrSimulation
  // ═══════════════════════════════════════════════════════
  group('P6 — VlVsIrSimulation', () {
    test('devrait calculer vlPlusAvantageux correctement', () {
      // Cas où VL est mieux
      final sim = VlVsIrSimulation(
        revenuNetSansVl: Decimal.parse('40000'),
        revenuNetApresIrSansVl: Decimal.parse('33000'),
        revenuImposableSansVl: Decimal.parse('35000'),
        revenuNetAvecVl: Decimal.parse('39000'),
        revenuNetApresIrAvecVl: Decimal.parse('35000'),
        montantVl: Decimal.parse('1500'),
        plafondVlRfr: Decimal.parse('29315'),
        caTotal: Decimal.parse('50000'),
      );

      expect(sim.vlPlusAvantageux, true);
      expect(sim.differenceAnnuelle, Decimal.parse('2000')); // 35000 - 33000
    });

    test('devrait calculer IR plus avantageux si VL désavantageux', () {
      final sim = VlVsIrSimulation(
        revenuNetSansVl: Decimal.parse('40000'),
        revenuNetApresIrSansVl: Decimal.parse('36000'),
        revenuImposableSansVl: Decimal.parse('35000'),
        revenuNetAvecVl: Decimal.parse('38000'),
        revenuNetApresIrAvecVl: Decimal.parse('34000'),
        montantVl: Decimal.parse('2500'),
        plafondVlRfr: Decimal.parse('29315'),
        caTotal: Decimal.parse('50000'),
      );

      expect(sim.vlPlusAvantageux, false);
      expect(sim.differenceAnnuelle, Decimal.parse('-2000'));
    });

    test('devrait calculer les taux effectifs', () {
      final sim = VlVsIrSimulation(
        revenuNetSansVl: Decimal.parse('40000'),
        revenuNetApresIrSansVl: Decimal.parse('35000'),
        revenuImposableSansVl: Decimal.parse('40000'),
        revenuNetAvecVl: Decimal.parse('39000'),
        revenuNetApresIrAvecVl: Decimal.parse('36000'),
        montantVl: Decimal.parse('1000'),
        plafondVlRfr: Decimal.parse('29315'),
        caTotal: Decimal.parse('50000'),
      );

      // Taux effectif VL = (50000-36000)/50000 * 100 = 28%
      expect(sim.tauxEffectifVl, Decimal.parse('28'));
      // Taux effectif IR = (50000-35000)/50000 * 100 = 30%
      expect(sim.tauxEffectifIr, Decimal.parse('30'));
    });

    test('devrait retourner 0 si CA = 0 pour les taux effectifs', () {
      final sim = VlVsIrSimulation(
        revenuNetSansVl: Decimal.zero,
        revenuNetApresIrSansVl: Decimal.zero,
        revenuImposableSansVl: Decimal.zero,
        revenuNetAvecVl: Decimal.zero,
        revenuNetApresIrAvecVl: Decimal.zero,
        montantVl: Decimal.zero,
        plafondVlRfr: Decimal.parse('29315'),
        caTotal: Decimal.zero,
      );

      expect(sim.tauxEffectifVl, Decimal.zero);
      expect(sim.tauxEffectifIr, Decimal.zero);
    });
  });

  // ═══════════════════════════════════════════════════════
  //  P4 : UrssafViewModel.syncFromApi
  // ═══════════════════════════════════════════════════════
  group('P4 — UrssafViewModel.syncFromApi', () {
    late MockUrssafRepository mockRepository;
    late MockHttpClient mockClient;
    late UrssafSyncService syncService;
    late UrssafViewModel viewModel;

    setUp(() {
      mockRepository = MockUrssafRepository();
      mockClient = MockHttpClient();
      syncService = UrssafSyncService(client: mockClient);
      viewModel = UrssafViewModel(
        repository: mockRepository,
        syncService: syncService,
      );
    });

    test('devrait synchroniser et sauvegarder la config', () async {
      // Setup : charger une config initiale
      final initialConfig = UrssafConfig(
        id: 'cfg-1',
        userId: 'user-1',
        statut: StatutEntrepreneur.artisan,
        typeActivite: TypeActiviteMicro.bicPrestation,
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => initialConfig);
      await viewModel.loadConfig();

      // Mock la réponse API
      final apiResponse = {
        'evaluate': List.generate(23, (i) {
          switch (i) {
            case 0:
              return {'nodeValue': 12.3};
            case 1:
              return {'nodeValue': 21.2};
            case 2:
              return {'nodeValue': 25.6};
            case 5:
              return {'nodeValue': 0.48};
            case 6:
              return {'nodeValue': 0.22};
            case 7:
              return {'nodeValue': 188700};
            case 8:
              return {'nodeValue': 77700};
            case 9:
              return {'nodeValue': 29315};
            default:
              return {'nodeValue': null};
          }
        }),
      };

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(apiResponse),
            200,
          ));

      when(() => mockRepository.saveConfig(any())).thenAnswer((_) async {});

      // ACT
      final success = await viewModel.syncFromApi();

      // ASSERT
      expect(success, true);
      expect(viewModel.config!.sourceApi, true);
      expect(viewModel.syncMessage, 'Taux synchronisés avec succès');
      verify(() => mockRepository.saveConfig(any())).called(1);
    });

    test('devrait retourner false si pas de config chargée', () async {
      // Pas de loadConfig() appelé → _config est null
      final success = await viewModel.syncFromApi();
      expect(success, false);
    });

    test('devrait gérer l\'échec API gracieusement', () async {
      final initialConfig = UrssafConfig(
        id: 'cfg-1',
        userId: 'user-1',
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => initialConfig);
      await viewModel.loadConfig();

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{}', 500));

      // ACT
      final success = await viewModel.syncFromApi();

      // ASSERT
      expect(success, false);
      expect(viewModel.syncMessage, contains('Erreur API'));
      expect(viewModel.isLoading, false);
    });
  });

  // ═══════════════════════════════════════════════════════
  //  Constantes standard (valeurs corrigées post-audit)
  // ═══════════════════════════════════════════════════════
  group('Constantes standard post-audit', () {
    test('BNC = 25.6% (corrigé depuis 24.6%)', () {
      expect(UrssafConfig.standardTauxMicroBNC, Decimal.parse('25.6'));
    });

    test('TFC service = 0.48%, vente = 0.22%', () {
      expect(UrssafConfig.standardTauxTfcService, Decimal.parse('0.48'));
      expect(UrssafConfig.standardTauxTfcVente, Decimal.parse('0.22'));
    });

    test('Plafond VL RFR = 29315', () {
      expect(UrssafConfig.standardPlafondVlRfr, Decimal.parse('29315'));
    });
  });

  // ═══════════════════════════════════════════════════════
  //  ACRE — réduction 50% cotisations sociales
  // ═══════════════════════════════════════════════════════
  group('ACRE — réduction 50% cotisations sociales', () {
    test('devrait réduire de 50% les cotisations sociales avec ACRE actif', () {
      final configSansAcre = UrssafConfig(userId: 'u1', accreActive: false);
      final configAvecAcre = UrssafConfig(userId: 'u1', accreActive: true);

      final ca = Decimal.parse('50000');

      final resultSans =
          configSansAcre.calculerCotisations(Decimal.zero, ca, Decimal.zero);
      final resultAvec =
          configAvecAcre.calculerCotisations(Decimal.zero, ca, Decimal.zero);

      // Social devrait être divisé par 2
      expect(
          resultAvec['social'], resultSans['social']! * Decimal.parse('0.5'));
      // CFP ne doit PAS changer
      expect(resultAvec['cfp'], resultSans['cfp']);
      // TFC ne doit PAS changer
      expect(resultAvec['tfc'], resultSans['tfc']);
    });

    test('ACRE ne devrait PAS affecter le versement libératoire', () {
      final configAvecAcre = UrssafConfig(
        userId: 'u1',
        accreActive: true,
        versementLiberatoire: true,
      );
      final configSansAcre = UrssafConfig(
        userId: 'u1',
        accreActive: false,
        versementLiberatoire: true,
      );

      final ca = Decimal.parse('50000');

      final resAvec =
          configAvecAcre.calculerCotisations(ca, Decimal.zero, Decimal.zero);
      final resSans =
          configSansAcre.calculerCotisations(ca, Decimal.zero, Decimal.zero);

      expect(resAvec['liberatoire'], resSans['liberatoire']);
    });

    test('ACRE devrait réduire la sous-répartition (maladie, retraite, etc.)',
        () {
      final configSans = UrssafConfig(userId: 'u1', accreActive: false);
      final configAvec = UrssafConfig(userId: 'u1', accreActive: true);

      final ca = Decimal.parse('60000');

      final repSans =
          configSans.calculerRepartition(Decimal.zero, ca, Decimal.zero);
      final repAvec =
          configAvec.calculerRepartition(Decimal.zero, ca, Decimal.zero);

      expect(repAvec['maladie'], repSans['maladie']! * Decimal.parse('0.5'));
      expect(repAvec['retraite_base'],
          repSans['retraite_base']! * Decimal.parse('0.5'));
    });

    test('ACRE désactivé ne change rien aux calculs', () {
      final config = UrssafConfig(userId: 'u1', accreActive: false);

      final ca = Decimal.parse('80000');
      final result = config.calculerCotisations(ca, Decimal.zero, Decimal.zero);

      // Social = 80000 * 12.3% = 9840
      expect(result['social'], Decimal.parse('9840'));
    });

    test('ACRE avec activité mixte réduit vente ET prestation', () {
      final config = UrssafConfig(userId: 'u1', accreActive: true);

      final caVente = Decimal.parse('30000');
      final caBIC = Decimal.parse('50000');

      final result = config.calculerCotisations(caVente, caBIC, Decimal.zero);

      // Sans ACRE : social = 30000*12.3% + 50000*21.2% = 3690 + 10600 = 14290
      // Avec ACRE : 14290 * 0.5 = 7145
      expect(result['social'], Decimal.parse('7145'));
    });
  });
}
