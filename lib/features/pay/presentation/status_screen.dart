import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/payment_status_provider.dart';
import '../domain/payment.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/bank_error_view.dart';
import '../../../core/errors/bank_error.dart';

/// Payment Status Screen handling non-binary state (SUCCESS / PENDING / FAILED) (Feature F6)
class StatusScreen extends ConsumerWidget {
  final String paymentId;

  const StatusScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusStream = ref.watch(paymentStatusProvider(paymentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
        automaticallyImplyLeading: false,
      ),
      body: statusStream.when(
        data: (payment) => _buildStatusContent(context, payment),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF00796B)),
              SizedBox(height: 16),
              Text('Connecting with banking switch...'),
            ],
          ),
        ),
        error: (e, _) => BankErrorView(
          error: e is BankError ? e : ServerFailureError(message: e.toString()),
          onRetry: () => ref.refresh(paymentStatusProvider(paymentId)),
        ),
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context, Payment payment) {
    final isSuccess = payment.status == PaymentStatus.success;
    final isPending = payment.status == PaymentStatus.pending;

    Color themeColor;
    IconData iconData;
    String title;
    String subtitle;

    if (isSuccess) {
      themeColor = const Color(0xFF00C853);
      iconData = Icons.check_circle_rounded;
      title = 'Payment Successful';
      subtitle = 'Transferred to ${payment.counterpartyName}';
    } else if (isPending) {
      themeColor = Colors.orange;
      iconData = Icons.pending_rounded;
      title = 'Payment Pending';
      subtitle = 'Bank switch is confirming your transaction. Polling updates...';
    } else {
      themeColor = Colors.red;
      iconData = Icons.cancel_rounded;
      title = 'Payment Failed';
      subtitle = 'Amount was not debited. Please try again.';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: isPending
                ? const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 4),
                  )
                : Icon(iconData, size: 64, color: themeColor),
          ),
          const SizedBox(height: 20),

          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: themeColor),
          ),
          const SizedBox(height: 8),

          Text(
            Money(payment.amountPaise).format(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF12302C)),
          ),
          const SizedBox(height: 12),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('UPI Ref ID: ', style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text(payment.upiRef, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 36),

          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFF00796B),
            ),
            child: const Text('Back to Home'),
          ),
          if (isSuccess) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/history/${payment.id}'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: const Color(0xFF00796B),
              ),
              child: const Text('View Full Receipt'),
            ),
          ],
        ],
      ),
    );
  }
}
