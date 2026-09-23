import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/bank_error_view.dart';
import '../../../core/errors/bank_error.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController(text: 'CUST84920');
  final _pinController = TextEditingController(text: '1234');
  bool _obscurePin = true;

  @override
  void dispose() {
    _customerIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(sessionProvider.notifier).login(
            _customerIdController.text.trim(),
            _pinController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionProvider);
    final isLoading = sessionAsync.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00796B).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 44,
                      color: Color(0xFF00796B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to PayLite',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF12302C),
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Instant UPI-style payments with zero waiting',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // Customer ID Field
                  TextFormField(
                    controller: _customerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Customer ID',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: Validators.validateCustomerId,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // UPI PIN Field
                  TextFormField(
                    controller: _pinController,
                    obscureText: _obscurePin,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'App PIN / Passcode',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                      ),
                    ),
                    validator: Validators.validatePin,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Sign In & Bind Device'),
                  ),

                  // Error Display
                  if (sessionAsync.hasError) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sessionAsync.error is BankError
                                  ? (sessionAsync.error as BankError).message
                                  : sessionAsync.error.toString(),
                              style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
