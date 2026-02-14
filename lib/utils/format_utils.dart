import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

class FormatUtils {
  static final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  static final NumberFormat _qtyFormatter = NumberFormat('#,###.##', 'fr_FR');

  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  /// Formate un montant monétaire (ex: 1 250,50 €)
  static String currency(dynamic value) {
    if (value is Decimal) {
      return _currencyFormatter.format(value.toDouble());
    }
    return _currencyFormatter.format(value);
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
}
