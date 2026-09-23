import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../state/account_provider.dart';
import '../../history/state/history_provider.dart';
import '../../history/widgets/payment_tile.dart';
import '../../auth/state/session_provider.dart';

/// Main Dashboard Screen (Feature F2)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(accountProvider);
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PayLite'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log out'),
                  content: const Text('Are you sure you want to log out of PayLite?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(sessionProvider.notifier).logout();
                      },
                      child: const Text('Log out', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF00796B),
        onRefresh: () async {
          await ref.read(accountProvider.notifier).refresh();
          await ref.read(historyProvider.notifier).fetchHistory();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              BalanceCard(
                balancePaise: accountAsync.value?.balancePaise,
                primaryVpa: accountAsync.value?.primaryVpa,
                maskedNumber: accountAsync.value?.maskedNumber,
                isLoading: accountAsync.isLoading,
              ),
              const SizedBox(height: 20),

              // Quick Actions
              QuickActions(
                actions: [
                  QuickActionItem(
                    label: 'Scan QR',
                    icon: Icons.qr_code_scanner_rounded,
                    tooltip: 'Scan UPI QR code',
                    onTap: () => context.push('/scan'),
                  ),
                  QuickActionItem(
                    label: 'Pay VPA',
                    icon: Icons.send_rounded,
                    tooltip: 'Pay to any UPI ID',
                    onTap: () => context.push('/pay'),
                  ),
                  QuickActionItem(
                    label: 'Request',
                    icon: Icons.call_received_rounded,
                    tooltip: 'Request money from a friend',
                    onTap: () => context.push('/requests'),
                  ),
                  QuickActionItem(
                    label: 'Split Bill',
                    icon: Icons.group_work_rounded,
                    tooltip: 'Split bill among friends',
                    onTap: () => context.push('/split'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Payments Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Payments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF12302C),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/history'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Payments List Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: historyState.items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text('No payments yet', style: TextStyle(color: Colors.black45)),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: historyState.items.take(5).length,
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
            ],
          ),
        ),
      ),
    );
  }
}
