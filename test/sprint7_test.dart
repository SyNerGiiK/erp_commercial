import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/utils/validation_utils.dart';
import 'package:erp_commercial/models/entreprise_model.dart';
import 'package:erp_commercial/models/enums/entreprise_enums.dart';
import 'package:erp_commercial/viewmodels/entreprise_viewmodel.dart';
import 'mocks/repository_mocks.dart';

/// Tests Sprint 7 — Validation Luhn SIRET, modèle ProfilEntreprise complet,
/// mentions légales auto-générées.
void main() {
  // ════════════════════════════════════════════════════════════════════════
  // 1. VALIDATION LUHN SIRET
  // ════════════════════════════════════════════════════════════════════════

  group('Validation SIRET — Luhn', () {
    test('null et vide sont optionnels', () {
      expect(ValidationUtils.validateSiret(null), isNull);
      expect(ValidationUtils.validateSiret(''), isNull);
      expect(ValidationUtils.validateSiret('   '), isNull);
    });

    test('rejette format non numérique ou longueur incorrecte', () {
      expect(ValidationUtils.validateSiret('abc'), isNotNull);
      expect(ValidationUtils.validateSiret('1234'), isNotNull);
      expect(ValidationUtils.validateSiret('123456789012345'), isNotNull);
    });

    test('accepte SIRET 14 chiffres valide Luhn', () {
      // 44306184100047 — Luhn sum = 50
      expect(ValidationUtils.validateSiret('44306184100047'), isNull);
      // 32105077000015 — Luhn sum = 30
      expect(ValidationUtils.validateSiret('32105077000015'), isNull);
    });

    test('accepte SIRET avec espaces (nettoyé → valide Luhn)', () {
      expect(ValidationUtils.validateSiret('443 061 841 00047'), isNull);
      expect(ValidationUtils.validateSiret('321 050 770 00015'), isNull);
    });

    test('rejette SIRET 14 chiffres échouant Luhn', () {
      expect(ValidationUtils.validateSiret('12345678901234'), isNotNull);
      expect(ValidationUtils.validateSiret('11111111111111'), isNotNull);
      expect(ValidationUtils.validateSiret('99999999999999'), isNotNull);
    });

    test('accepte SIRET La Poste (SIREN 356000000, somme % 5 = 0)', () {
      // 35600000049837 : somme = 3+5+6+0+0+0+0+0+0+4+9+8+3+7 = 45
      expect(ValidationUtils.validateSiret('35600000049837'), isNull);
    });

    test('rejette SIRET La Poste avec somme non divisible par 5', () {
      // 35600000012345 : somme = 29 → 29 % 5 = 4
      expect(ValidationUtils.validateSiret('35600000012345'), isNotNull);
    });

    test('00000000000000 est techniquement valide Luhn (cas limite)', () {
      expect(ValidationUtils.validateSiret('00000000000000'), isNull);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // 2. MODÈLE ProfilEntreprise — CHAMPS COMPLETS
  // ════════════════════════════════════════════════════════════════════════

  group('ProfilEntreprise — champs complets', () {
    test('construction avec tous les champs explicites', () {
      final profil = ProfilEntreprise(
        nomEntreprise: 'Test SARL',
        nomGerant: 'Alice Martin',
        adresse: '12 rue des Lilas',
        codePostal: '69001',
        ville: 'Lyon',
        siret: '44306184100047',
        email: 'alice@test.fr',
        tvaApplicable: true,
        numeroTvaIntra: 'FR12345678901',
        pdfTheme: PdfTheme.classique,
        modeFacturation: ModeFacturation.detaille,
        modeDiscret: true,
        tauxPenalitesRetard: 15.0,
        escompteApplicable: true,
        estImmatricule: true,
      );

      expect(profil.tvaApplicable, isTrue);
      expect(profil.numeroTvaIntra, 'FR12345678901');
      expect(profil.pdfTheme, PdfTheme.classique);
      expect(profil.modeFacturation, ModeFacturation.detaille);
      expect(profil.modeDiscret, isTrue);
      expect(profil.tauxPenalitesRetard, 15.0);
      expect(profil.escompteApplicable, isTrue);
      expect(profil.estImmatricule, isTrue);
    });

    test('valeurs par défaut cohérentes pour micro-entrepreneur', () {
      final profil = ProfilEntreprise(
        nomEntreprise: 'Artisan Test',
        nomGerant: 'Bob',
        adresse: '1 rue',
        codePostal: '75001',
        ville: 'Paris',
        siret: '32105077000015',
        email: 'bob@test.fr',
      );

      expect(profil.tvaApplicable, isFalse);
      expect(profil.numeroTvaIntra, isNull);
      expect(profil.pdfTheme, PdfTheme.moderne);
      expect(profil.modeFacturation, ModeFacturation.global);
      expect(profil.modeDiscret, isFalse);
      expect(profil.tauxPenalitesRetard, 11.62);
      expect(profil.escompteApplicable, isFalse);
      expect(profil.estImmatricule, isFalse);
      expect(profil.typeEntreprise, TypeEntreprise.microEntrepreneur);
    });

    test('toMap / fromMap round-trip préserve tous les champs', () {
      final original = ProfilEntreprise(
        id: 'test-id',
        userId: 'user-1',
        nomEntreprise: 'Round Trip SARL',
        nomGerant: 'Charlie',
        adresse: '5 avenue du Parc',
        codePostal: '33000',
        ville: 'Bordeaux',
        siret: '44306184100047',
        email: 'charlie@round.fr',
        telephone: '0612345678',
        iban: 'FR7630001007941234567890185',
        bic: 'BNPAFRPP',
        tvaApplicable: true,
        numeroTvaIntra: 'FR99123456789',
        pdfTheme: PdfTheme.minimaliste,
        modeFacturation: ModeFacturation.detaille,
        modeDiscret: true,
        tauxPenalitesRetard: 12.5,
        escompteApplicable: true,
        estImmatricule: true,
        mentionsLegales: 'Mentions custom',
      );

      final map = original.toMap();
      final restored = ProfilEntreprise.fromMap(map);

      expect(restored.tvaApplicable, original.tvaApplicable);
      expect(restored.numeroTvaIntra, original.numeroTvaIntra);
      expect(restored.pdfTheme, original.pdfTheme);
      expect(restored.modeFacturation, original.modeFacturation);
      expect(restored.modeDiscret, original.modeDiscret);
      expect(restored.tauxPenalitesRetard, original.tauxPenalitesRetard);
      expect(restored.escompteApplicable, original.escompteApplicable);
      expect(restored.estImmatricule, original.estImmatricule);
      expect(restored.mentionsLegales, original.mentionsLegales);
    });

    test('copyWith préserve les champs non modifiés', () {
      final base = ProfilEntreprise(
        nomEntreprise: 'Base',
        nomGerant: 'Gérant',
        adresse: 'Addr',
        codePostal: '75001',
        ville: 'Paris',
        siret: '44306184100047',
        email: 'base@test.fr',
        tvaApplicable: false,
        pdfTheme: PdfTheme.moderne,
        tauxPenalitesRetard: 11.62,
      );

      final updated = base.copyWith(tvaApplicable: true);

      expect(updated.tvaApplicable, isTrue);
      expect(updated.nomEntreprise, 'Base'); // inchangé
      expect(updated.pdfTheme, PdfTheme.moderne); // inchangé
      expect(updated.tauxPenalitesRetard, 11.62); // inchangé
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // 3. MENTIONS LÉGALES AUTO-GÉNÉRÉES
  // ════════════════════════════════════════════════════════════════════════

  group('Mentions légales — getLegalMentionsSuggestion', () {
    late EntrepriseViewModel vm;

    setUp(() {
      vm = EntrepriseViewModel(repository: MockEntrepriseRepository());
    });

    test('micro non TVA non immatriculé → 2 mentions', () {
      final result = vm.getLegalMentionsSuggestion(
        TypeEntreprise.microEntrepreneur,
        tvaApplicable: false,
        estImmatricule: false,
      );
      expect(result, contains('TVA non applicable'));
      expect(result, contains('art. 293 B'));
      expect(result, contains("Dispensé d'immatriculation"));
    });

    test('micro assujetti TVA → pas de mention art. 293 B', () {
      final result = vm.getLegalMentionsSuggestion(
        TypeEntreprise.microEntrepreneur,
        tvaApplicable: true,
        estImmatricule: false,
      );
      expect(result, isNot(contains('TVA non applicable')));
      expect(result, contains("Dispensé d'immatriculation"));
    });

    test('micro immatriculé → pas de mention dispensé', () {
      final result = vm.getLegalMentionsSuggestion(
        TypeEntreprise.microEntrepreneur,
        tvaApplicable: false,
        estImmatricule: true,
      );
      expect(result, contains('TVA non applicable'));
      expect(result, isNot(contains("Dispensé d'immatriculation")));
    });

    test('SASU → aucune mention micro', () {
      final result = vm.getLegalMentionsSuggestion(
        TypeEntreprise.sasu,
        tvaApplicable: true,
        estImmatricule: true,
      );
      expect(result, isEmpty);
    });

    test('micro non TVA + immatriculé → une seule mention', () {
      final result = vm.getLegalMentionsSuggestion(
        TypeEntreprise.microEntrepreneur,
        tvaApplicable: false,
        estImmatricule: true,
      );
      expect(result, contains('TVA non applicable'));
      expect(result, isNot(contains("Dispensé")));
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // 4. ENUMS — couverture
  // ════════════════════════════════════════════════════════════════════════

  group('Enums entreprise', () {
    test('PdfTheme a label + description pour chaque valeur', () {
      for (final theme in PdfTheme.values) {
        expect(theme.label, isNotEmpty);
        expect(theme.description, isNotEmpty);
      }
    });

    test('ModeFacturation a label + description', () {
      for (final mode in ModeFacturation.values) {
        expect(mode.label, isNotEmpty);
        expect(mode.description, isNotEmpty);
      }
    });

    test('TypeEntreprise.isMicroEntrepreneur correct', () {
      expect(TypeEntreprise.microEntrepreneur.isMicroEntrepreneur, isTrue);
      expect(TypeEntreprise.sasu.isMicroEntrepreneur, isFalse);
      expect(TypeEntreprise.eurl.isMicroEntrepreneur, isFalse);
      expect(TypeEntreprise.autre.isMicroEntrepreneur, isFalse);
    });

    test('TypeEntreprise.isTNS correct', () {
      expect(TypeEntreprise.entrepriseIndividuelle.isTNS, isTrue);
      expect(TypeEntreprise.eurl.isTNS, isTrue);
      expect(TypeEntreprise.sasu.isTNS, isFalse);
    });

    test('TypeEntreprise.isAssimileSalarie correct', () {
      expect(TypeEntreprise.sasu.isAssimileSalarie, isTrue);
      expect(TypeEntreprise.sas.isAssimileSalarie, isTrue);
      expect(TypeEntreprise.eurl.isAssimileSalarie, isFalse);
    });
  });
}
