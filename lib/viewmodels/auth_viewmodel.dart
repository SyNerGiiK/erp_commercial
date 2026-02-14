import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final IAuthRepository _repository = AuthRepository();

  User? get currentUser => _repository.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    _isLoading = true;
    notifyListeners();
    try {
      await action();
      return null; // Succès (pas d'erreur retournée)
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Une erreur inattendue est survenue.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
