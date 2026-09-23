import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/split_provider.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';

/// Bill Splitting Screen with equal/custom split and paise remainder handling (Feature F8)
class SplitScreen extends ConsumerStatefulWidget {
  const SplitScreen({super.key});

  @override
  ConsumerState<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends ConsumerState<SplitScreen> {
  final _totalController = TextEditingController();
  final _noteController = TextEditingController(text: 'Dinner split');

  @override
  void dispose() {
    _totalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showAddFriendDialog() {
    final vpaController = TextEditingController();
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Participant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name', hintText: 'Asha Kulkarni'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vpaController,
              decoration: const InputDecoration(labelText: 'UPI ID', hintText: 'asha.t@okaxis'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (vpaController.text.isNotEmpty) {
                ref.read(splitProvider.notifier).addParticipant(
                      vpaController.text.trim(),
                      nameController.text.trim().isEmpty ? vpaController.text.trim() : nameController.text.trim(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final split = ref.watch(splitProvider);
    final notifier = ref.read(splitProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill'),
        actions: [
          IconButton(
            tooltip: 'Add Friend',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: split.participants.length < 10 ? _showAddFriendDialog : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Bill Input
            TextField(
              controller: _totalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Total Bill Amount',
                prefixText: '₹ ',
                prefixStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF12302C)),
              ),
              onChanged: (val) {
                final rupees = double.tryParse(val) ?? 0.0;
                notifier.setTotal(Money.rupeesToPaise(rupees));
              },
            ),
            const SizedBox(height: 16),

            // Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'What is this for?', hintText: 'e.g. Pizza party'),
            ),
            const SizedBox(height: 20),

            // Equal vs Custom Toggle
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Split Equally')),
                      ButtonSegment(value: true, label: Text('Custom Amounts')),
                    ],
                    selected: {split.isCustomMode},
                    onSelectionChanged: (set) => notifier.toggleMode(set.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Participants Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participants (${split.participants.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Allocated: ${Money(split.sumOfParticipantsPaise).format()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: split.isValid ? const Color(0xFF00796B) : Colors.red,
                  ),
                ),
              ],
            ),
            if (split.differencePaise != 0 && split.totalPaise > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Difference: ${Money(split.differencePaise).format()} remaining to allocate',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),

            // Participant List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: split.participants.length,
              itemBuilder: (context, index) {
                final p = split.participants[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
                          child: Text(
                            p.name.isNotEmpty ? p.name[0] : '?',
                            style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(p.vpa, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (split.isCustomMode)
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: (p.amountPaise / 100.0).toStringAsFixed(2),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                prefixText: '₹',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (val) {
                                final rupees = double.tryParse(val) ?? 0.0;
                                notifier.updateParticipantAmount(p.id, Money.rupeesToPaise(rupees));
                              },
                            ),
                          )
                        else
                          Text(
                            Money(p.amountPaise).format(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        if (split.participants.length > 2) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                            onPressed: () => notifier.removeParticipant(p.id),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: split.isValid && !split.isSubmitting
                  ? () async {
                      await notifier.sendSplitRequests(_noteController.text.trim());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Split requests sent to all participants!')),
                        );
                        context.go('/requests');
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: split.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send Split Collect Requests'),
            ),
          ],
        ),
      ),
    );
  }
}
