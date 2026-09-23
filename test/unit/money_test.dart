import 'package:flutter_test/flutter_test.dart';
import 'package:paylite/core/utils/money.dart';

void main() {
  group('Money', () {
    test('formats integer paise correctly to INR', () {
      const money = Money(50000);
      expect(money.format(), contains('500.00'));
    });

    test('converts rupees to paise accurately', () {
      expect(Money.rupeesToPaise(100.50), equals(10050));
      expect(Money.rupeesToPaise(1.00), equals(100));
    });
  });
}
