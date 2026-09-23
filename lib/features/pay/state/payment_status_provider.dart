import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/payment.dart';
import 'payment_flow_provider.dart';

/// Polling provider for payment status (SUCCESS / PENDING / FAILED)
/// Polls every 5s up to 2 minutes, auto-disposes on screen exit without timer leaks (Feature F6)
final paymentStatusProvider = StreamProvider.autoDispose.family<Payment, String>((ref, paymentId) async* {
  final repo = ref.read(paymentRepositoryProvider);
  final startTime = DateTime.now();

  while (true) {
    final payment = await repo.getPayment(paymentId);
    yield payment;

    // If final status reached or timeout reached (2 minutes)
    if (payment.status != PaymentStatus.pending) {
      break;
    }
    if (DateTime.now().difference(startTime).inSeconds >= 120) {
      break;
    }

    // Wait 5 seconds between polls
    await Future.delayed(const Duration(seconds: 5));
  }
});
