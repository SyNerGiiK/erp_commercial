import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

abstract class IAuthRepository {
  User? get currentUser;
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();
}

class AuthRepository implements IAuthRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
