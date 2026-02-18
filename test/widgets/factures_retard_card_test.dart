import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/widgets/dashboard/factures_retard_card.dart';
import 'package:erp_commercial/services/relance_service.dart';
import 'package:erp_commercial/models/facture_model.dart';
import 'package:erp_commercial/models/client_model.dart';

void main() {
  group('FacturesRetardCard', () {
    testWidgets('devrait afficher "Aucune facture en retard" quand vide',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: FacturesRetardCard(relances: []),
        ),
      ));

      expect(find.text("Aucune facture en retard"), findsOneWidget);
      expect(find.text("Tous les paiements sont à jour"), findsOneWidget);
    });

    testWidgets('devrait afficher le nombre de factures en retard',
        (tester) async {
      final relances = [
        RelanceInfo(
          facture: Facture(
            id: 'f1',
            userId: 'u1',
            numeroFacture: 'FAC-001',
            objet: 'Test 1',
            clientId: 'c1',
            dateEmission: DateTime(2024, 1, 1),
            dateEcheance: DateTime(2024, 2, 1),
            totalHt: Decimal.parse('1000'),
            remiseTaux: Decimal.zero,
            acompteDejaRegle: Decimal.zero,
          ),
          client: Client(
            id: 'c1',
            userId: 'u1',
            nomComplet: 'Client 1',
            adresse: '',
            codePostal: '',
            ville: '',
            telephone: '',
            email: 'c1@test.com',
          ),
          joursRetard: 30,
          resteAPayer: Decimal.parse('1000'),
          niveau: NiveauRelance.ferme,
        ),
        RelanceInfo(
          facture: Facture(
            id: 'f2',
            userId: 'u1',
            numeroFacture: 'FAC-002',
            objet: 'Test 2',
            clientId: 'c2',
            dateEmission: DateTime(2024, 1, 1),
            dateEcheance: DateTime(2024, 3, 1),
            totalHt: Decimal.parse('500'),
            remiseTaux: Decimal.zero,
            acompteDejaRegle: Decimal.zero,
          ),
          joursRetard: 10,
          resteAPayer: Decimal.parse('500'),
          niveau: NiveauRelance.amiable,
        ),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FacturesRetardCard(relances: relances),
          ),
        ),
      ));

      // Badge avec nombre
      expect(find.text("2"), findsOneWidget);

      // Titre
      expect(find.text("Factures en retard"), findsOneWidget);

      // Montant total
      expect(find.text("1500.00 €"), findsOneWidget);

      // Retard max
      expect(find.text("30 jours"), findsOneWidget);
    });

    testWidgets('devrait appeler onTap quand cliqué', (tester) async {
      bool tapped = false;

      final relances = [
        RelanceInfo(
          facture: Facture(
            id: 'f1',
            userId: 'u1',
            numeroFacture: 'FAC-001',
            objet: 'Test',
            clientId: 'c1',
            dateEmission: DateTime(2024, 1, 1),
            dateEcheance: DateTime(2024, 2, 1),
            totalHt: Decimal.parse('1000'),
            remiseTaux: Decimal.zero,
            acompteDejaRegle: Decimal.zero,
          ),
          joursRetard: 15,
          resteAPayer: Decimal.parse('1000'),
          niveau: NiveauRelance.ferme,
        ),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FacturesRetardCard(
              relances: relances,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ));

      await tester.tap(find.text("Factures en retard"));
      expect(tapped, true);
    });

    testWidgets('devrait afficher la légende des niveaux', (tester) async {
      final relances = [
        RelanceInfo(
          facture: Facture(
            id: 'f1',
            userId: 'u1',
            numeroFacture: 'FAC-001',
            objet: 'Test',
            clientId: 'c1',
            dateEmission: DateTime(2024, 1, 1),
            dateEcheance: DateTime(2024, 2, 1),
            totalHt: Decimal.parse('1000'),
            remiseTaux: Decimal.zero,
            acompteDejaRegle: Decimal.zero,
          ),
          joursRetard: 5,
          resteAPayer: Decimal.parse('1000'),
          niveau: NiveauRelance.amiable,
        ),
        RelanceInfo(
          facture: Facture(
            id: 'f2',
            userId: 'u1',
            numeroFacture: 'FAC-002',
            objet: 'Test 2',
            clientId: 'c2',
            dateEmission: DateTime(2024, 1, 1),
            dateEcheance: DateTime(2024, 3, 1),
            totalHt: Decimal.parse('2000'),
            remiseTaux: Decimal.zero,
            acompteDejaRegle: Decimal.zero,
          ),
          joursRetard: 50,
          resteAPayer: Decimal.parse('2000'),
          niveau: NiveauRelance.miseEnDemeure,
        ),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FacturesRetardCard(relances: relances),
          ),
        ),
      ));

      expect(find.text("Amiable (1)"), findsOneWidget);
      expect(find.text("Mise en demeure (1)"), findsOneWidget);
    });
  });
}
