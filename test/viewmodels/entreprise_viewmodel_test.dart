import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:erp_commercial/viewmodels/entreprise_viewmodel.dart';
import 'package:erp_commercial/models/entreprise_model.dart';
import 'package:erp_commercial/models/enums/entreprise_enums.dart';
import '../mocks/repository_mocks.dart';

// Fake pour les types complexes
class FakeProfilEntreprise extends Fake implements ProfilEntreprise {}

void main() {
  late MockEntrepriseRepository mockRepository;
  late EntrepriseViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeProfilEntreprise());
  });

  setUp(() {
    mockRepository = MockEntrepriseRepository();
    viewModel = EntrepriseViewModel(repository: mockRepository);
  });

  group('fetchProfil', () {
    test('devrait récupérer et exposer le profil entreprise', () async {
      // ARRANGE
      final testProfil = ProfilEntreprise(
        id: 'profil-1',
        userId: 'user-1',
        nomEntreprise: 'Ma Société',
        nomGerant: 'Jean Dupont',
        adresse: '123 rue du Test',
        codePostal: '75001',
        ville: 'Paris',
        siret: '12345678901234',
        email: 'contact@masociete.fr',
        telephone: '0123456789',
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        tvaApplicable: false,
      );

      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => testProfil);

      // ACT
      await viewModel.fetchProfil();

      // ASSERT
      expect(viewModel.profil, isNotNull);
      expect(viewModel.profil!.nomEntreprise, 'Ma Société');
      expect(viewModel.profil!.siret, '12345678901234');
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.getProfil()).called(1);
    });

    test('devrait gérer les erreurs sans crash', () async {
      // ARRANGE
      when(() => mockRepository.getProfil())
          .thenThrow(Exception('Erreur réseau'));

      // ACT
      await viewModel.fetchProfil();

      // ASSERT
      expect(viewModel.profil, isNull);
      expect(viewModel.isLoading, false);
    });
  });

  group('saveProfil', () {
    test('devrait sauvegarder et recharger le profil', () async {
      // ARRANGE
      final newProfil = ProfilEntreprise(
        id: 'profil-1',
        userId: 'user-1',
        nomEntreprise: 'Société Mise à jour',
        nomGerant: 'Jean Dupont',
        adresse: '456 avenue Nouveau',
        codePostal: '75002',
        ville: 'Paris',
        siret: '12345678901234',
        email: 'nouveau@masociete.fr',
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        tvaApplicable: false,
      );

      final savedProfil = ProfilEntreprise(
        id: 'profil-1',
        userId: 'user-1',
        nomEntreprise: 'Société Mise à jour',
        nomGerant: 'Jean Dupont',
        adresse: '456 avenue Nouveau',
        codePostal: '75002',
        ville: 'Paris',
        siret: '12345678901234',
        email: 'nouveau@masociete.fr',
        typeEntreprise: TypeEntreprise.microEntrepreneur,
        tvaApplicable: false,
      );

      when(() => mockRepository.saveProfil(any())).thenAnswer((_) async {});
      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => savedProfil);

      // ACT
      final success = await viewModel.saveProfil(newProfil);

      // ASSERT
      expect(success, true);
      expect(viewModel.profil, isNotNull);
      expect(viewModel.profil!.nomEntreprise, 'Société Mise à jour');
      verify(() => mockRepository.saveProfil(newProfil)).called(1);
      verify(() => mockRepository.getProfil()).called(1);
    });

    test('devrait retourner false en cas d\'erreur de sauvegarde', () async {
      // ARRANGE
      final newProfil = ProfilEntreprise(
        nomEntreprise: 'Test',
        nomGerant: 'Test',
        adresse: 'Test',
        codePostal: '75000',
        ville: 'Paris',
        siret: '12345678901234',
        email: 'test@test.fr',
      );

      when(() => mockRepository.saveProfil(any()))
          .thenThrow(Exception('Save failed'));

      // ACT
      final success = await viewModel.saveProfil(newProfil);

      // ASSERT
      expect(success, false);
      expect(viewModel.isLoading, false);
    });
  });

  group('getLegalMentionsSuggestion', () {
    test('devrait retourner les mentions légales pour micro-entrepreneur', () {
      // ACT
      final mentions = viewModel
          .getLegalMentionsSuggestion(TypeEntreprise.microEntrepreneur);

      // ASSERT
      expect(mentions, contains('TVA non applicable'));
      expect(mentions, contains('art. 293 B du CGI'));
      expect(mentions, contains('Dispensé d\'immatriculation'));
    });

    test('devrait retourner vide pour autres types d\'entreprise', () {
      // ACT
      final mentions = viewModel
          .getLegalMentionsSuggestion(TypeEntreprise.entrepriseIndividuelle);

      // ASSERT
      expect(mentions, isEmpty);
    });
  });

  group('isTvaApplicable', () {
    test('devrait retourner false si profil null', () {
      // ACT & ASSERT
      expect(viewModel.isTvaApplicable, false);
    });

    test('devrait retourner la valeur du profil si présent', () async {
      // ARRANGE
      final profilAvecTva = ProfilEntreprise(
        id: 'profil-1',
        userId: 'user-1',
        nomEntreprise: 'Société TVA',
        nomGerant: 'Jean Dupont',
        adresse: '123 rue du Test',
        codePostal: '75001',
        ville: 'Paris',
        siret: '12345678901234',
        email: 'contact@masociete.fr',
        typeEntreprise: TypeEntreprise.entrepriseIndividuelle,
        tvaApplicable: true, // TVA applicable
        numeroTvaIntra: 'FR12345678901',
      );

      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => profilAvecTva);

      // ACT
      await viewModel.fetchProfil();

      // ASSERT
      expect(viewModel.isTvaApplicable, true);
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après fetch réussi', () async {
      // ARRANGE
      final testProfil = ProfilEntreprise(
        id: 'profil-1',
        userId: 'user-1',
        nomEntreprise: 'Test',
        nomGerant: 'Test',
        adresse: 'Test',
        codePostal: '75000',
        ville: 'Paris',
        siret: '12345678901234',
        email: 'test@test.fr',
      );

      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => testProfil);

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      await viewModel.fetchProfil();
      expect(viewModel.isLoading, false);
    });
  });
}
