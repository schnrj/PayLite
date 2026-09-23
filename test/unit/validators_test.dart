import 'package:flutter_test/flutter_test.dart';
import 'package:paylite/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validates and normalizes valid VPA', () {
      expect(Validators.isValidVpa('priya@paylite'), isTrue);
      expect(Validators.isValidVpa('sachin.raj_01@okaxis'), isTrue);
      expect(Validators.normalizeVpa('  Rahul@OKSBI  '), equals('rahul@oksbi'));
    });

    test('rejects invalid VPA addresses', () {
      expect(Validators.isValidVpa('invalid-vpa'), isFalse);
      expect(Validators.isValidVpa('@okaxis'), isFalse);
      expect(Validators.isValidVpa('priya@'), isFalse);
    });

    test('validates payment amounts within limits', () {
      expect(Validators.validateAmount('100.50'), isNull);
      expect(Validators.validateAmount('0'), contains('greater than ₹0'));
      expect(Validators.validateAmount('100001'), contains('exceeds single transaction limit'));
    });

    test('validates UPI PIN length', () {
      expect(Validators.validatePin('1234'), isNull);
      expect(Validators.validatePin('123456'), isNull);
      expect(Validators.validatePin('12'), contains('4 to 6 digits'));
      expect(Validators.validatePin('abcd'), contains('only numbers'));
    });
  });
}
