import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

class FormatUtils {
  static final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  static final NumberFormat _qtyFormatter = NumberFormat('#,###.##', 'fr_FR');

  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormatter =
      DateFormat('MMMM yyyy', 'fr_FR');
  static final DateFormat _shortDateFormatter = DateFormat('dd MMM', 'fr_FR');

  /// Formate un montant monétaire (ex: 1 250,50 €)
  static String currency(dynamic value) {
    if (value is Decimal) {
      return _currencyFormatter.format(value.toDouble());
    }
    return _currencyFormatter.format(value);
  }

  /// Formate un montant sans symbole (ex: 1 250,50)
  static String amount(Decimal value) {
    return NumberFormat('#,##0.00', 'fr_FR').format(value.toDouble());
  }

  /// Formate une quantité (évite 10.00 -> 10)
  static String quantity(dynamic value) {
    if (value is Decimal) {
      return _qtyFormatter.format(value.toDouble());
    }
    return _qtyFormatter.format(value);
  }

  /// Formate une date (dd/MM/yyyy)
  static String date(DateTime? date) {
    if (date == null) return "-";
    return _dateFormatter.format(date);
  }

  /// Formate date et heure
  static String dateTime(DateTime? date) {
    if (date == null) return "-";
    return _dateTimeFormatter.format(date);
  }

  /// Formate mois et année (ex: Février 2026)
  static String monthYear(DateTime? date) {
    if (date == null) return "-";
    final result = _monthYearFormatter.format(date);
    return result[0].toUpperCase() + result.substring(1);
  }

  /// Formate une date courte (ex: 17 Fév)
  static String shortDate(DateTime? date) {
    if (date == null) return "-";
    return _shortDateFormatter.format(date);
  }

  /// Formate un pourcentage (ex: 22,00%)
  static String percentage(dynamic value) {
    double d;
    if (value is Decimal) {
      d = value.toDouble();
    } else {
      d = (value as num).toDouble();
    }
    return '${d.toStringAsFixed(2).replaceAll('.', ',')}%';
  }

  /// Formate un numéro de téléphone français (ex: 06 12 34 56 78)
  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return "-";
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 2)} ${digits.substring(2, 4)} '
          '${digits.substring(4, 6)} ${digits.substring(6, 8)} '
          '${digits.substring(8, 10)}';
    }
    return phone;
  }

  /// Tronque un texte avec des points de suspension
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Durée relative (ex: "il y a 3 jours", "dans 2 heures")
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) {
      final absDiff = date.difference(now);
      if (absDiff.inDays > 30) {
        return "dans ${absDiff.inDays ~/ 30} mois";
      }
      if (absDiff.inDays > 0) {
        return "dans ${absDiff.inDays} jour${absDiff.inDays > 1 ? 's' : ''}";
      }
      if (absDiff.inHours > 0) {
        return "dans ${absDiff.inHours}h";
      }
      return "dans ${absDiff.inMinutes}min";
    }

    if (diff.inDays > 365) {
      return "il y a ${diff.inDays ~/ 365} an${diff.inDays ~/ 365 > 1 ? 's' : ''}";
    }
    if (diff.inDays > 30) {
      return "il y a ${diff.inDays ~/ 30} mois";
    }
    if (diff.inDays > 0) {
      return "il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}";
    }
    if (diff.inHours > 0) {
      return "il y a ${diff.inHours}h";
    }
    if (diff.inMinutes > 0) {
      return "il y a ${diff.inMinutes}min";
    }
    return "à l'instant";
  }
}
