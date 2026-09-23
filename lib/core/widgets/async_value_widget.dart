import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/bank_error.dart';
import 'bank_error_view.dart';
import 'skeleton.dart';

/// Helper widget that automatically renders Loading (skeleton), Error (with retry), and Data states (Baseline B4)
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Skeleton(height: 100, width: double.infinity),
            ),
          ),
      error: (e, stack) {
        final bankError = e is BankError ? e : ServerFailureError(message: e.toString());
        return BankErrorView(error: bankError, onRetry: onRetry);
      },
    );
  }
}
