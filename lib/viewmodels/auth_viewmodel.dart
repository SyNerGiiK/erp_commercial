import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';
import '../core/base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final IAuthRepository _repository;

  AuthViewModel({IAuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  User? get currentUser => _repository.currentUser;

  Future<String?> signIn(String email, String password) async {
    return await _performAuthAction(() async {
      await _repository.signIn(email, password);
    });
  }

  Future<String?> signUp(String email, String password) async {
    return await _performAuthAction(() async {
      await _repository.signUp(email, password);
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
    notifyListeners(); // Important pour déclencher la redirection du Router
  }

  Future<String?> _performAuthAction(Future<void> Function() action) async {
    try {
      await action();
      notifyListeners(); // Déclenche la réévaluation du Router (redirect)
      return null; // Succès (pas d'erreur retournée)
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Une erreur inattendue est survenue.";
    }
  }
}
