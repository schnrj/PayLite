import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/payment.dart';
import '../data/payment_repository.dart';
import '../../account/state/account_provider.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return FakePaymentRepository();
});

class PaymentFlowState {
  final String vpa;
  final String verifiedName;
  final int amountPaise;
  final String note;
  final String idempotencyKey;
  final bool isSubmitting;
  final Payment? completedPayment;
  final Object? error;

  const PaymentFlowState({
    this.vpa = '',
    this.verifiedName = '',
    this.amountPaise = 0,
    this.note = '',
    required this.idempotencyKey,
    this.isSubmitting = false,
    this.completedPayment,
    this.error,
  });

  PaymentFlowState copyWith({
    String? vpa,
    String? verifiedName,
    int? amountPaise,
    String? note,
    String? idempotencyKey,
    bool? isSubmitting,
    Payment? completedPayment,
    Object? error,
  }) {
    return PaymentFlowState(
      vpa: vpa ?? this.vpa,
      verifiedName: verifiedName ?? this.verifiedName,
      amountPaise: amountPaise ?? this.amountPaise,
      note: note ?? this.note,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      completedPayment: completedPayment ?? this.completedPayment,
      error: error,
    );
  }
}

final paymentFlowProvider = StateNotifierProvider<PaymentFlowNotifier, PaymentFlowState>((ref) {
  return PaymentFlowNotifier(ref);
});

class PaymentFlowNotifier extends StateNotifier<PaymentFlowState> {
  final Ref _ref;
  static const _uuid = Uuid();

  PaymentFlowNotifier(this._ref)
      : super(PaymentFlowState(idempotencyKey: _uuid.v4()));

  void reset() {
    state = PaymentFlowState(idempotencyKey: _uuid.v4());
  }

  void setPaymentDetails({
    required String vpa,
    required String verifiedName,
    required int amountPaise,
    String note = '',
  }) {
    state = state.copyWith(
      vpa: vpa,
      verifiedName: verifiedName,
      amountPaise: amountPaise,
      note: note,
    );
  }

  /// Called on the Review screen: generates ONE unique idempotency key per review flow
  void regenerateIdempotencyKey() {
    state = state.copyWith(idempotencyKey: _uuid.v4());
  }

  Future<Payment?> confirmPayment(String pin) async {
    if (state.isSubmitting) return null; // Debounce double-tap prevention

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repo = _ref.read(paymentRepositoryProvider);
      // Hash or mask the PIN before sending
      final pinHash = 'hash_${pin.hashCode}';

      final payment = await repo.pay(
        vpa: state.vpa,
        amountPaise: state.amountPaise,
        note: state.note,
        pinHash: pinHash,
        idempotencyKey: state.idempotencyKey,
      );

      state = state.copyWith(
        isSubmitting: false,
        completedPayment: payment,
      );

      // Invalidate account balance cache to reflect new debited balance
      _ref.invalidate(accountProvider);

      return payment;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      rethrow;
    }
  }
}
