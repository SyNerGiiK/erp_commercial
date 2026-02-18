import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/chiffrage_model.dart';

void main() {
  group('LigneDevis - fromMap / toMap', () {
    test('crée une LigneDevis depuis une Map complète', () {
      final map = {
        'id': 'ligne-123',
        'description': 'Installation électrique',
        'quantite': '10',
        'prix_unitaire': '50.50',
        'total_ligne': '505',
        'type_activite': 'service',
        'unite': 'u',
        'type': 'article',
        'ordre': 1,
        'est_gras': true,
        'est_italique': false,
        'est_souligne': false,
        'taux_tva': '20',
      };

      final ligne = LigneDevis.fromMap(map);

      expect(ligne.id, 'ligne-123');
      expect(ligne.description, 'Installation électrique');
      expect(ligne.quantite, Decimal.parse('10'));
      expect(ligne.prixUnitaire, Decimal.parse('50.50'));
      expect(ligne.totalLigne, Decimal.parse('505'));
      expect(ligne.typeActivite, 'service');
      expect(ligne.unite, 'u');
      expect(ligne.ordre, 1);
      expect(ligne.estGras, true);
      expect(ligne.tauxTva, Decimal.parse('20'));
    });

    test('calcule montantTva correctement', () {
      final ligne = LigneDevis(
        description: 'Test',
        quantite: Decimal.parse('1'),
        prixUnitaire: Decimal.parse('100'),
        totalLigne: Decimal.parse('100'),
        tauxTva: Decimal.parse('20'),
      );

      expect(ligne.montantTva, Decimal.parse('20'));
    });

    test('toMap produit une Map correcte', () {
      final ligne = LigneDevis(
        id: 'ligne-456',
        description: 'Fourniture matériel',
        quantite: Decimal.parse('5'),
        prixUnitaire: Decimal.parse('25.75'),
        totalLigne: Decimal.parse('128.75'),
        typeActivite: 'vente',
        unite: 'm',
        type: 'article',
        ordre: 2,
        estGras: false,
        estItalique: true,
        estSouligne: false,
        tauxTva: Decimal.parse('5.5'),
      );

      final map = ligne.toMap();

      expect(map['id'], 'ligne-456');
      expect(map['description'], 'Fourniture matériel');
      expect(map['quantite'], '5');
      expect(map['prix_unitaire'], '25.75');
      expect(map['total_ligne'], '128.75');
      expect(map['type_activite'], 'vente');
      expect(map['unite'], 'm');
      expect(map['ordre'], 2);
      expect(map['est_italique'], true);
      expect(map['taux_tva'], '5.5');
    });

    test('uiKey est généré automatiquement', () {
      final ligne1 = LigneDevis(
        description: 'Ligne 1',
        quantite: Decimal.one,
        prixUnitaire: Decimal.one,
        totalLigne: Decimal.one,
      );

      final ligne2 = LigneDevis(
        description: 'Ligne 2',
        quantite: Decimal.one,
        prixUnitaire: Decimal.one,
        totalLigne: Decimal.one,
      );

      expect(ligne1.uiKey, isNotEmpty);
      expect(ligne2.uiKey, isNotEmpty);
      expect(ligne1.uiKey, isNot(equals(ligne2.uiKey))); // uiKeys différentes
    });
  });

  group('LigneDevis - copyWith', () {
    test('copyWith modifie les champs spécifiés', () {
      final original = LigneDevis(
        description: 'Original',
        quantite: Decimal.parse('10'),
        prixUnitaire: Decimal.parse('50'),
        totalLigne: Decimal.parse('500'),
        unite: 'u',
      );

      final modified = original.copyWith(
        description: 'Modified',
        quantite: Decimal.parse('20'),
      );

      expect(modified.description, 'Modified');
      expect(modified.quantite, Decimal.parse('20'));
      expect(modified.prixUnitaire, Decimal.parse('50')); // Conservé
      expect(modified.uiKey, original.uiKey); // uiKey conservée
    });
  });

  group('Devis - fromMap / toMap', () {
    test('crée un Devis depuis une Map complète', () {
      final map = {
        'id': 'devis-123',
        'user_id': 'user-456',
        'numero_devis': 'DEV-2026-001',
        'objet': 'Travaux rénovation',
        'client_id': 'client-789',
        'date_emission': '2026-02-17T00:00:00.000Z',
        'date_validite': '2026-03-17T00:00:00.000Z',
        'statut': 'finalisé',
        'est_transforme': false,
        'est_archive': false,
        'total_ht': '1000',
        'total_tva': '200',
        'total_ttc': '1200',
        'remise_taux': '10',
        'acompte_montant': '300',
        'acompte_percentage': '40',
        'conditions_reglement': 'Paiement à 30 jours',
        'notes_publiques': 'Notes publiques ici',
        'signature_url': 'https://example.com/signature.png',
        'date_signature': '2026-02-18T10:00:00.000Z',
        'tva_intra': 'FR12345678901',
        'lignes_devis': [],
        'lignes_chiffrages': [],
      };

      final devis = Devis.fromMap(map);

      expect(devis.id, 'devis-123');
      expect(devis.userId, 'user-456');
      expect(devis.numeroDevis, 'DEV-2026-001');
      expect(devis.objet, 'Travaux rénovation');
      expect(devis.clientId, 'client-789');
      expect(devis.dateEmission, DateTime.parse('2026-02-17T00:00:00.000Z'));
      expect(devis.dateValidite, DateTime.parse('2026-03-17T00:00:00.000Z'));
      expect(devis.statut, 'finalisé');
      expect(devis.totalHt, Decimal.parse('1000'));
      expect(devis.totalTva, Decimal.parse('200'));
      expect(devis.totalTtc, Decimal.parse('1200'));
      expect(devis.remiseTaux, Decimal.parse('10'));
      expect(devis.acompteMontant, Decimal.parse('300'));
      expect(devis.acomptePercentage, Decimal.parse('40'));
      expect(devis.conditionsReglement, 'Paiement à 30 jours');
      expect(devis.signatureUrl, 'https://example.com/signature.png');
      expect(devis.dateSignature, DateTime.parse('2026-02-18T10:00:00.000Z'));
    });

    test('acomptePercentage par défaut à 30 si absent de la Map', () {
      final map = {
        'objet': 'Test défaut',
        'client_id': 'client-1',
        'date_emission': '2026-02-17T00:00:00.000Z',
        'date_validite': '2026-03-17T00:00:00.000Z',
        'total_ht': '1000',
        'total_tva': '200',
        'total_ttc': '1200',
        'remise_taux': '0',
        'acompte_montant': '0',
      };

      final devis = Devis.fromMap(map);
      expect(devis.acomptePercentage, Decimal.fromInt(30));
    });

    test('acomptePercentage est persisté dans toMap', () {
      final devis = Devis(
        objet: 'Test percentage toMap',
        clientId: 'client-1',
        dateEmission: DateTime(2026, 2, 17),
        dateValidite: DateTime(2026, 3, 17),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.parse('200'),
        acomptePercentage: Decimal.parse('20'),
      );

      final map = devis.toMap();
      expect(map['acompte_percentage'], '20');
      expect(map['acompte_montant'], '200');
    });

    test('copyWith modifie acomptePercentage', () {
      final original = Devis(
        objet: 'Test',
        clientId: 'client-1',
        dateEmission: DateTime(2026, 2, 17),
        dateValidite: DateTime(2026, 3, 17),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        acomptePercentage: Decimal.fromInt(30),
      );

      final modified =
          original.copyWith(acomptePercentage: Decimal.fromInt(50));
      expect(modified.acomptePercentage, Decimal.fromInt(50));
      expect(original.acomptePercentage, Decimal.fromInt(30)); // inchangé
    });

    test('toMap produit une Map correcte', () {
      final devis = Devis(
        id: 'devis-abc',
        userId: 'user-xyz',
        numeroDevis: 'DEV-2026-002',
        objet: 'Projet test',
        clientId: 'client-def',
        dateEmission: DateTime(2026, 2, 17),
        dateValidite: DateTime(2026, 3, 17),
        statut: 'brouillon',
        totalHt: Decimal.parse('2000'),
        totalTva: Decimal.parse('400'),
        totalTtc: Decimal.parse('2400'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        conditionsReglement: 'N/A',
        lignes: [],
        chiffrage: [],
      );

      final map = devis.toMap();

      expect(map['id'], 'devis-abc');
      expect(map['numero_devis'], 'DEV-2026-002');
      expect(map['objet'], 'Projet test');
      expect(map['client_id'], 'client-def');
      expect(map['statut'], 'brouillon');
      expect(map['total_ht'], '2000');
      expect(map['total_ttc'], '2400');
      expect(map['remise_taux'], '0');
    });
  });

  group('Devis - Getters calculés', () {
    test('margeBrute calcule correctement (CA - Achats)', () {
      final devis = Devis(
        objet: 'Test marge',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        chiffrage: [
          LigneChiffrage(
            designation: 'Matériel',
            quantite: Decimal.parse('10'),
            prixAchatUnitaire: Decimal.parse('30'), // 10 * 30 = 300
          ),
        ],
      );

      // Marge brute = 1000 (CA) - 300 (Achats) = 700
      expect(devis.totalAchats, Decimal.parse('300'));
      expect(devis.margeBrute, Decimal.parse('700'));
    });

    test('tauxMargeBrute calcule le pourcentage correctement', () {
      final devis = Devis(
        objet: 'Test taux marge',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        chiffrage: [
          LigneChiffrage(
            designation: 'Matériel',
            quantite: Decimal.parse('5'),
            prixAchatUnitaire: Decimal.parse('50'), // 5 * 50 = 250
          ),
        ],
      );

      // Marge brute = 1000 - 250 = 750
      // Taux = (750 / 1000) * 100 = 75%
      expect(devis.margeBrute, Decimal.parse('750'));
      expect(devis.tauxMargeBrute.toDouble(), closeTo(75, 0.01));
    });

    test('tauxMargeBrute retourne zéro si totalHt est zéro', () {
      final devis = Devis(
        objet: 'Test',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.zero,
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
      );

      expect(devis.tauxMargeBrute, Decimal.zero);
    });

    test('netCommercial calcule HT - Remise', () {
      final devis = Devis(
        objet: 'Test net commercial',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.parse('10'), // 10% de remise
        acompteMontant: Decimal.zero,
      );

      // Net commercial = 1000 - (1000 * 10 / 100) = 1000 - 100 = 900
      expect(devis.netCommercial, Decimal.parse('900'));
    });

    test('totalAchats somme tous les chiffrages', () {
      final devis = Devis(
        objet: 'Test achats multiples',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.parse('2000'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
        chiffrage: [
          LigneChiffrage(
            designation: 'Matériel 1',
            quantite: Decimal.parse('10'),
            prixAchatUnitaire: Decimal.parse('20'), // 200
          ),
          LigneChiffrage(
            designation: 'Matériel 2',
            quantite: Decimal.parse('5'),
            prixAchatUnitaire: Decimal.parse('30'), // 150
          ),
          LigneChiffrage(
            designation: 'Matériel 3',
            quantite: Decimal.parse('8'),
            prixAchatUnitaire: Decimal.parse('12.50'), // 100
          ),
        ],
      );

      // Total achats = 200 + 150 + 100 = 450
      expect(devis.totalAchats, Decimal.parse('450'));
    });
  });

  group('Devis - copyWith', () {
    test('copyWith modifie les champs spécifiés', () {
      final original = Devis(
        id: 'devis-1',
        objet: 'Original',
        clientId: 'client-1',
        dateEmission: DateTime(2026, 1, 1),
        dateValidite: DateTime(2026, 2, 1),
        statut: 'brouillon',
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
      );

      final modified = original.copyWith(
        objet: 'Modified',
        statut: 'finalisé',
        totalHt: Decimal.parse('2000'),
      );

      expect(modified.objet, 'Modified');
      expect(modified.statut, 'finalisé');
      expect(modified.totalHt, Decimal.parse('2000'));
      expect(modified.id, 'devis-1'); // Conservé
      expect(modified.clientId, 'client-1'); // Conservé
    });
  });

  group('Devis - Cas limites', () {
    test('gère devis sans lignes ni chiffrage', () {
      final devis = Devis(
        objet: 'Devis vide',
        clientId: 'client-1',
        dateEmission: DateTime.now(),
        dateValidite: DateTime.now(),
        totalHt: Decimal.zero,
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
      );

      expect(devis.lignes, isEmpty);
      expect(devis.chiffrage, isEmpty);
      expect(devis.totalAchats, Decimal.zero);
      expect(devis.margeBrute, Decimal.zero);
    });

    test('fromMap gère lignes_devis et lignes_chiffrages', () {
      final map = {
        'objet': 'Test avec lignes',
        'client_id': 'client-1',
        'date_emission': '2026-02-17T00:00:00.000Z',
        'date_validite': '2026-03-17T00:00:00.000Z',
        'total_ht': '500',
        'total_tva': '100',
        'total_ttc': '600',
        'remise_taux': '0',
        'acompte_montant': '0',
        'lignes_devis': [
          {
            'description': 'Ligne 1',
            'quantite': '1',
            'prix_unitaire': '100',
            'total_ligne': '100',
            'taux_tva': '20',
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

      final devis = Devis.fromMap(map);

      expect(devis.lignes.length, 1);
      expect(devis.chiffrage.length, 1);
      expect(devis.lignes[0].description, 'Ligne 1');
      expect(devis.chiffrage[0].designation, 'Chiffrage 1');
    });
  });
}
