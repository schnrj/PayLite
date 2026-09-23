import 'package:flutter/material.dart';
import '../../pay/domain/payment.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/date_format.dart';

class PaymentTile extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentTile({
    super.key,
    required this.payment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSent = payment.direction == PaymentDirection.sent;
    final isSuccess = payment.status == PaymentStatus.success;
    final isPending = payment.status == PaymentStatus.pending;

    final amountColor = isSent
        ? (isSuccess ? const Color(0xFF12302C) : Colors.black54)
        : const Color(0xFF00796B);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSent
                    ? Colors.red.withOpacity(0.08)
                    : const Color(0xFF00796B).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: isSent ? Colors.red.shade700 : const Color(0xFF00796B),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Counterparty & Note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.counterpartyName.isNotEmpty
                        ? payment.counterpartyName
                        : payment.counterparty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormatter.formatTimestamp(payment.createdAt),
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Amount & Status Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isSent ? '-' : '+'}${Money(payment.amountPaise).format()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 3),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.shade300, width: 0.5),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (!isSuccess)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade300, width: 0.5),
                    ),
                    child: const Text(
                      'FAILED',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
