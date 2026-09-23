import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/payment_flow_provider.dart';
import '../../../core/utils/money.dart';
import '../../../core/errors/bank_error.dart';

/// Secure UPI PIN Entry Screen (Feature F4, NFR Security)
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';
  final int _pinLength = 4;
  String? _errorMessage;

  void _onDigitPress(String digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += digit;
        _errorMessage = null;
      });
      if (_pin.length == _pinLength) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _submitPin() async {
    final notifier = ref.read(paymentFlowProvider.notifier);
    try {
      final payment = await notifier.confirmPayment(_pin);
      if (payment != null && mounted) {
        context.go('/pay/status/${payment.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pin = '';
          _errorMessage = e is BankError ? e.message : 'Payment failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(paymentFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter UPI PIN'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Paying ${flow.verifiedName}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              Money(flow.amountPaise).format(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12302C),
              ),
            ),
            const SizedBox(height: 32),

            // PIN Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final filled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? const Color(0xFF00796B) : Colors.grey.shade300,
                  ),
                );
              }),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],

            if (flow.isSubmitting) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Color(0xFF00796B)),
              const SizedBox(height: 8),
              const Text('Processing payment safely...', style: TextStyle(color: Colors.black54, fontSize: 13)),
            ],

            const Spacer(),

            // Custom Number Keypad
            Container(
              padding: const EdgeInsets.only(bottom: 24, top: 12),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  _keypadRow(['1', '2', '3']),
                  _keypadRow(['4', '5', '6']),
                  _keypadRow(['7', '8', '9']),
                  _keypadRow(['', '0', 'DEL']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keypadRow(List<String> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((item) {
        if (item.isEmpty) {
          return const SizedBox(width: 80, height: 60);
        }
        if (item == 'DEL') {
          return SizedBox(
            width: 80,
            height: 60,
            child: IconButton(
              icon: const Icon(Icons.backspace_outlined, size: 24),
              onPressed: _onBackspace,
            ),
          );
        }
        return SizedBox(
          width: 80,
          height: 60,
          child: TextButton(
            onPressed: () => _onDigitPress(item),
            child: Text(
              item,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF12302C)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
