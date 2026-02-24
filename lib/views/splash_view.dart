import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../config/theme.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 1. Permission Gate (Mobile only - Law 6)
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      try {
        await [
          Permission.camera,
          Permission.photos,
          Permission.notification,
        ].request();
      } catch (e) {
        debugPrint("Erreur permissions: $e");
      }
    }

    // Petite pause pour l'effet visuel (logo)
    await Future.delayed(const Duration(seconds: 2));

    // Vérification et redirection manuelle après le délai
    if (!mounted) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (authVM.currentUser != null) {
      context.go('/app/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handyman, size: 100, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
