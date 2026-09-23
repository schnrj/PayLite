import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/payment_flow_provider.dart';
import '../../../core/utils/money.dart';

/// Review transaction details & generate unique Idempotency Key (Feature F5)
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    // Generate fresh Idempotency Key ONCE per entry to this review screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentFlowProvider.notifier).regenerateIdempotencyKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(paymentFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Total Amount', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      Money(flow.amountPaise).format(),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF12302C),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _summaryRow('Payee Name', flow.verifiedName),
                    const SizedBox(height: 14),
                    _summaryRow('Payee UPI ID', flow.vpa),
                    if (flow.note.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _summaryRow('Note', flow.note),
                    ],
                    const SizedBox(height: 14),
                    _summaryRow('Security Key', '${flow.idempotencyKey.substring(0, 8)}...'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.push('/pay/pin');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFF00796B),
              ),
              child: const Text('Confirm & Enter UPI PIN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
