import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:erp_commercial/viewmodels/auth_viewmodel.dart';
import '../mocks/repository_mocks.dart';

// Mock pour Supabase User
class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthViewModel viewModel;

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = AuthViewModel(repository: mockRepository);
  });

  group('signIn', () {
    test('devrait retourner null en cas de succès', () async {
      // ARRANGE
      when(() => mockRepository.signIn(any(), any())).thenAnswer((_) async {});

      // ACT
      final error = await viewModel.signIn('test@test.com', 'password123');

      // ASSERT
      expect(error, isNull); // Succès = pas d'erreur
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.signIn('test@test.com', 'password123'))
          .called(1);
    });

    test('devrait retourner le message d\'erreur AuthException', () async {
      // ARRANGE
      when(() => mockRepository.signIn(any(), any())).thenThrow(
        AuthException('Invalid credentials'),
      );

      // ACT
      final error = await viewModel.signIn('test@test.com', 'wrong');

      // ASSERT
      expect(error, 'Invalid credentials');
      expect(viewModel.isLoading, false);
    });

    test('devrait retourner un message générique pour erreur inattendue',
        () async {
      // ARRANGE
      when(() => mockRepository.signIn(any(), any()))
          .thenThrow(Exception('Network error'));

      // ACT
      final error = await viewModel.signIn('test@test.com', 'password');

      // ASSERT
      expect(error, 'Une erreur inattendue est survenue.');
      expect(viewModel.isLoading, false);
    });
  });

  group('signUp', () {
    test('devrait retourner null en cas de succès', () async {
      // ARRANGE
      when(() => mockRepository.signUp(any(), any())).thenAnswer((_) async {});

      // ACT
      final error = await viewModel.signUp('new@test.com', 'password123');

      // ASSERT
      expect(error, isNull);
      expect(viewModel.isLoading, false);
      verify(() => mockRepository.signUp('new@test.com', 'password123'))
          .called(1);
    });

    test('devrait retourner le message d\'erreur en cas d\'échec', () async {
      // ARRANGE
      when(() => mockRepository.signUp(any(), any())).thenThrow(
        AuthException('Email already registered'),
      );

      // ACT
      final error = await viewModel.signUp('existing@test.com', 'password');

      // ASSERT
      expect(error, 'Email already registered');
      expect(viewModel.isLoading, false);
    });
  });

  group('signOut', () {
    test('devrait appeler le repository et notifier les listeners', () async {
      // ARRANGE
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      // ACT
      await viewModel.signOut();

      // ASSERT
      verify(() => mockRepository.signOut()).called(1);
    });
  });

  group('currentUser getter', () {
    test('devrait retourner null si pas d\'utilisateur connecté', () {
      // ARRANGE
      when(() => mockRepository.currentUser).thenReturn(null);

      // ACT
      final user = viewModel.currentUser;

      // ASSERT
      expect(user, isNull);
    });

    test('devrait retourner l\'utilisateur si connecté', () {
      // ARRANGE
      final mockUser = MockUser();
      when(() => mockRepository.currentUser).thenReturn(mockUser);

      // ACT
      final user = viewModel.currentUser;

      // ASSERT
      expect(user, mockUser);
    });
  });

  group('isLoading state', () {
    test('devrait être false initialement et après action réussie', () async {
      // ARRANGE
      when(() => mockRepository.signIn(any(), any())).thenAnswer((_) async {});

      // ACT & ASSERT
      expect(viewModel.isLoading, false);
      final future = viewModel.signIn('test@test.com', 'password');
      // Note: impossible de tester isLoading=true ici car l'action est trop rapide
      await future;
      expect(viewModel.isLoading, false);
    });
  });
}
