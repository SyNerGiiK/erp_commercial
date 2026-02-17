import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/services/relance_service.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/paiement_model.dart';
import 'package:erp_commercial/models/client_model.dart';

void main() {
  group('RelanceService - analyserRelances', () {
    test('devrait détecter les factures en retard', () {
      // ARRANGE
      final now = DateTime.now();
      final factures = <Facture>[
        // En retard - 20 jours
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'En retard',
          clientId: 'client-1',
          dateEmission: now.subtract(const Duration(days: 50)),
          dateEcheance: now.subtract(const Duration(days: 20)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [],
        ),
        // Payée - ne devrait pas apparaître
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-002',
          objet: 'Payée',
          clientId: 'client-2',
          dateEmission: now.subtract(const Duration(days: 60)),
          dateEcheance: now.subtract(const Duration(days: 30)),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'payee',
          paiements: [],
        ),
        // Brouillon - ne devrait pas apparaître
        Facture(
          id: 'f3',
          userId: 'user-1',
          numeroFacture: 'FAC-003',
          objet: 'Brouillon',
          clientId: 'client-3',
          dateEmission: now,
          dateEcheance: now.subtract(const Duration(days: 10)),
          totalHt: Decimal.parse('2000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'brouillon',
          paiements: [],
        ),
        // En retard - 5 jours
        Facture(
          id: 'f4',
          userId: 'user-1',
          numeroFacture: 'FAC-004',
          objet: 'Petit retard',
          clientId: 'client-1',
          dateEmission: now.subtract(const Duration(days: 35)),
          dateEcheance: now.subtract(const Duration(days: 5)),
          totalHt: Decimal.parse('750'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'envoye',
          paiements: [],
        ),
      ];

      // ACT
      final relances = RelanceService.analyserRelances(factures);

      // ASSERT
      expect(relances.length, 2);
      // Trié par retard décroissant
      expect(relances[0].joursRetard, 20);
      expect(relances[0].facture.id, 'f1');
      expect(relances[1].joursRetard, 5);
      expect(relances[1].facture.id, 'f4');
    });

    test('devrait ignorer les factures soldées', () {
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Soldée par paiement',
          clientId: 'c1',
          dateEmission: now.subtract(const Duration(days: 60)),
          dateEcheance: now.subtract(const Duration(days: 30)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [
            Paiement(
              factureId: 'f1',
              montant: Decimal.parse('1000'),
              datePaiement: now,
              typePaiement: 'virement',
            ),
          ],
        ),
      ];

      final relances = RelanceService.analyserRelances(factures);
      expect(relances, isEmpty);
    });

    test('devrait associer les clients aux relances', () {
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'client-1',
          dateEmission: now.subtract(const Duration(days: 40)),
          dateEcheance: now.subtract(const Duration(days: 10)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
          paiements: [],
        ),
      ];

      final clients = <Client>[
        Client(
          id: 'client-1',
          userId: 'user-1',
          nomComplet: 'Jean Dupont',
          adresse: '1 rue Test',
          codePostal: '75001',
          ville: 'Paris',
          telephone: '0612345678',
          email: 'jean@test.com',
        ),
      ];

      final relances =
          RelanceService.analyserRelances(factures, clients: clients);
      expect(relances.length, 1);
      expect(relances[0].client?.nomComplet, 'Jean Dupont');
    });

    test('devrait retourner une liste vide si aucune facture en retard', () {
      final relances = RelanceService.analyserRelances([]);
      expect(relances, isEmpty);
    });
  });

  group('RelanceService - NiveauRelance', () {
    test('devrait déterminer le niveau amiable (1-14 jours)', () {
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: now.subtract(const Duration(days: 40)),
          dateEcheance: now.subtract(const Duration(days: 10)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      final relances = RelanceService.analyserRelances(factures);
      expect(relances[0].niveau, NiveauRelance.amiable);
    });

    test('devrait déterminer le niveau ferme (15-30 jours)', () {
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: now.subtract(const Duration(days: 50)),
          dateEcheance: now.subtract(const Duration(days: 20)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      final relances = RelanceService.analyserRelances(factures);
      expect(relances[0].niveau, NiveauRelance.ferme);
    });

    test('devrait déterminer le niveau miseEnDemeure (31-60 jours)', () {
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: now.subtract(const Duration(days: 80)),
          dateEcheance: now.subtract(const Duration(days: 45)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      final relances = RelanceService.analyserRelances(factures);
      expect(relances[0].niveau, NiveauRelance.miseEnDemeure);
    });

    test('devrait déterminer le niveau contentieux (60+ jours)', () {
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: now.subtract(const Duration(days: 120)),
          dateEcheance: now.subtract(const Duration(days: 90)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      final relances = RelanceService.analyserRelances(factures);
      expect(relances[0].niveau, NiveauRelance.contentieux);
    });
  });

  group('RelanceService - getStatistiquesRelances', () {
    test('devrait calculer les statistiques correctement', () {
      final now = DateTime.now();
      final factures = <Facture>[
        Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Retard 10j',
          clientId: 'c1',
          dateEmission: now.subtract(const Duration(days: 40)),
          dateEcheance: now.subtract(const Duration(days: 10)),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
        Facture(
          id: 'f2',
          userId: 'user-1',
          numeroFacture: 'FAC-002',
          objet: 'Retard 25j',
          clientId: 'c2',
          dateEmission: now.subtract(const Duration(days: 55)),
          dateEcheance: now.subtract(const Duration(days: 25)),
          totalHt: Decimal.parse('2000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
          statut: 'validee',
        ),
      ];

      final relances = RelanceService.analyserRelances(factures);
      final stats = RelanceService.getStatistiquesRelances(relances);

      expect(stats['total'], 2);
      expect(stats['montantTotal'], Decimal.parse('3000'));
      expect((stats['retardMoyen'] as double), closeTo(17.5, 1.0));
      expect((stats['parNiveau'] as Map).length, greaterThan(0));
    });

    test('devrait retourner des stats vides pour aucune relance', () {
      final stats = RelanceService.getStatistiquesRelances([]);
      expect(stats['total'], 0);
      expect(stats['montantTotal'], Decimal.zero);
      expect(stats['retardMoyen'], 0.0);
    });
  });

  group('RelanceService - genererTexteRelance', () {
    test('devrait générer un texte de relance amiable', () {
      final relance = RelanceInfo(
        facture: Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: DateTime(2024, 1, 1),
          dateEcheance: DateTime(2024, 2, 1),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
        ),
        joursRetard: 10,
        resteAPayer: Decimal.parse('1000'),
        niveau: NiveauRelance.amiable,
      );

      final texte = RelanceService.genererTexteRelance(relance);

      expect(texte, contains('Rappel'));
      expect(texte, contains('FAC-2024-001'));
      expect(texte, contains('1000.00'));
      expect(texte, contains('Cordialement'));
    });

    test('devrait générer un texte de mise en demeure', () {
      final relance = RelanceInfo(
        facture: Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-2024-002',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: DateTime(2024, 1, 1),
          dateEcheance: DateTime(2024, 2, 1),
          totalHt: Decimal.parse('5000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
        ),
        joursRetard: 45,
        resteAPayer: Decimal.parse('5000'),
        niveau: NiveauRelance.miseEnDemeure,
      );

      final texte = RelanceService.genererTexteRelance(relance);

      expect(texte, contains('MISE EN DEMEURE'));
      expect(texte, contains('FAC-2024-002'));
      expect(texte, contains('recouvrement'));
    });

    test('devrait utiliser le nom du client si disponible', () {
      final client = Client(
        id: 'c1',
        userId: 'user-1',
        nomComplet: 'Entreprise Dupont',
        adresse: '',
        codePostal: '',
        ville: '',
        telephone: '',
        email: '',
      );

      final relance = RelanceInfo(
        facture: Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: DateTime(2024, 1, 1),
          dateEcheance: DateTime(2024, 2, 1),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
        ),
        client: client,
        joursRetard: 5,
        resteAPayer: Decimal.parse('1000'),
        niveau: NiveauRelance.amiable,
      );

      final texte = RelanceService.genererTexteRelance(relance);
      expect(texte, contains('Entreprise Dupont'));
    });
  });

  group('RelanceInfo - message', () {
    test('devrait formater un message complet', () {
      final relance = RelanceInfo(
        facture: Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: DateTime(2024, 1, 1),
          dateEcheance: DateTime(2024, 3, 1),
          totalHt: Decimal.parse('500'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
        ),
        client: Client(
          id: 'c1',
          userId: 'user-1',
          nomComplet: 'Test Client',
          adresse: '',
          codePostal: '',
          ville: '',
          telephone: '',
          email: '',
        ),
        joursRetard: 15,
        resteAPayer: Decimal.parse('500'),
        niveau: NiveauRelance.ferme,
      );

      expect(relance.message, contains('FAC-001'));
      expect(relance.message, contains('Test Client'));
      expect(relance.message, contains('15 jours'));
      expect(relance.message, contains('500.00'));
    });
  });
}
