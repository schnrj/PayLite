import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/requests_provider.dart';
import '../domain/collect_request.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/bank_error_view.dart';
import '../../../core/errors/bank_error.dart';

/// Money Requests (Incoming & Outgoing Collects) Screen (Feature F7)
class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showNewRequestDialog() {
    final vpaController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Request Money',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: vpaController,
                decoration: const InputDecoration(labelText: 'From UPI ID', hintText: 'friend@paylite'),
                validator: Validators.validateVpa,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ '),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (Optional)', hintText: 'Lunch, tickets'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final amount = Money.rupeesToPaise(double.parse(amountController.text));
                    Navigator.pop(ctx);
                    await ref.read(collectRequestsProvider.notifier).createRequest(
                          toVpa: vpaController.text.trim(),
                          amountPaise: amount,
                          note: noteController.text.trim(),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Collect request sent!')),
                    );
                  }
                },
                child: const Text('Send Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(collectRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Requests'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Incoming'),
            Tab(text: 'Sent Requests'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewRequestDialog,
        backgroundColor: const Color(0xFF00796B),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Request', style: TextStyle(color: Colors.white)),
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00796B))),
        error: (e, _) => BankErrorView(
          error: e is BankError ? e : ServerFailureError(message: e.toString()),
          onRetry: () => ref.read(collectRequestsProvider.notifier).refresh(),
        ),
        data: (requests) {
          final incoming = requests.where((r) => r.to == 'sachin@okpaylite').toList();
          final outgoing = requests.where((r) => r.from == 'sachin@okpaylite').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestList(incoming, isIncoming: true),
              _buildRequestList(outgoing, isIncoming: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestList(List<CollectRequest> list, {required bool isIncoming}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_unread_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              isIncoming ? 'No incoming requests' : 'No requests sent yet',
              style: const TextStyle(color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = list[index];
        final isPending = req.status == CollectStatus.pending;
        final isExpired = req.isExpired;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isIncoming ? req.fromName : req.to,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      Money(req.amountPaise).format(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF00796B),
                      ),
                    ),
                  ],
                ),
                if (req.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(req.note, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
                const SizedBox(height: 12),

                // Status or Action buttons
                if (isIncoming && isPending && !isExpired)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => ref.read(collectRequestsProvider.notifier).declineRequest(req.id),
                        child: const Text('Decline'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _payCollectRequest(req),
                        child: const Text('Pay Now'),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: req.status == CollectStatus.paid
                          ? Colors.green.shade50
                          : (isExpired ? Colors.grey.shade100 : Colors.orange.shade50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isExpired ? 'EXPIRED' : req.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: req.status == CollectStatus.paid
                            ? Colors.green.shade700
                            : (isExpired ? Colors.grey.shade700 : Colors.orange.shade700),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _payCollectRequest(CollectRequest req) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pay ${Money(req.amountPaise).format()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Paying to ${req.fromName} (${req.from})'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Enter UPI PIN', counterText: ''),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(collectRequestsProvider.notifier).payRequest(req.id, pinController.text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment completed successfully!')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
