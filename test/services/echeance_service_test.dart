import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/services/echeance_service.dart';
import 'package:erp_commercial/models/rappel_model.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/enums/entreprise_enums.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('EcheanceService - génération complète', () {
    test('devrait générer des rappels sans factures ni devis', () {
      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: [],
        urssafTrimestriel: false,
        tvaApplicable: true,
      );

      // Au minimum : URSSAF (12 mensuels) + CFE (1) + Impôts (1) + TVA (4) = 18
      expect(rappels.length, greaterThanOrEqualTo(18));
    });

    test('devrait générer des rappels URSSAF mensuels par défaut', () {
      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: [],
        urssafTrimestriel: false,
        tvaApplicable: true,
      );

      final urssaf =
          rappels.where((r) => r.typeRappel == TypeRappel.urssaf).toList();
      expect(urssaf.length, 12); // mensuel par défaut
    });

    test('devrait générer des rappels URSSAF trimestriels si spécifié', () {
      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: [],
        urssafTrimestriel: true,
        tvaApplicable: true,
      );

      final urssaf =
          rappels.where((r) => r.typeRappel == TypeRappel.urssaf).toList();
      expect(urssaf.length, 4);
    });

    test('devrait inclure un rappel CFE au 15 décembre', () {
      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: [],
        urssafTrimestriel: false,
        tvaApplicable: true,
      );

      final cfe = rappels.where((r) => r.typeRappel == TypeRappel.cfe).toList();
      expect(cfe, hasLength(1));
      expect(cfe[0].dateEcheance.month, 12);
      expect(cfe[0].dateEcheance.day, 15);
    });

    test('devrait inclure un rappel impôts au 8 juin', () {
      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: [],
        urssafTrimestriel: false,
        tvaApplicable: true,
      );

      final impots =
          rappels.where((r) => r.typeRappel == TypeRappel.impots).toList();
      expect(impots, hasLength(1));
      expect(impots[0].dateEcheance.month, 6);
      expect(impots[0].dateEcheance.day, 8);
    });

    test('devrait inclure 4 rappels TVA trimestriels', () {
      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: [],
        urssafTrimestriel: false,
        tvaApplicable: true,
      );

      final tva = rappels.where((r) => r.typeRappel == TypeRappel.tva).toList();
      expect(tva, hasLength(4));
    });
  });

  group('EcheanceService - rappels factures', () {
    test('devrait générer des rappels pour factures non soldées échues', () {
      final factures = [
        Facture(
          id: 'f1',
          objet: 'Facture test',
          clientId: 'c1',
          dateEmission: DateTime.now().subtract(const Duration(days: 60)),
          dateEcheance: DateTime.now().subtract(const Duration(days: 30)),
          totalHt: Decimal.fromInt(1000),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statutJuridique: 'validee',
          statut: 'envoyee',
          numeroFacture: 'F-2026-001',
        ),
      ];

      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: factures,
        devis: [],
        urssafTrimestriel: false,
        tvaApplicable: false,
      );

      final factureRappels = rappels
          .where((r) => r.typeRappel == TypeRappel.echeanceFacture)
          .toList();
      expect(factureRappels, hasLength(1));
      expect(factureRappels[0].priorite, PrioriteRappel.urgente);
    });

    test('ne devrait pas générer de rappel pour factures soldées', () {
      final factures = [
        Facture(
          id: 'f1',
          objet: 'Facture soldée',
          clientId: 'c1',
          dateEmission: DateTime.now().subtract(const Duration(days: 60)),
          dateEcheance: DateTime.now().subtract(const Duration(days: 30)),
          totalHt: Decimal.fromInt(1000),
          totalTtc: Decimal.fromInt(1000),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.fromInt(1000),
          statutJuridique: 'validee',
          statut: 'payee',
        ),
      ];

      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: factures,
        devis: [],
        urssafTrimestriel: false,
        tvaApplicable: false,
      );

      final factureRappels = rappels
          .where((r) => r.typeRappel == TypeRappel.echeanceFacture)
          .toList();
      expect(factureRappels, isEmpty);
    });
  });

  group('EcheanceService - rappels devis', () {
    test('devrait générer des rappels pour devis expirant bientôt', () {
      final devis = [
        Devis(
          id: 'd1',
          objet: 'Devis test',
          clientId: 'c1',
          dateEmission: DateTime.now().subtract(const Duration(days: 25)),
          dateValidite: DateTime.now().add(const Duration(days: 5)),
          totalHt: Decimal.fromInt(5000),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'envoye',
          numeroDevis: 'D-2026-001',
        ),
      ];

      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: devis,
        urssafTrimestriel: false,
        tvaApplicable: false,
      );

      final devisRappels =
          rappels.where((r) => r.typeRappel == TypeRappel.finDevis).toList();
      expect(devisRappels, hasLength(1));
    });

    test('ne devrait pas générer de rappel pour devis signés', () {
      final devis = [
        Devis(
          id: 'd1',
          objet: 'Devis signé',
          clientId: 'c1',
          dateEmission: DateTime.now().subtract(const Duration(days: 25)),
          dateValidite: DateTime.now().add(const Duration(days: 5)),
          totalHt: Decimal.fromInt(5000),
          remiseTaux: Decimal.zero,
          acompteMontant: Decimal.zero,
          statut: 'signe',
          numeroDevis: 'D-2026-002',
        ),
      ];

      final rappels = EcheanceService.genererTousRappels(
        annee: 2026,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: devis,
        urssafTrimestriel: false,
        tvaApplicable: false,
      );

      final devisRappels =
          rappels.where((r) => r.typeRappel == TypeRappel.finDevis).toList();
      expect(devisRappels, isEmpty);
    });
  });

  group('EcheanceService - année', () {
    test('devrait générer pour l\'année spécifiée', () {
      final rappels = EcheanceService.genererTousRappels(
        annee: 2027,
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        factures: [],
        devis: [],
        urssafTrimestriel: false,
        tvaApplicable: true,
      );

      // Les rappels URSSAF sont en 2027 sauf décembre (M+1 → janvier 2028)
      final urssaf =
          rappels.where((r) => r.typeRappel == TypeRappel.urssaf).toList();
      for (final r in urssaf) {
        expect(r.dateEcheance.year, anyOf(2027, 2028));
      }
    });
  });
}
