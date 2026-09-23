import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/history_provider.dart';
import '../widgets/payment_tile.dart';
import '../../../core/widgets/skeleton.dart';

/// Infinite scroll transaction history with filters and search (Feature F9)
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final historyNotifier = ref.read(historyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: historyNotifier.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by name, UPI ID, or note...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('ALL', 'All', historyState.filter, historyNotifier.setFilter),
                      const SizedBox(width: 8),
                      _filterChip('SENT', 'Sent', historyState.filter, historyNotifier.setFilter),
                      const SizedBox(width: 8),
                      _filterChip('RECEIVED', 'Received', historyState.filter, historyNotifier.setFilter),
                      const SizedBox(width: 8),
                      _filterChip('FAILED', 'Failed', historyState.filter, historyNotifier.setFilter),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Payment List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => historyNotifier.fetchHistory(),
              color: const Color(0xFF00796B),
              child: historyState.isLoading && historyState.items.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: 8,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Skeleton.circular(size: 40),
                            SizedBox(width: 12),
                            Expanded(child: Skeleton(height: 18)),
                            SizedBox(width: 12),
                            Skeleton(height: 18, width: 60),
                          ],
                        ),
                      ),
                    )
                  : historyState.items.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No transactions found', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: historyState.items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final payment = historyState.items[index];
                            return PaymentTile(
                              payment: payment,
                              onTap: () => context.push('/history/${payment.id}'),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label, String currentFilter, Function(String) onSelect) {
    final isSelected = currentFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(filterKey),
      selectedColor: const Color(0xFF00796B),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
