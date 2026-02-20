import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:erp_commercial/widgets/success_overlay.dart';

void main() {
  // Désactiver les animations réelles dans les tests
  setUp(() {
    Animate.restartOnHotReload = false;
  });

  /// Helper : crée un widget MaterialApp avec un bouton qui déclenche l'overlay.
  Widget buildTestApp({
    required String title,
    String? subtitle,
    Duration duration = const Duration(milliseconds: 500),
    VoidCallback? onDismissed,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              SuccessOverlay.show(
                context: context,
                title: title,
                subtitle: subtitle,
                duration: duration,
                onDismissed: onDismissed ?? () {},
              );
            },
            child: const Text('Show'),
          );
        },
      ),
    );
  }

  group('SuccessOverlay - affichage et contenu', () {
    testWidgets('devrait afficher le titre dans l\'overlay', (tester) async {
      await tester.pumpWidget(buildTestApp(title: 'Facture validée !'));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Facture validée !'), findsOneWidget);

      // Avancer au-delà du timer auto-dismiss pour éviter pending timers
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('devrait afficher le sous-titre si fourni', (tester) async {
      await tester.pumpWidget(buildTestApp(
        title: 'Succès',
        subtitle: 'Le document a été enregistré.',
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Succès'), findsOneWidget);
      expect(find.text('Le document a été enregistré.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('devrait ne pas afficher de sous-titre si null',
        (tester) async {
      await tester.pumpWidget(buildTestApp(title: 'OK'));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('OK'), findsOneWidget);
      // Pas de sous-titre — seuls le bouton + titre
      expect(find.byType(Text), findsNWidgets(2));

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('devrait contenir l\'icône check', (tester) async {
      await tester.pumpWidget(buildTestApp(title: 'Done'));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('devrait se fermer automatiquement après la durée',
        (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(buildTestApp(
        title: 'Auto-close',
        duration: const Duration(milliseconds: 500),
        onDismissed: () => dismissed = true,
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(dismissed, isFalse);

      // Avancer le temps au-delà de la durée
      await tester.pump(const Duration(milliseconds: 600));
      expect(dismissed, isTrue);
    });

    testWidgets('devrait se fermer au tap (dismiss manuel)', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(buildTestApp(
        title: 'Tap to close',
        duration: const Duration(seconds: 10),
        onDismissed: () => dismissed = true,
      ));

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap sur l'overlay (le texte du titre)
      await tester.tap(find.text('Tap to close'));
      await tester.pump();

      expect(dismissed, isTrue);
    });
  });
}
