import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static double? parseCurrency(String text) {
    if (text.isEmpty) return null;
    final cleaned = text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned);
  }
}
