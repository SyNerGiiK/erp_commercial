import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/services/email_service.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/devis_model.dart';
import 'package:erp_commercial/models/client_model.dart';
import 'package:erp_commercial/models/entreprise_model.dart';
import 'package:erp_commercial/services/relance_service.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('EmailResult', () {
    test('devrait créer un résultat OK', () {
      final result = EmailResult.ok();
      expect(result.success, true);
      expect(result.errorMessage, isNull);
    });

    test('devrait créer un résultat erreur', () {
      final result = EmailResult.error("Test erreur");
      expect(result.success, false);
      expect(result.errorMessage, "Test erreur");
    });
  });

  group('EmailService - envoyerDevis', () {
    test('devrait retourner erreur si client sans email', () async {
      final devis = Devis(
        id: 'd1',
        userId: 'user-1',
        numeroDevis: 'DEV-001',
        objet: 'Test devis',
        clientId: 'c1',
        dateEmission: DateTime(2025, 1, 1),
        dateValidite: DateTime(2025, 2, 1),
        totalHt: Decimal.parse('1000'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
      );

      final client = Client(
        id: 'c1',
        userId: 'user-1',
        nomComplet: 'Client Sans Email',
        adresse: '1 rue Test',
        codePostal: '75001',
        ville: 'Paris',
        telephone: '0612345678',
        email: '', // Pas d'email
      );

      final result =
          await EmailService.envoyerDevis(devis: devis, client: client);

      expect(result.success, false);
      expect(result.errorMessage, contains("pas d'adresse email"));
    });

    test('devrait retourner erreur si client email vide', () async {
      final devis = Devis(
        id: 'd1',
        userId: 'user-1',
        numeroDevis: 'DEV-002',
        objet: 'Test',
        clientId: 'c1',
        dateEmission: DateTime(2025, 3, 1),
        dateValidite: DateTime(2025, 4, 1),
        totalHt: Decimal.parse('500'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.zero,
      );

      final client = Client(
        id: 'c1',
        userId: 'user-1',
        nomComplet: 'Dupont',
        adresse: '',
        codePostal: '',
        ville: '',
        telephone: '',
        email: '',
      );

      final result =
          await EmailService.envoyerDevis(devis: devis, client: client);

      expect(result.success, false);
    });
  });

  group('EmailService - envoyerFacture', () {
    test('devrait retourner erreur si client sans email', () async {
      final facture = Facture(
        id: 'f1',
        userId: 'user-1',
        numeroFacture: 'FAC-001',
        objet: 'Test facture',
        clientId: 'c1',
        dateEmission: DateTime(2025, 1, 1),
        dateEcheance: DateTime(2025, 2, 1),
        totalHt: Decimal.parse('2000'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      final client = Client(
        id: 'c1',
        userId: 'user-1',
        nomComplet: 'Client Test',
        adresse: '1 rue Test',
        codePostal: '75001',
        ville: 'Paris',
        telephone: '0612345678',
        email: '',
      );

      final result =
          await EmailService.envoyerFacture(facture: facture, client: client);

      expect(result.success, false);
      expect(result.errorMessage, contains("pas d'adresse email"));
    });

    test('devrait retourner erreur si client sans email - avoir aussi vérifié',
        () async {
      final avoir = Facture(
        id: 'f2',
        userId: 'user-1',
        numeroFacture: 'AVO-001',
        objet: 'Avoir test',
        clientId: 'c1',
        typeDocument: 'avoir',
        type: 'avoir',
        dateEmission: DateTime(2025, 1, 1),
        dateEcheance: DateTime(2025, 2, 1),
        totalHt: Decimal.parse('500'),
        remiseTaux: Decimal.zero,
        acompteDejaRegle: Decimal.zero,
      );

      final client = Client(
        id: 'c1',
        userId: 'user-1',
        nomComplet: 'Client Avoir',
        adresse: '',
        codePostal: '',
        ville: '',
        telephone: '',
        email: '',
      );

      final result =
          await EmailService.envoyerFacture(facture: avoir, client: client);

      expect(result.success, false);
    });
  });

  group('EmailService - envoyerRelance', () {
    test('devrait retourner erreur si client sans email', () async {
      final relance = RelanceInfo(
        facture: Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: DateTime(2025, 1, 1),
          dateEcheance: DateTime(2024, 12, 1),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
        ),
        client: Client(
          id: 'c1',
          userId: 'user-1',
          nomComplet: 'Sans Email',
          adresse: '',
          codePostal: '',
          ville: '',
          telephone: '',
          email: '',
        ),
        joursRetard: 30,
        resteAPayer: Decimal.parse('1000'),
        niveau: NiveauRelance.ferme,
      );

      final result = await EmailService.envoyerRelance(relance: relance);
      expect(result.success, false);
      expect(result.errorMessage, contains("pas d'adresse email"));
    });

    test('devrait retourner erreur si client null', () async {
      final relance = RelanceInfo(
        facture: Facture(
          id: 'f1',
          userId: 'user-1',
          numeroFacture: 'FAC-001',
          objet: 'Test',
          clientId: 'c1',
          dateEmission: DateTime(2025, 1, 1),
          dateEcheance: DateTime(2024, 12, 1),
          totalHt: Decimal.parse('1000'),
          remiseTaux: Decimal.zero,
          acompteDejaRegle: Decimal.zero,
        ),
        // client: null (pas fourni)
        joursRetard: 30,
        resteAPayer: Decimal.parse('1000'),
        niveau: NiveauRelance.ferme,
      );

      final result = await EmailService.envoyerRelance(relance: relance);
      expect(result.success, false);
    });
  });

  group('EmailService - validation email', () {
    test('devrait accepter un email valide et tenter l\'envoi', () async {
      // On vérifie que la méthode ne retourne pas une erreur de validation
      // quand le client a un email valide. En test, url_launcher échouera
      // (pas de client mail), mais l'erreur de validation ne devrait pas
      // apparaître.
      final devis = Devis(
        id: 'd1',
        userId: 'u1',
        numeroDevis: 'DEV-2025-001',
        objet: 'Création site web',
        clientId: 'c1',
        dateEmission: DateTime(2025, 6, 15),
        dateValidite: DateTime(2025, 7, 15),
        totalHt: Decimal.parse('3500'),
        totalTtc: Decimal.parse('4200'),
        remiseTaux: Decimal.zero,
        acompteMontant: Decimal.parse('1050'),
      );

      final client = Client(
        id: 'c1',
        userId: 'u1',
        nomComplet: 'Entreprise Test SARL',
        adresse: '10 avenue de la Paix',
        codePostal: '69001',
        ville: 'Lyon',
        telephone: '0478123456',
        email: 'contact@test.com',
      );

      final profil = ProfilEntreprise(
        userId: 'u1',
        nomEntreprise: 'Mon Artisan',
        nomGerant: 'Jean Dupont',
        adresse: '10 rue Test',
        codePostal: '75001',
        ville: 'Paris',
        siret: '12345678901234',
        email: 'artisan@test.com',
      );

      final result = await EmailService.envoyerDevis(
          devis: devis, client: client, profil: profil);

      // En environnement test, url_launcher ne peut pas ouvrir le mail
      // Donc soit l'envoi réussit (si le système supporte mailto:),
      // soit il échoue à cause de l'absence de client mail — mais PAS
      // à cause de la validation email.
      if (!result.success) {
        expect(result.errorMessage, isNot(contains("pas d'adresse email")));
      }
    });
  });
}
