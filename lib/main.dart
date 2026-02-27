import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for kReleaseMode
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart'; // Pour PointerDeviceKind
import 'dart:ui'; // Added for PlatformDispatcher
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Custom Crashlytics (override FlutterError)
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (originalOnError != null) {
      originalOnError(details);
    }
    // Log silently to Supabase
    try {
      SupabaseConfig.client.from('crash_logs').insert({
        'error_message': details.exceptionAsString(),
        'stack_trace': details.stack?.toString(),
        'app_version': '1.0.0+1', // Hardcoded for now
      }).then((_) {});
    } catch (_) {}
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      SupabaseConfig.client.from('crash_logs').insert({
        'error_message': error.toString(),
        'stack_trace': stack.toString(),
        'app_version': '1.0.0+1',
      }).then((_) {});
    } catch (_) {}
    return true; // Prevents crash
  };

  // Initialisation Locale (Dates FR)
  await initializeDateFormatting('fr_FR', null);

  // Charger les variables d'environnement
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Aucun fichier .env trouvé ou erreur de chargement: $e");
  }

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
      scrollBehavior: AppScrollBehavior(),

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

/// Comportement de Scroll optimisé pour Web & Desktop
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  // Supprime l'effet "Glow" (Vague bleue) sur Android/Chrome
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
