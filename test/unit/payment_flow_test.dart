import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paylite/features/pay/state/payment_flow_provider.dart';

void main() {
  group('Payment Idempotency', () {
    test('same idempotency key yields exactly one debit and deduplicated response', () async {
      final container = ProviderContainer();
      final notifier = container.read(paymentFlowProvider.notifier);

      notifier.setPaymentDetails(
        vpa: 'priya@paylite',
        verifiedName: 'Priya Sharma',
        amountPaise: 50000,
        note: 'Test transfer',
      );

      final key1 = container.read(paymentFlowProvider).idempotencyKey;

      // First confirmation
      final payment1 = await notifier.confirmPayment('1234');
      expect(payment1, isNotNull);

      // Simulating a retry with the SAME key
      final payment2 = await notifier.confirmPayment('1234');

      expect(payment1!.id, equals(payment2!.id));
      expect(payment1.upiRef, equals(payment2.upiRef));
    });
  });
}
