import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../config/theme.dart';
import '../widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;

  Future<void> _submit() async {
    final vm = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Veuillez tout remplir")));
      return;
    }

    String? error;
    if (_isLogin) {
      error = await vm.signIn(email, password);
    } else {
      error = await vm.signUp(email, password);
    }

    // Vérification Context Safety après await
    if (!mounted) return;

    if (error != null) {
      // CAS ERREUR : On affiche le message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.error,
        ),
      );
    }
    // CAS SUCCÈS : Le Router gère la redirection
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO & TITRE
                const Icon(Icons.handyman, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  "ARTISAN 3.0",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Gestion simplifiée pour micro-entreprise",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // CARTE DE CONNEXION
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text(
                          _isLogin ? "CONNEXION" : "INSCRIPTION",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: "Email",
                          controller: _emailCtrl,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: "Mot de passe",
                          controller: _passCtrl,
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),
                        if (vm.isLoading)
                          const CircularProgressIndicator()
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _isLogin ? "SE CONNECTER" : "CRÉER UN COMPTE",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // SWITCH LOGIN / SIGNUP
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? "Pas encore de compte ? S'inscrire"
                        : "Déjà un compte ? Se connecter",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
