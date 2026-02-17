import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:erp_commercial/utils/format_utils.dart';

void main() {
  group('FormatUtils - currency', () {
    test('formate un Decimal en euros français', () {
      final value = Decimal.parse('1250.50');
      final result = FormatUtils.currency(value);
      // Vérifie que le résultat contient les éléments clés
      expect(result, contains('250,50'));
      expect(result, contains('€'));
      expect(result.replaceAll(RegExp(r'\s'), ''), '1250,50€');
    });

    test('formate un double en euros français', () {
      final result = FormatUtils.currency(1250.50);
      expect(result, contains('250,50'));
      expect(result, contains('€'));
    });

    test('formate un entier en euros français', () {
      final result = FormatUtils.currency(1000);
      expect(result, contains('1'));
      expect(result, contains('000,00'));
      expect(result, contains('€'));
    });

    test('formate zéro correctement', () {
      final result = FormatUtils.currency(Decimal.zero);
      expect(result, contains('0,00'));
      expect(result, contains('€'));
    });

    test('formate des montants négatifs', () {
      final value = Decimal.parse('-150.75');
      final result = FormatUtils.currency(value);
      expect(result, contains('-'));
      expect(result, contains('150,75'));
      expect(result, contains('€'));
    });

    test('formate des grands montants avec espaces', () {
      final value = Decimal.parse('1234567.89');
      final result = FormatUtils.currency(value);
      expect(result, contains('234'));
      expect(result, contains('567,89'));
      expect(result, contains('€'));
      // Sans espaces: 1234567,89€
      expect(result.replaceAll(RegExp(r'\s'), ''), '1234567,89€');
    });
  });

  group('FormatUtils - quantity', () {
    test('formate une quantité Decimal sans décimales inutiles', () {
      final value = Decimal.parse('10.00');
      expect(FormatUtils.quantity(value), '10');
    });

    test('formate une quantité Decimal avec décimales', () {
      final value = Decimal.parse('10.5');
      expect(FormatUtils.quantity(value), '10,5');
    });

    test('formate un double avec décimales', () {
      expect(FormatUtils.quantity(25.75), '25,75');
    });

    test('formate un entier', () {
      expect(FormatUtils.quantity(100), '100');
    });

    test('formate des grands nombres avec séparateurs', () {
      final value = Decimal.parse('1234.56');
      final result = FormatUtils.quantity(value);
      expect(result, contains('234,56'));
      expect(result.replaceAll(RegExp(r'\s'), ''), '1234,56');
    });

    test('formate zéro', () {
      expect(FormatUtils.quantity(Decimal.zero), '0');
    });
  });

  group('FormatUtils - date', () {
    test('formate une date au format français dd/MM/yyyy', () {
      final date = DateTime(2025, 12, 31);
      expect(FormatUtils.date(date), '31/12/2025');
    });

    test('formate une date avec jour et mois sur 2 chiffres', () {
      final date = DateTime(2025, 1, 5);
      expect(FormatUtils.date(date), '05/01/2025');
    });

    test('retourne "-" pour une date nulle', () {
      expect(FormatUtils.date(null), '-');
    });

    test('formate la date du jour correctement', () {
      final today = DateTime(2026, 2, 17);
      expect(FormatUtils.date(today), '17/02/2026');
    });
  });

  group('FormatUtils - dateTime', () {
    test('formate date et heure au format français', () {
      final dateTime = DateTime(2025, 12, 31, 14, 30);
      expect(FormatUtils.dateTime(dateTime), '31/12/2025 14:30');
    });

    test('formate heure avec zéros initiaux', () {
      final dateTime = DateTime(2025, 1, 5, 9, 5);
      expect(FormatUtils.dateTime(dateTime), '05/01/2025 09:05');
    });

    test('retourne "-" pour une date nulle', () {
      expect(FormatUtils.dateTime(null), '-');
    });

    test('formate minuit correctement', () {
      final dateTime = DateTime(2026, 2, 17, 0, 0);
      expect(FormatUtils.dateTime(dateTime), '17/02/2026 00:00');
    });

    test('formate midi correctement', () {
      final dateTime = DateTime(2026, 2, 17, 12, 0);
      expect(FormatUtils.dateTime(dateTime), '17/02/2026 12:00');
    });
  });
}
