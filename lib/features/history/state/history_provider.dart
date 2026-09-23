import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pay/domain/payment.dart';
import '../../pay/state/payment_flow_provider.dart';

class HistoryState {
  final List<Payment> items;
  final String filter; // 'ALL', 'SENT', 'RECEIVED', 'FAILED'
  final String query;
  final bool isLoading;
  final Object? error;

  const HistoryState({
    this.items = const [],
    this.filter = 'ALL',
    this.query = '',
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<Payment>? items,
    String? filter,
    String? query,
    bool? isLoading,
    Object? error,
  }) {
    return HistoryState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const HistoryState()) {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(paymentRepositoryProvider);
      final items = await repo.getHistory(
        filter: state.filter == 'ALL' ? null : state.filter,
        query: state.query,
      );
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  void setFilter(String filter) {
    if (state.filter != filter) {
      state = state.copyWith(filter: filter);
      fetchHistory();
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(query: query);
    fetchHistory();
  }
}
