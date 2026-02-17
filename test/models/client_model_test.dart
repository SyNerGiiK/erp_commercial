import 'package:flutter_test/flutter_test.dart';
import 'package:erp_commercial/models/client_model.dart';

void main() {
  group('Client - fromMap / toMap', () {
    test('crée un Client depuis une Map complète', () {
      final map = {
        'id': 'client-123',
        'user_id': 'user-456',
        'nom_complet': 'Jean Dupont',
        'type_client': 'particulier',
        'nom_contact': 'Marie Dupont',
        'siret': '12345678901234',
        'tva_intra': 'FR12345678901',
        'adresse': '123 Rue de la Paix',
        'code_postal': '75001',
        'ville': 'Paris',
        'telephone': '0123456789',
        'email': 'jean.dupont@example.com',
        'notes_privees': 'Client VIP',
      };

      final client = Client.fromMap(map);

      expect(client.id, 'client-123');
      expect(client.userId, 'user-456');
      expect(client.nomComplet, 'Jean Dupont');
      expect(client.typeClient, 'particulier');
      expect(client.nomContact, 'Marie Dupont');
      expect(client.siret, '12345678901234');
      expect(client.tvaIntra, 'FR12345678901');
      expect(client.adresse, '123 Rue de la Paix');
      expect(client.codePostal, '75001');
      expect(client.ville, 'Paris');
      expect(client.telephone, '0123456789');
      expect(client.email, 'jean.dupont@example.com');
      expect(client.notesPrivees, 'Client VIP');
    });

    test('crée un Client avec valeurs par défaut pour champs manquants', () {
      final map = {
        'nom_complet': 'Pierre Martin',
        'adresse': '45 Avenue Victor Hugo',
        'code_postal': '69001',
        'ville': 'Lyon',
        'telephone': '0987654321',
        'email': 'pierre@example.com',
      };

      final client = Client.fromMap(map);

      expect(client.id, isNull);
      expect(client.userId, isNull);
      expect(client.nomComplet, 'Pierre Martin');
      expect(client.typeClient, 'particulier'); // Défaut
      expect(client.nomContact, isNull);
      expect(client.siret, isNull);
      expect(client.tvaIntra, isNull);
      expect(client.adresse, '45 Avenue Victor Hugo');
      expect(client.notesPrivees, isNull);
    });

    test('toMap produit une Map correcte', () {
      final client = Client(
        id: 'client-789',
        userId: 'user-101',
        nomComplet: 'Sophie Bernard',
        typeClient: 'professionnel',
        nomContact: 'Marc Bernard',
        siret: '98765432109876',
        tvaIntra: 'FR98765432109',
        adresse: '10 Boulevard Haussmann',
        codePostal: '75009',
        ville: 'Paris',
        telephone: '0611223344',
        email: 'sophie@example.com',
        notesPrivees: 'Paiement 30 jours',
      );

      final map = client.toMap();

      expect(map['id'], 'client-789');
      expect(map['user_id'], 'user-101');
      expect(map['nom_complet'], 'Sophie Bernard');
      expect(map['type_client'], 'professionnel');
      expect(map['nom_contact'], 'Marc Bernard');
      expect(map['siret'], '98765432109876');
      expect(map['tva_intra'], 'FR98765432109');
      expect(map['adresse'], '10 Boulevard Haussmann');
      expect(map['code_postal'], '75009');
      expect(map['ville'], 'Paris');
      expect(map['telephone'], '0611223344');
      expect(map['email'], 'sophie@example.com');
      expect(map['notes_privees'], 'Paiement 30 jours');
    });

    test('fromMap puis toMap conserve les données', () {
      final originalMap = {
        'id': 'client-abc',
        'user_id': 'user-xyz',
        'nom_complet': 'Test Client',
        'type_client': 'particulier',
        'adresse': 'Test Address',
        'code_postal': '12345',
        'ville': 'Test City',
        'telephone': '0000000000',
        'email': 'test@test.com',
      };

      final client = Client.fromMap(originalMap);
      final resultMap = client.toMap();

      expect(resultMap['id'], originalMap['id']);
      expect(resultMap['user_id'], originalMap['user_id']);
      expect(resultMap['nom_complet'], originalMap['nom_complet']);
      expect(resultMap['type_client'], originalMap['type_client']);
      expect(resultMap['adresse'], originalMap['adresse']);
      expect(resultMap['email'], originalMap['email']);
    });
  });

  group('Client - copyWith', () {
    test('copyWith modifie les champs spécifiés', () {
      final original = Client(
        id: 'client-1',
        userId: 'user-1',
        nomComplet: 'Original Name',
        typeClient: 'particulier',
        adresse: 'Original Address',
        codePostal: '11111',
        ville: 'Original City',
        telephone: '1111111111',
        email: 'original@example.com',
      );

      final modified = original.copyWith(
        nomComplet: 'Modified Name',
        email: 'modified@example.com',
        telephone: '2222222222',
      );

      // Champs modifiés
      expect(modified.nomComplet, 'Modified Name');
      expect(modified.email, 'modified@example.com');
      expect(modified.telephone, '2222222222');

      // Champs conservés
      expect(modified.id, 'client-1');
      expect(modified.userId, 'user-1');
      expect(modified.adresse, 'Original Address');
      expect(modified.codePostal, '11111');
      expect(modified.ville, 'Original City');
      expect(modified.typeClient, 'particulier');
    });

    test('copyWith sans paramètres retourne une copie identique', () {
      final original = Client(
        id: 'client-2',
        nomComplet: 'Test Name',
        adresse: 'Test Adresse',
        codePostal: '22222',
        ville: 'Test Ville',
        telephone: '3333333333',
        email: 'test@example.com',
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.nomComplet, original.nomComplet);
      expect(copy.adresse, original.adresse);
      expect(copy.email, original.email);
      expect(copy.telephone, original.telephone);
    });

    test('copyWith peut modifier le typeClient', () {
      final original = Client(
        nomComplet: 'Entreprise SARL',
        typeClient: 'particulier',
        adresse: 'Siège social',
        codePostal: '33333',
        ville: 'Ville',
        telephone: '4444444444',
        email: 'contact@sarl.com',
      );

      final modified = original.copyWith(
        typeClient: 'professionnel',
        siret: '11122233344455',
        tvaIntra: 'FR11122233344',
      );

      expect(modified.typeClient, 'professionnel');
      expect(modified.siret, '11122233344455');
      expect(modified.tvaIntra, 'FR11122233344');
      expect(modified.nomComplet, 'Entreprise SARL'); // Conservé
    });
  });

  group('Client - Cas limites', () {
    test('gère les champs vides dans fromMap', () {
      final map = {
        'nom_complet': '',
        'adresse': '',
        'code_postal': '',
        'ville': '',
        'telephone': '',
        'email': '',
      };

      final client = Client.fromMap(map);

      expect(client.nomComplet, '');
      expect(client.adresse, '');
      expect(client.email, '');
    });

    test('toMap n\'inclut pas l\'ID si null', () {
      final client = Client(
        nomComplet: 'Nouveau Client',
        adresse: 'Adresse',
        codePostal: '44444',
        ville: 'Ville',
        telephone: '5555555555',
        email: 'nouveau@example.com',
      );

      final map = client.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('nom_complet'), isTrue);
    });

    test('toMap inclut l\'ID si présent', () {
      final client = Client(
        id: 'client-with-id',
        nomComplet: 'Client avec ID',
        adresse: 'Adresse',
        codePostal: '55555',
        ville: 'Ville',
        telephone: '6666666666',
        email: 'withid@example.com',
      );

      final map = client.toMap();

      expect(map.containsKey('id'), isTrue);
      expect(map['id'], 'client-with-id');
    });
  });

  group('Client - Validation des données métier', () {
    test('crée un client particulier sans SIRET ni TVA', () {
      final client = Client(
        nomComplet: 'Particulier Test',
        typeClient: 'particulier',
        adresse: 'Adresse particulier',
        codePostal: '66666',
        ville: 'Ville',
        telephone: '7777777777',
        email: 'particulier@example.com',
      );

      expect(client.typeClient, 'particulier');
      expect(client.siret, isNull);
      expect(client.tvaIntra, isNull);
    });

    test('crée un client professionnel avec SIRET et TVA', () {
      final client = Client(
        nomComplet: 'Entreprise Pro',
        typeClient: 'professionnel',
        siret: '12312312312312',
        tvaIntra: 'FR12312312312',
        adresse: 'Siège entreprise',
        codePostal: '77777',
        ville: 'Ville Pro',
        telephone: '8888888888',
        email: 'pro@example.com',
      );

      expect(client.typeClient, 'professionnel');
      expect(client.siret, '12312312312312');
      expect(client.tvaIntra, 'FR12312312312');
    });
  });
}
