import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../pay/domain/payment.dart';
import '../../pay/state/payment_flow_provider.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/bank_error_view.dart';
import '../../../core/errors/bank_error.dart';

/// Receipt and Share Screen (Feature F10)
class ReceiptScreen extends ConsumerWidget {
  final String paymentId;

  const ReceiptScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(paymentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipt'),
      ),
      body: FutureBuilder<Payment>(
        future: repo.getPayment(paymentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00796B)));
          }
          if (snapshot.hasError) {
            final error = snapshot.error is BankError
                ? snapshot.error as BankError
                : ServerFailureError(message: snapshot.error.toString());
            return BankErrorView(error: error);
          }

          final payment = snapshot.data!;
          final isSuccess = payment.status == PaymentStatus.success;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Status Icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: (isSuccess ? const Color(0xFF00C853) : Colors.orange).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSuccess ? Icons.check_circle_rounded : Icons.pending_rounded,
                            size: 40,
                            color: isSuccess ? const Color(0xFF00C853) : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          isSuccess ? 'Payment Successful' : 'Payment Processing',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          Money(payment.amountPaise).format(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF12302C),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        _detailRow('Paid to', payment.counterpartyName),
                        const SizedBox(height: 12),
                        _detailRow('UPI ID', payment.counterparty),
                        const SizedBox(height: 12),
                        _detailRow('Date & Time', DateFormatter.formatTimestamp(payment.createdAt)),
                        const SizedBox(height: 12),
                        if (payment.note.isNotEmpty) ...[
                          _detailRow('Note', payment.note),
                          const SizedBox(height: 12),
                        ],

                        // Copyable UPI Ref ID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('UPI Ref ID', style: TextStyle(color: Colors.black54, fontSize: 13)),
                            Row(
                              children: [
                                Text(
                                  payment.upiRef,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: payment.upiRef));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('UPI Reference copied!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF00796B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Share Button
                ElevatedButton.icon(
                  onPressed: () {
                    final shareText = '''
PayLite Transaction Receipt
--------------------------
Status: ${payment.status.name.toUpperCase()}
Amount: ${Money(payment.amountPaise).format()}
Paid to: ${payment.counterpartyName} (${payment.counterparty})
UPI Ref: ${payment.upiRef}
Date: ${DateFormatter.formatTimestamp(payment.createdAt)}
''';
                    Share.share(shareText, subject: 'Payment Receipt - ${payment.upiRef}');
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Receipt as Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
