import 'package:intl/intl.dart';

/// Money representation strictly using integer paise as required by the specification.
class Money {
  final int paise;

  const Money(this.paise);

  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Formats the integer paise into Indian Rupee format (e.g. 50000 -> ₹500.00)
  String format() {
    final double rupees = paise / 100.0;
    return _inrFormatter.format(rupees);
  }

  /// Converts rupees string or double to paise integer
  static int rupeesToPaise(double rupees) {
    return (rupees * 100).round();
  }

  @override
  String toString() => format();
}
