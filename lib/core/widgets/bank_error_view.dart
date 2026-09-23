import 'package:flutter/material.dart';
import '../errors/bank_error.dart';

/// User-friendly, plain language error display with retry capability (Baseline B4 & B7)
class BankErrorView extends StatelessWidget {
  final BankError error;
  final VoidCallback? onRetry;

  const BankErrorView({
    super.key,
    required this.error,
    this.onRetry,
  });

  IconData _getIcon() {
    return switch (error) {
      NetworkConnectionError() => Icons.wifi_off_rounded,
      AuthError() => Icons.lock_clock_rounded,
      AccountLockedError() => Icons.block_rounded,
      InsufficientFundsError() => Icons.account_balance_wallet_outlined,
      LimitExceededError() => Icons.warning_amber_rounded,
      VpaNotFoundError() => Icons.person_search_rounded,
      KeyReusedError() => Icons.repeat_rounded,
      ExpiredError() => Icons.timer_off_rounded,
      NotFoundError() => Icons.search_off_rounded,
      ServerFailureError() => Icons.cloud_off_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                size: 48,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            if (error.traceId != null) ...[
              const SizedBox(height: 6),
              Text(
                'Reference: ${error.traceId}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
