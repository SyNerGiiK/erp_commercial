import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/models/client_model.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/paiement_model.dart';
import 'package:erp_commercial/models/chiffrage_model.dart';

/// Tests d'intégration pour les workflows métier complets
/// Ces tests valident les scénarios bout-en-bout sans dépendre de Supabase
void main() {
  group('Workflow Intégration - Devis → Facture → Paiement', () {
    late Client testClient;
    late Devis testDevis;

    setUp(() {
      // Créer un client de test
      testClient = Client(
        id: 'client-test-001',
        nomComplet: 'Entreprise Test SARL',
        typeClient: 'professionnel',
        siret: '12345678901234',
        tvaIntra: 'FR12345678901',
        adresse: '123 Rue du Test',
        codePostal: '75001',
        ville: 'Paris',
        telephone: '0123456789',
        email: 'contact@test.com',
      );

      // Créer un devis de test avec lignes et chiffrage
      testDevis = Devis(
        id: 'devis-test-001',
        numeroDevis: 'DEV-2026-001',
        objet: 'Travaux de rénovation complète',
        clientId: testClient.id!,
        dateEmission: DateTime(2026, 2, 1),
        dateValidite: DateTime(2026, 3, 1),
        statut: 'finalisé',
        totalHt: Decimal.parse('10000'),
        totalTva: Decimal.parse('2000'),
        totalTtc: Decimal.parse('12000'),
        remiseTaux: Decimal.parse('5'),
        acompteMontant: Decimal.parse('3000'),
        conditionsReglement: 'Acompte de 30% à la commande, solde à 30 jours',
        lignes: [
          LigneDevis(
            id: 'ligne-1',
            description: 'Peinture intérieure',
            quantite: Decimal.parse('100'),
            prixUnitaire: Decimal.parse('50'),
            totalLigne: Decimal.parse('5000'),
            typeActivite: 'service',
            unite: 'm²',
            tauxTva: Decimal.parse('20'),
          ),
          LigneDevis(
            id: 'ligne-2',
            description: 'Fourniture parquet',
            quantite: Decimal.parse('50'),
            prixUnitaire: Decimal.parse('100'),
            totalLigne: Decimal.parse('5000'),
            typeActivite: 'vente',
            unite: 'm²',
            tauxTva: Decimal.parse('20'),
          ),
        ],
        chiffrage: [
          LigneChiffrage(
            designation: 'Peinture (achat)',
            quantite: Decimal.parse('50'),
            unite: 'L',
            prixAchatUnitaire: Decimal.parse('15'),
            prixVenteUnitaire: Decimal.parse('30'),
          ),
          LigneChiffrage(
            designation: 'Parquet (achat)',
            quantite: Decimal.parse('50'),
            unite: 'm²',
            prixAchatUnitaire: Decimal.parse('60'),
            prixVenteUnitaire: Decimal.parse('100'),
          ),
        ],
      );
    });

    test('Scénario 1: Calcul de rentabilité du devis', () {
      // Vérifier les calculs de rentabilité
      expect(testDevis.totalHt, Decimal.parse('10000'));

      // Total achats = (50 * 15) + (50 * 60) = 750 + 3000 = 3750
      expect(testDevis.totalAchats, Decimal.parse('3750'));

      // Marge brute = 10000 - 3750 = 6250
      expect(testDevis.margeBrute, Decimal.parse('6250'));

      // Taux marge = (6250 / 10000) * 100 = 62.5%
      expect(testDevis.tauxMargeBrute.toDouble(), closeTo(62.5, 0.01));

      // Net commercial = 10000 - (10000 * 5 / 100) = 9500
      expect(testDevis.netCommercial, Decimal.parse('9500'));
    });

    test('Scénario 2: Transformation Devis → Facture d\'acompte', () {
      // Créer une facture d'acompte depuis le devis
      final factureAcompte = Facture(
        id: 'facture-acompte-001',
        numeroFacture: 'FACT-2026-001',
        objet: testDevis.objet,
        clientId: testDevis.clientId,
        devisSourceId: testDevis.id, // Lien vers le devis source
        dateEmission: DateTime(2026, 2, 5),
        dateEcheance: DateTime(2026, 2, 5), // Payable immédiatement
        type: 'acompte',
        statut: 'validée',
        statutJuridique: 'validée',
        // Facture d'acompte de 30%
        totalHt: Decimal.parse('2500'), // 3000 / 1.20
        totalTva: Decimal.parse('500'), // 20% de 2500
        totalTtc: testDevis.acompteMontant, // 3000€
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        lignes: [
          LigneFacture(
            description: 'Acompte de 30% sur devis ${testDevis.numeroDevis}',
            quantite: Decimal.one,
            prixUnitaire: Decimal.parse('2500'), // HT
            totalLigne: Decimal.parse('2500'),
            typeActivite: 'service',
            tauxTva: Decimal.parse('20'),
          ),
        ],
      );

      // Vérifications
      expect(factureAcompte.type, 'acompte');
      expect(factureAcompte.devisSourceId, testDevis.id);
      expect(factureAcompte.totalTtc, Decimal.parse('3000'));
      expect(factureAcompte.estSoldee, false); // Pas de paiement
      expect(factureAcompte.netAPayer, Decimal.parse('3000'));
    });

    test(
        'Scénario 3: Workflow complet - Devis → Facture acompte → Paiement → Facture solde → Paiement final',
        () {
      // ÉTAPE 1: Facture d'acompte
      final factureAcompte = Facture(
        id: 'facture-acompte-001',
        numeroFacture: 'FACT-2026-001',
        objet: testDevis.objet,
        clientId: testDevis.clientId,
        devisSourceId: testDevis.id,
        dateEmission: DateTime(2026, 2, 5),
        dateEcheance: DateTime(2026, 2, 5),
        type: 'acompte',
        totalHt: Decimal.parse('2500'),
        totalTva: Decimal.parse('500'),
        totalTtc: Decimal.parse('3000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        lignes: [
          LigneFacture(
            description: 'Acompte 30%',
            quantite: Decimal.one,
            prixUnitaire: Decimal.parse('2500'),
            totalLigne: Decimal.parse('2500'),
            tauxTva: Decimal.parse('20'),
          ),
        ],
      );

      expect(factureAcompte.netAPayer, Decimal.parse('3000'));
      expect(factureAcompte.estSoldee, false);

      // ÉTAPE 2: Paiement de l'acompte
      final paiementAcompte = Paiement(
        id: 'paiement-001',
        factureId: factureAcompte.id!,
        montant: Decimal.parse('3000'),
        datePaiement: DateTime(2026, 2, 6),
        typePaiement: 'virement',
        commentaire: 'Acompte 30% reçu',
        isAcompte: true,
      );

      // Facture avec paiement
      final factureAcomptePayee = factureAcompte.copyWith(
        paiements: [paiementAcompte],
      );

      expect(factureAcomptePayee.totalPaiements, Decimal.parse('3000'));
      expect(factureAcomptePayee.netAPayer, Decimal.zero);
      expect(factureAcomptePayee.estSoldee, true); // ✅ Acompte soldé

      // ÉTAPE 3: Facture de solde (après travaux terminés)
      final factureSolde = Facture(
        id: 'facture-solde-001',
        numeroFacture: 'FACT-2026-002',
        objet: testDevis.objet,
        clientId: testDevis.clientId,
        devisSourceId: testDevis.id,
        factureSourceId: factureAcompte.id, // Lien vers facture d'acompte
        dateEmission: DateTime(2026, 3, 1),
        dateEcheance: DateTime(2026, 3, 31),
        type: 'solde',
        totalHt: testDevis.totalHt,
        totalTva: testDevis.totalTva,
        totalTtc: testDevis.totalTtc,
        remiseTaux: testDevis.remiseTaux,
        acompteDejaRegle: Decimal.parse('3000'), // Acompte déjà payé
        lignes: testDevis.lignes
            .map((ligneDevis) => LigneFacture(
                  description: ligneDevis.description,
                  quantite: ligneDevis.quantite,
                  prixUnitaire: ligneDevis.prixUnitaire,
                  totalLigne: ligneDevis.totalLigne,
                  typeActivite: ligneDevis.typeActivite,
                  unite: ligneDevis.unite,
                  tauxTva: ligneDevis.tauxTva,
                ))
            .toList(),
      );

      // Net à payer sur facture solde = 12000 (TTC) - 3000 (acompte) = 9000
      expect(factureSolde.totalTtc, Decimal.parse('12000'));
      expect(factureSolde.acompteDejaRegle, Decimal.parse('3000'));
      expect(factureSolde.netAPayer, Decimal.parse('9000'));
      expect(factureSolde.estSoldee, false);

      // ÉTAPE 4: Paiement partiel du solde (5000€)
      final paiementPartiel = Paiement(
        id: 'paiement-002',
        factureId: factureSolde.id!,
        montant: Decimal.parse('5000'),
        datePaiement: DateTime(2026, 3, 15),
        typePaiement: 'cheque',
        commentaire: 'Paiement partiel',
      );

      final factureSoldePartielle = factureSolde.copyWith(
        paiements: [paiementPartiel],
      );

      // Reste à payer = 9000 - 5000 = 4000
      expect(factureSoldePartielle.netAPayer, Decimal.parse('4000'));
      expect(factureSoldePartielle.estSoldee, false);

      // ÉTAPE 5: Paiement final du solde (4000€)
      final paiementFinal = Paiement(
        id: 'paiement-003',
        factureId: factureSolde.id!,
        montant: Decimal.parse('4000'),
        datePaiement: DateTime(2026, 3, 31),
        typePaiement: 'virement',
        commentaire: 'Solde final',
      );

      final factureSoldeeComplete = factureSolde.copyWith(
        paiements: [paiementPartiel, paiementFinal],
      );

      // Total paiements = 5000 + 4000 = 9000
      expect(factureSoldeeComplete.totalPaiements, Decimal.parse('9000'));
      expect(factureSoldeeComplete.netAPayer, Decimal.zero);
      expect(
          factureSoldeeComplete.estSoldee, true); // ✅ Projet complètement soldé

      // VÉRIFICATION FINALE DU WORKFLOW COMPLET
      // Total facturé = Acompte (3000) + Solde net à payer (9000) = 12000
      final totalFacture = factureAcomptePayee.totalTtc +
          factureSoldeeComplete.netAPayer +
          factureSoldeeComplete.totalPaiements;
      expect(totalFacture, testDevis.totalTtc); // Correspond au devis initial ✅
    });

    test('Scénario 4: Facture de situation (avancement progressif)', () {
      // SITUATION 1: 30% des travaux (mois 1)
      final factureSituation1 = Facture(
        id: 'facture-sit-001',
        numeroFacture: 'FACT-SIT-2026-001',
        objet: '${testDevis.objet} - Situation 1',
        clientId: testDevis.clientId,
        devisSourceId: testDevis.id,
        dateEmission: DateTime(2026, 2, 15),
        dateEcheance: DateTime(2026, 3, 15),
        type: 'situation',
        avancementGlobal: Decimal.parse('30'),
        totalHt:
            (testDevis.totalHt * Decimal.parse('30') / Decimal.fromInt(100))
                .toDecimal(),
        totalTva:
            (testDevis.totalTva * Decimal.parse('30') / Decimal.fromInt(100))
                .toDecimal(),
        totalTtc:
            (testDevis.totalTtc * Decimal.parse('30') / Decimal.fromInt(100))
                .toDecimal(),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        lignes: testDevis.lignes
            .map((ligne) => LigneFacture(
                  description: ligne.description,
                  quantite: ligne.quantite,
                  prixUnitaire: ligne.prixUnitaire,
                  totalLigne: ligne.totalLigne,
                  typeActivite: ligne.typeActivite,
                  unite: ligne.unite,
                  avancement: Decimal.parse('30'), // 30% de chaque ligne
                  tauxTva: ligne.tauxTva,
                ))
            .toList(),
      );

      // Montant situation 1 = 12000 * 30% = 3600€
      expect(factureSituation1.totalTtc, Decimal.parse('3600'));
      expect(factureSituation1.avancementGlobal, Decimal.parse('30'));

      // SITUATION 2: 70% des travaux (mois 2) - cumul à déduire
      final factureSituation2 = Facture(
        id: 'facture-sit-002',
        numeroFacture: 'FACT-SIT-2026-002',
        objet: '${testDevis.objet} - Situation 2',
        clientId: testDevis.clientId,
        devisSourceId: testDevis.id,
        dateEmission: DateTime(2026, 3, 15),
        dateEcheance: DateTime(2026, 4, 15),
        type: 'situation',
        avancementGlobal: Decimal.parse('70'),
        totalHt:
            (testDevis.totalHt * Decimal.parse('70') / Decimal.fromInt(100))
                .toDecimal(),
        totalTva:
            (testDevis.totalTva * Decimal.parse('70') / Decimal.fromInt(100))
                .toDecimal(),
        totalTtc:
            (testDevis.totalTtc * Decimal.parse('70') / Decimal.fromInt(100))
                .toDecimal(),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: factureSituation1.totalTtc, // Déduire situation 1
        lignes: testDevis.lignes
            .map((ligne) => LigneFacture(
                  description: ligne.description,
                  quantite: ligne.quantite,
                  prixUnitaire: ligne.prixUnitaire,
                  totalLigne: ligne.totalLigne,
                  typeActivite: ligne.typeActivite,
                  unite: ligne.unite,
                  avancement: Decimal.parse('70'),
                  tauxTva: ligne.tauxTva,
                ))
            .toList(),
      );

      // Montant brut situation 2 = 12000 * 70% = 8400€
      // À déduire situation 1 = 3600€
      // Net à payer = 8400 - 3600 = 4800€
      expect(factureSituation2.totalTtc, Decimal.parse('8400'));
      expect(factureSituation2.acompteDejaRegle, Decimal.parse('3600'));
      expect(factureSituation2.netAPayer, Decimal.parse('4800'));
    });
  });
}
