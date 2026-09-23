import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paylite/features/split/state/split_provider.dart';

void main() {
  group('SplitNotifier Logic', () {
    test('splits ₹100 evenly between 3 participants, allocating remainder paise to first', () {
      final container = ProviderContainer();
      final notifier = container.read(splitProvider.notifier);

      // Add a 3rd participant
      notifier.addParticipant('asha@okaxis', 'Asha');

      // ₹100.00 = 10000 paise
      notifier.setTotal(10000);

      final state = container.read(splitProvider);
      expect(state.participants.length, equals(3));

      // 10000 / 3 = 3333 with remainder 1. First gets 3334, other two get 3333
      expect(state.participants[0].amountPaise, equals(3334));
      expect(state.participants[1].amountPaise, equals(3333));
      expect(state.participants[2].amountPaise, equals(3333));

      expect(state.sumOfParticipantsPaise, equals(10000));
      expect(state.isValid, isTrue);
    });

    test('validates custom split sum matches total', () {
      final container = ProviderContainer();
      final notifier = container.read(splitProvider.notifier);

      notifier.setTotal(5000); // ₹50.00
      notifier.toggleMode(true); // Custom mode

      final p1 = container.read(splitProvider).participants[0].id;
      final p2 = container.read(splitProvider).participants[1].id;

      notifier.updateParticipantAmount(p1, 2000);
      notifier.updateParticipantAmount(p2, 2000);

      // Total 4000 != 5000 -> invalid
      expect(container.read(splitProvider).isValid, isFalse);
      expect(container.read(splitProvider).differencePaise, equals(1000));

      // Adjust to 3000 -> valid
      notifier.updateParticipantAmount(p2, 3000);
      expect(container.read(splitProvider).isValid, isTrue);
    });
  });
}
