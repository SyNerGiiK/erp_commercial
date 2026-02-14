import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// CONFIG
import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'config/dependency_injection.dart';
import 'config/router.dart';

// VIEWMODELS
import 'viewmodels/auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Supabase
  await SupabaseConfig.initialize();

  // Initialisation Locale (Dates FR)
  await initializeDateFormatting('fr_FR', null);

  runApp(
    MultiProvider(
      providers: DependencyInjection.providers,
      child: const ArtisanApp(),
    ),
  );
}

class ArtisanApp extends StatelessWidget {
  const ArtisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération du VM Auth pour le passer au Router (Redirection dynamique)
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final router = AppRouter.createRouter(authViewModel);

    return MaterialApp.router(
      title: 'Artisan 3.0',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Configuration GoRouter
      routerConfig: router,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
    );
  }
}
