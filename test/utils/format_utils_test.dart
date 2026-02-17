import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:erp_commercial/utils/format_utils.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

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

  group('FormatUtils - amount', () {
    test('formate un montant sans symbole monétaire', () {
      final result = FormatUtils.amount(Decimal.parse('1250.50'));
      expect(result, contains('250,50'));
      expect(result, isNot(contains('€')));
    });

    test('formate zéro', () {
      final result = FormatUtils.amount(Decimal.zero);
      expect(result, contains('0,00'));
    });
  });

  group('FormatUtils - percentage', () {
    test('formate un pourcentage Decimal', () {
      final result = FormatUtils.percentage(Decimal.parse('22'));
      expect(result, '22,00%');
    });

    test('formate un pourcentage double', () {
      final result = FormatUtils.percentage(10.5);
      expect(result, '10,50%');
    });

    test('formate un pourcentage entier', () {
      final result = FormatUtils.percentage(0);
      expect(result, '0,00%');
    });
  });

  group('FormatUtils - phone', () {
    test('formate un numéro français à 10 chiffres', () {
      expect(FormatUtils.phone('0612345678'), '06 12 34 56 78');
    });

    test('gère les numéros avec espaces existants', () {
      expect(FormatUtils.phone('06 12 34 56 78'), '06 12 34 56 78');
    });

    test('retourne "-" pour null', () {
      expect(FormatUtils.phone(null), '-');
    });

    test('retourne "-" pour chaîne vide', () {
      expect(FormatUtils.phone(''), '-');
    });

    test('retourne le numéro tel quel si pas 10 chiffres', () {
      expect(FormatUtils.phone('+33612345678'), '+33612345678');
    });
  });

  group('FormatUtils - truncate', () {
    test('tronque un texte long', () {
      expect(FormatUtils.truncate('Hello World', 5), 'Hello...');
    });

    test('ne tronque pas un texte court', () {
      expect(FormatUtils.truncate('Hello', 10), 'Hello');
    });

    test('gère la longueur exacte', () {
      expect(FormatUtils.truncate('Hello', 5), 'Hello');
    });
  });

  group('FormatUtils - shortDate', () {
    test('formate une date courte', () {
      final date = DateTime(2026, 2, 17);
      final result = FormatUtils.shortDate(date);
      expect(result, contains('17'));
    });

    test('retourne "-" pour null', () {
      expect(FormatUtils.shortDate(null), '-');
    });
  });

  group('FormatUtils - monthYear', () {
    test('formate mois et année avec majuscule', () {
      final date = DateTime(2026, 2, 17);
      final result = FormatUtils.monthYear(date);
      // Le résultat dépend de la locale mais doit commencer par une majuscule
      expect(result[0], result[0].toUpperCase());
      expect(result, contains('2026'));
    });

    test('retourne "-" pour null', () {
      expect(FormatUtils.monthYear(null), '-');
    });
  });

  group('FormatUtils - relativeDate', () {
    test('retourne "à l\'instant" pour maintenant', () {
      final result = FormatUtils.relativeDate(DateTime.now());
      expect(result, "à l'instant");
    });

    test('retourne "il y a X jours" pour le passé', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 3));
      final result = FormatUtils.relativeDate(pastDate);
      expect(result, 'il y a 3 jours');
    });

    test('retourne "il y a 1 jour" pour hier', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = FormatUtils.relativeDate(yesterday);
      expect(result, 'il y a 1 jour');
    });

    test('retourne "dans X jours" pour le futur', () {
      final futureDate = DateTime.now().add(const Duration(days: 5, hours: 1));
      final result = FormatUtils.relativeDate(futureDate);
      expect(result, 'dans 5 jours');
    });

    test('gère les heures', () {
      final hoursAgo = DateTime.now().subtract(const Duration(hours: 3));
      final result = FormatUtils.relativeDate(hoursAgo);
      expect(result, 'il y a 3h');
    });

    test('gère les mois', () {
      final monthsAgo = DateTime.now().subtract(const Duration(days: 60));
      final result = FormatUtils.relativeDate(monthsAgo);
      expect(result, contains('mois'));
    });
  });
}
