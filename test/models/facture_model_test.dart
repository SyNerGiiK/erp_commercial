import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/paiement_model.dart';
import 'package:erp_commercial/models/chiffrage_model.dart';

void main() {
  group('LigneFacture - fromMap / toMap', () {
    test('crée une LigneFacture depuis une Map complète', () {
      final map = {
        'id': 'ligne-123',
        'description': 'Prestation maintenance',
        'quantite': '5',
        'prix_unitaire': '120.50',
        'total_ligne': '602.50',
        'type_activite': 'service',
        'unite': 'h',
        'type': 'article',
        'ordre': 1,
        'est_gras': false,
        'est_italique': true,
        'est_souligne': false,
        'avancement': '50',
        'taux_tva': '20',
      };

      final ligne = LigneFacture.fromMap(map);

      expect(ligne.id, 'ligne-123');
      expect(ligne.description, 'Prestation maintenance');
      expect(ligne.quantite, Decimal.parse('5'));
      expect(ligne.prixUnitaire, Decimal.parse('120.50'));
      expect(ligne.totalLigne, Decimal.parse('602.50'));
      expect(ligne.typeActivite, 'service');
      expect(ligne.unite, 'h');
      expect(ligne.ordre, 1);
      expect(ligne.estItalique, true);
      expect(ligne.avancement, Decimal.parse('50'));
      expect(ligne.tauxTva, Decimal.parse('20'));
    });

    test('calcule montantTva correctement', () {
      final ligne = LigneFacture(
        description: 'Test TVA',
        quantite: Decimal.one,
        prixUnitaire: Decimal.parse('100'),
        totalLigne: Decimal.parse('100'),
        tauxTva: Decimal.parse('20'),
      );

      // montantTva = totalLigne * tauxTva / 100 = 100 * 20 / 100 = 20
      expect(ligne.montantTva, Decimal.parse('20'));
    });

    test('toMap produit une Map correcte', () {
      final ligne = LigneFacture(
        id: 'ligne-456',
        description: 'Fourniture matériel',
        quantite: Decimal.parse('10'),
        prixUnitaire: Decimal.parse('45.00'),
        totalLigne: Decimal.parse('450.00'),
        typeActivite: 'vente',
        unite: 'u',
        avancement: Decimal.parse('75'),
        tauxTva: Decimal.parse('5.5'),
      );

      final map = ligne.toMap();

      expect(map['id'], 'ligne-456');
      expect(map['description'], 'Fourniture matériel');
      expect(map['quantite'], '10');
      expect(Decimal.parse(map['prix_unitaire']), Decimal.parse('45.00'));
      expect(Decimal.parse(map['total_ligne']), Decimal.parse('450.00'));
      expect(map['avancement'], '75');
      expect(map['taux_tva'], '5.5');
    });

    test('uiKey est généré automatiquement', () {
      final ligne1 = LigneFacture(
        description: 'Ligne 1',
        quantite: Decimal.one,
        prixUnitaire: Decimal.one,
        totalLigne: Decimal.one,
      );

      final ligne2 = LigneFacture(
        description: 'Ligne 2',
        quantite: Decimal.one,
        prixUnitaire: Decimal.one,
        totalLigne: Decimal.one,
      );

      expect(ligne1.uiKey, isNotEmpty);
      expect(ligne2.uiKey, isNotEmpty);
      expect(ligne1.uiKey, isNot(equals(ligne2.uiKey)));
    });

    test('avancement défaut à 100', () {
      final ligne = LigneFacture(
        description: 'Test',
        quantite: Decimal.one,
        prixUnitaire: Decimal.one,
        totalLigne: Decimal.one,
      );

      expect(ligne.avancement, Decimal.fromInt(100));
    });
  });

  group('Paiement - fromMap / toMap / copyWith', () {
    test('crée un Paiement depuis une Map', () {
      final map = {
        'id': 'paiement-123',
        'facture_id': 'facture-456',
        'montant': '500.00',
        'date_paiement': '2026-02-17T10:00:00.000Z',
        'type_paiement': 'virement',
        'commentaire': 'Paiement partiel',
        'is_acompte': true,
      };

      final paiement = Paiement.fromMap(map);

      expect(paiement.id, 'paiement-123');
      expect(paiement.factureId, 'facture-456');
      expect(paiement.montant, Decimal.parse('500.00'));
      expect(paiement.datePaiement, DateTime.parse('2026-02-17T10:00:00.000Z'));
      expect(paiement.typePaiement, 'virement');
      expect(paiement.commentaire, 'Paiement partiel');
      expect(paiement.isAcompte, true);
    });

    test('toMap produit une Map correcte', () {
      final paiement = Paiement(
        id: 'paiement-789',
        factureId: 'facture-abc',
        montant: Decimal.parse('1200.00'),
        datePaiement: DateTime(2026, 2, 17, 15, 30),
        typePaiement: 'especes',
        commentaire: 'Paiement total',
        isAcompte: false,
      );

      final map = paiement.toMap();

      expect(map['id'], 'paiement-789');
      expect(map['facture_id'], 'facture-abc');
      expect(Decimal.parse(map['montant']), Decimal.parse('1200.00'));
      expect(map['type_paiement'], 'especes');
      expect(map['commentaire'], 'Paiement total');
      expect(map['is_acompte'], false);
    });

    test('copyWith modifie les champs spécifiés', () {
      final original = Paiement(
        factureId: 'facture-1',
        montant: Decimal.parse('100'),
        datePaiement: DateTime(2026, 1, 1),
        typePaiement: 'virement',
      );

      final modified = original.copyWith(
        montant: Decimal.parse('200'),
        typePaiement: 'cheque',
      );

      expect(modified.montant, Decimal.parse('200'));
      expect(modified.typePaiement, 'cheque');
      expect(modified.factureId, 'facture-1'); // Conservé
      expect(modified.datePaiement, DateTime(2026, 1, 1)); // Conservé
    });
  });

  group('Facture - fromMap / toMap', () {
    test('crée une Facture depuis une Map complète', () {
      final map = {
        'id': 'facture-123',
        'user_id': 'user-456',
        'numero_facture': 'FACT-2026-001',
        'objet': 'Facture travaux',
        'client_id': 'client-789',
        'devis_source_id': 'devis-abc',
        'date_emission': '2026-02-17T00:00:00.000Z',
        'date_echeance': '2026-03-17T00:00:00.000Z',
        'date_validation': '2026-02-18T10:00:00.000Z',
        'statut': 'validée',
        'statut_juridique': 'validée',
        'est_archive': false,
        'type': 'standard',
        'avancement_global': '100',
        'signature_url': 'https://example.com/signature.png',
        'date_signature': '2026-02-18T11:00:00.000Z',
        'total_ht': '2000',
        'total_tva': '400',
        'total_ttc': '2400',
        'remise_taux': '5',
        'acompte_deja_regle': '500',
        'conditions_reglement': 'Paiement à 30 jours',
        'notes_publiques': 'Merci pour votre confiance',
        'tva_intra': 'FR12345678901',
        'lignes_factures': [],
        'paiements': [],
        'lignes_chiffrages': [],
      };

      final facture = Facture.fromMap(map);

      expect(facture.id, 'facture-123');
      expect(facture.userId, 'user-456');
      expect(facture.numeroFacture, 'FACT-2026-001');
      expect(facture.objet, 'Facture travaux');
      expect(facture.clientId, 'client-789');
      expect(facture.devisSourceId, 'devis-abc');
      expect(facture.dateEmission, DateTime.parse('2026-02-17T00:00:00.000Z'));
      expect(facture.dateEcheance, DateTime.parse('2026-03-17T00:00:00.000Z'));
      expect(
          facture.dateValidation, DateTime.parse('2026-02-18T10:00:00.000Z'));
      expect(facture.statut, 'validée');
      expect(facture.statutJuridique, 'validée');
      expect(facture.type, 'standard');
      expect(facture.totalHt, Decimal.parse('2000'));
      expect(facture.totalTtc, Decimal.parse('2400'));
      expect(facture.remiseTaux, Decimal.parse('5'));
      expect(facture.acompteDejaRegle, Decimal.parse('500'));
      expect(facture.signatureUrl, 'https://example.com/signature.png');
    });

    test('toMap produit une Map correcte', () {
      final facture = Facture(
        id: 'facture-xyz',
        numeroFacture: 'FACT-2026-002',
        objet: 'Test facture',
        clientId: 'client-test',
        dateEmission: DateTime(2026, 2, 17),
        dateEcheance: DateTime(2026, 3, 17),
        totalHt: Decimal.parse('1000'),
        totalTva: Decimal.parse('200'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      final map = facture.toMap();

      expect(map['id'], 'facture-xyz');
      expect(map['numero_facture'], 'FACT-2026-002');
      expect(map['objet'], 'Test facture');
      expect(map['client_id'], 'client-test');
      expect(map['total_ht'], '1000');
      expect(map['total_ttc'], '1200');
    });
  });

  group('Facture - Getters calculés', () {
    test('totalPaiements somme tous les paiements', () {
      final facture = Facture(
        objet: 'Test',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        paiements: [
          Paiement(
            factureId: 'facture-1',
            montant: Decimal.parse('300'),
            datePaiement: DateTime.now(),
          ),
          Paiement(
            factureId: 'facture-1',
            montant: Decimal.parse('400'),
            datePaiement: DateTime.now(),
          ),
          Paiement(
            factureId: 'facture-1',
            montant: Decimal.parse('100'),
            datePaiement: DateTime.now(),
          ),
        ],
      );

      // Total paiements = 300 + 400 + 100 = 800
      expect(facture.totalPaiements, Decimal.parse('800'));
    });

    test('totalPaiements retourne zéro si aucun paiement', () {
      final facture = Facture(
        objet: 'Test',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        paiements: [],
      );

      expect(facture.totalPaiements, Decimal.zero);
    });

    test('netAPayer calcule TTC - Acompte - Paiements', () {
      final facture = Facture(
        objet: 'Test',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.parse('300'), // Acompte déjà réglé
        paiements: [
          Paiement(
            factureId: 'facture-1',
            montant: Decimal.parse('500'), // Paiement
            datePaiement: DateTime.now(),
          ),
        ],
      );

      // Net à payer = 1200 (TTC) - 300 (Acompte) - 500 (Paiement) = 400
      expect(facture.netAPayer, Decimal.parse('400'));
    });

    test('estSoldee retourne true si netAPayer <= 0', () {
      final factureSoldee = Facture(
        objet: 'Test soldée',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.parse('200'),
        paiements: [
          Paiement(
            factureId: 'facture-1',
            montant: Decimal.parse('1000'),
            datePaiement: DateTime.now(),
          ),
        ],
      );

      // Net à payer = 1200 - 200 - 1000 = 0
      expect(factureSoldee.netAPayer, Decimal.zero);
      expect(factureSoldee.estSoldee, true);
    });

    test('estSoldee retourne false si netAPayer > 0', () {
      final factureNonSoldee = Facture(
        objet: 'Test non soldée',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        paiements: [
          Paiement(
            factureId: 'facture-1',
            montant: Decimal.parse('500'),
            datePaiement: DateTime.now(),
          ),
        ],
      );

      // Net à payer = 1200 - 0 - 500 = 700
      expect(factureNonSoldee.netAPayer, Decimal.parse('700'));
      expect(factureNonSoldee.estSoldee, false);
    });

    test('estSoldee gère les sur-paiements (netAPayer négatif)', () {
      final factureSurPayee = Facture(
        objet: 'Test sur-payée',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
        paiements: [
          Paiement(
            factureId: 'facture-1',
            montant: Decimal.parse('1500'), // Sur-paiement
            datePaiement: DateTime.now(),
          ),
        ],
      );

      // Net à payer = 1200 - 0 - 1500 = -300
      expect(factureSurPayee.netAPayer, Decimal.parse('-300'));
      expect(factureSurPayee.estSoldee, true); // Car <= 0
    });
  });

  group('Facture - copyWith', () {
    test('copyWith modifie les champs spécifiés', () {
      final original = Facture(
        id: 'facture-1',
        objet: 'Original',
        clientId: 'client-1',
        dateEmission: DateTime(2026, 1, 1),
        dateEcheance: DateTime(2026, 2, 1),
        statut: 'brouillon',
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      final modified = original.copyWith(
        objet: 'Modified',
        statut: 'validée',
        totalHt: Decimal.parse('2000'),
      );

      expect(modified.objet, 'Modified');
      expect(modified.statut, 'validée');
      expect(modified.totalHt, Decimal.parse('2000'));
      expect(modified.id, 'facture-1'); // Conservé
      expect(modified.clientId, 'client-1'); // Conservé
    });
  });

  group('Facture - Cas limites', () {
    test('gère facture sans lignes, paiements ni chiffrage', () {
      final facture = Facture(
        objet: 'Facture vide',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.zero,
        totalTtc: Decimal.zero,
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      expect(facture.lignes, isEmpty);
      expect(facture.paiements, isEmpty);
      expect(facture.chiffrage, isEmpty);
      expect(facture.totalPaiements, Decimal.zero);
      expect(facture.netAPayer, Decimal.zero);
      expect(facture.estSoldee, true);
    });

    test('fromMap gère lignes_factures, paiements et lignes_chiffrages', () {
      final map = {
        'objet': 'Test avec relations',
        'client_id': 'client-1',
        'date_emission': '2026-02-17T00:00:00.000Z',
        'date_echeance': '2026-03-17T00:00:00.000Z',
        'total_ht': '1000',
        'total_tva': '200',
        'total_ttc': '1200',
        'remise_taux': '0',
        'acompte_deja_regle': '0',
        'lignes_factures': [
          {
            'description': 'Ligne 1',
            'quantite': '1',
            'prix_unitaire': '100',
            'total_ligne': '100',
            'avancement': '100',
            'taux_tva': '20',
          }
        ],
        'paiements': [
          {
            'facture_id': 'facture-1',
            'montant': '500',
            'date_paiement': '2026-02-20T00:00:00.000Z',
            'type_paiement': 'virement',
          }
        ],
        'lignes_chiffrages': [
          {
            'designation': 'Chiffrage 1',
            'quantite': '1',
            'prix_achat_unitaire': '50',
            'prix_vente_unitaire': '100',
          }
        ],
      };

      final facture = Facture.fromMap(map);

      expect(facture.lignes.length, 1);
      expect(facture.paiements.length, 1);
      expect(facture.chiffrage.length, 1);
      expect(facture.lignes[0].description, 'Ligne 1');
      expect(facture.paiements[0].montant, Decimal.parse('500'));
      expect(facture.chiffrage[0].designation, 'Chiffrage 1');
    });

    test('gère facture liée à un devis source', () {
      final facture = Facture(
        objet: 'Facture depuis devis',
        clientId: 'client-1',
        devisSourceId: 'devis-123', // Lien vers devis
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      expect(facture.devisSourceId, 'devis-123');
    });

    test('gère différents types de factures', () {
      final factureStandard = Facture(
        objet: 'Standard',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        type: 'standard',
        totalHt: Decimal.parse('1000'),
        totalTtc: Decimal.parse('1200'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      final factureAcompte = Facture(
        objet: 'Acompte',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        type: 'acompte',
        totalHt: Decimal.parse('300'),
        totalTtc: Decimal.parse('360'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      final factureSituation = Facture(
        objet: 'Situation',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateEcheance: DateTime.now(),
        type: 'situation',
        avancementGlobal: Decimal.parse('50'),
        totalHt: Decimal.parse('500'),
        totalTtc: Decimal.parse('600'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      expect(factureStandard.type, 'standard');
      expect(factureAcompte.type, 'acompte');
      expect(factureSituation.type, 'situation');
      expect(factureSituation.avancementGlobal, Decimal.parse('50'));
    });
  });
}
