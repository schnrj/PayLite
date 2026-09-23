import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/split_group.dart';
import '../../requests/state/requests_provider.dart';

class SplitState {
  final int totalPaise;
  final bool isCustomMode;
  final List<SplitParticipant> participants;
  final bool isSubmitting;

  const SplitState({
    this.totalPaise = 0,
    this.isCustomMode = false,
    this.participants = const [],
    this.isSubmitting = false,
  });

  int get sumOfParticipantsPaise {
    return participants.fold(0, (sum, p) => sum + p.amountPaise);
  }

  int get differencePaise => totalPaise - sumOfParticipantsPaise;

  bool get isValid {
    if (totalPaise <= 0 || participants.length < 2) return false;
    return differencePaise == 0;
  }

  SplitState copyWith({
    int? totalPaise,
    bool? isCustomMode,
    List<SplitParticipant>? participants,
    bool? isSubmitting,
  }) {
    return SplitState(
      totalPaise: totalPaise ?? this.totalPaise,
      isCustomMode: isCustomMode ?? this.isCustomMode,
      participants: participants ?? this.participants,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final splitProvider = StateNotifierProvider<SplitNotifier, SplitState>((ref) {
  return SplitNotifier(ref);
});

class SplitNotifier extends StateNotifier<SplitState> {
  final Ref _ref;

  SplitNotifier(this._ref) : super(const SplitState()) {
    // Start with 2 default participants
    state = state.copyWith(
      participants: const [
        SplitParticipant(id: '1', vpa: 'priya@paylite', name: 'Priya Sharma', amountPaise: 0),
        SplitParticipant(id: '2', vpa: 'rahul@oksbi', name: 'Rahul Verma', amountPaise: 0),
      ],
    );
  }

  void setTotal(int totalPaise) {
    state = state.copyWith(totalPaise: totalPaise);
    if (!state.isCustomMode) {
      _recalculateEqualSplit();
    }
  }

  void toggleMode(bool isCustom) {
    state = state.copyWith(isCustomMode: isCustom);
    if (!isCustom) {
      _recalculateEqualSplit();
    }
  }

  void addParticipant(String vpa, String name) {
    if (state.participants.length >= 10) return; // Limit 2-10
    final updated = List<SplitParticipant>.from(state.participants);
    updated.add(SplitParticipant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vpa: vpa,
      name: name,
      amountPaise: 0,
    ));
    state = state.copyWith(participants: updated);
    if (!state.isCustomMode) {
      _recalculateEqualSplit();
    }
  }

  void removeParticipant(String id) {
    if (state.participants.length <= 2) return; // Minimum 2
    final updated = state.participants.where((p) => p.id != id).toList();
    state = state.copyWith(participants: updated);
    if (!state.isCustomMode) {
      _recalculateEqualSplit();
    }
  }

  void updateParticipantAmount(String id, int amountPaise) {
    final updated = state.participants.map((p) {
      return p.id == id ? p.copyWith(amountPaise: amountPaise) : p;
    }).toList();
    state = state.copyWith(participants: updated);
  }

  /// Edge Case: Split amounts in paise do not divide evenly (e.g. ₹100 / 3 = 33.33)
  /// Assign the extra paise to the first participant! (Spec line 532)
  void _recalculateEqualSplit() {
    final count = state.participants.length;
    if (count == 0 || state.totalPaise == 0) return;

    final basePaise = state.totalPaise ~/ count;
    final remainderPaise = state.totalPaise % count;

    final updated = <SplitParticipant>[];
    for (int i = 0; i < count; i++) {
      final p = state.participants[i];
      final amount = (i == 0) ? (basePaise + remainderPaise) : basePaise;
      updated.add(p.copyWith(amountPaise: amount));
    }

    state = state.copyWith(participants: updated);
  }

  Future<void> sendSplitRequests(String note) async {
    state = state.copyWith(isSubmitting: true);
    final repo = _ref.read(collectRepositoryProvider);

    for (final p in state.participants) {
      await repo.createRequest(
        toVpa: p.vpa,
        amountPaise: p.amountPaise,
        note: 'Split: $note',
      );
    }

    _ref.invalidate(collectRequestsProvider);
    state = state.copyWith(isSubmitting: false);
  }
}
