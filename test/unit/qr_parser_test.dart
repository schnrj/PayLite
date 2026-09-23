import 'package:flutter_test/flutter_test.dart';
import 'package:paylite/features/pay/domain/qr_parser.dart';

void main() {
  group('QrParser', () {
    test('parses standard upi://pay URI correctly', () {
      const qrData = 'upi://pay?pa=ramesh.vendor@paylite&pn=Ramesh%20Vegetables&am=150.00';
      final payload = QrParser.parse(qrData);

      expect(payload.vpa, equals('ramesh.vendor@paylite'));
      expect(payload.payeeName, equals('Ramesh Vegetables'));
      expect(payload.fixedAmountRupees, equals(150.00));
      expect(payload.hasFixedAmount, isTrue);
    });

    test('parses upi://pay URI without fixed amount', () {
      const qrData = 'upi://pay?pa=priya@paylite&pn=Priya%20Sharma';
      final payload = QrParser.parse(qrData);

      expect(payload.vpa, equals('priya@paylite'));
      expect(payload.hasFixedAmount, isFalse);
    });

    test('throws FormatException on malformed QR code', () {
      expect(
        () => QrParser.parse('https://example.com/not-upi'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
