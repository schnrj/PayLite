import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/payment_flow_provider.dart';
import '../state/vpa_lookup_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/bank_error_view.dart';
import '../../../core/errors/bank_error.dart';

/// Enter VPA, amount, and note screen (Feature F4)
class PayScreen extends ConsumerStatefulWidget {
  final String? initialVpa;
  final double? fixedAmountRupees;

  const PayScreen({
    super.key,
    this.initialVpa,
    this.fixedAmountRupees,
  });

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vpaController;
  late final TextEditingController _amountController;
  final _noteController = TextEditingController();

  String? _verifiedName;
  bool _isVerifying = false;
  String? _vpaError;

  @override
  void initState() {
    super.initState();
    _vpaController = TextEditingController(text: widget.initialVpa ?? '');
    _amountController = TextEditingController(
      text: widget.fixedAmountRupees != null ? widget.fixedAmountRupees!.toStringAsFixed(2) : '',
    );

    if (widget.initialVpa != null && widget.initialVpa!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _verifyVpa());
    }
  }

  @override
  void dispose() {
    _vpaController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _verifyVpa() async {
    final vpa = _vpaController.text.trim();
    if (!Validators.isValidVpa(vpa)) {
      setState(() {
        _vpaError = 'Enter a valid UPI ID (e.g. username@bank)';
        _verifiedName = null;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _vpaError = null;
    });

    try {
      final repo = ref.read(vpaRepositoryProvider);
      final verified = await repo.verify(vpa);
      setState(() {
        _verifiedName = verified.verifiedName;
        _isVerifying = false;
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _verifiedName = null;
        _vpaError = e is BankError ? e.message : 'No account found for this UPI ID';
      });
    }
  }

  void _proceedToReview() {
    if (_verifiedName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify the UPI ID before proceeding')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final amountRupees = double.parse(_amountController.text.replaceAll(',', ''));
      final amountPaise = Money.rupeesToPaise(amountRupees);

      ref.read(paymentFlowProvider.notifier).setPaymentDetails(
            vpa: _vpaController.text.trim(),
            verifiedName: _verifiedName!,
            amountPaise: amountPaise,
            note: _noteController.text.trim(),
          );

      context.push('/pay/review');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAmountLocked = widget.fixedAmountRupees != null && widget.fixedAmountRupees! > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // VPA Input & Verify
              TextFormField(
                controller: _vpaController,
                decoration: InputDecoration(
                  labelText: 'Recipient UPI ID',
                  hintText: 'e.g. priya@paylite',
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  suffixIcon: _isVerifying
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: _verifyVpa,
                          child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                ),
                validator: Validators.validateVpa,
              ),
              if (_vpaError != null) ...[
                const SizedBox(height: 6),
                Text(_vpaError!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
              ],

              // Verified Name badge
              if (_verifiedName != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00796B).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF00796B), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _verifiedName!,
                          style: const TextStyle(
                            color: Color(0xFF12302C),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                readOnly: isAmountLocked,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF12302C)),
                  helperText: isAmountLocked
                      ? 'Amount specified by scanned QR'
                      : 'Limit: Up to ₹1,00,000 per payment',
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: 16),

              // Note Input
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'e.g. Dinner, Grocery',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 32),

              // Proceed Button
              ElevatedButton(
                onPressed: _proceedToReview,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Proceed to Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
