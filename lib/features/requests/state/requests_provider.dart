import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/collect_request.dart';
import '../data/collect_repository.dart';
import '../../account/state/account_provider.dart';

final collectRepositoryProvider = Provider<CollectRepository>((ref) {
  return FakeCollectRepository();
});

final collectRequestsProvider = AsyncNotifierProvider<CollectRequestsNotifier, List<CollectRequest>>(() {
  return CollectRequestsNotifier();
});

class CollectRequestsNotifier extends AsyncNotifier<List<CollectRequest>> {
  @override
  Future<List<CollectRequest>> build() async {
    final repo = ref.read(collectRepositoryProvider);
    return await repo.getRequests();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(collectRepositoryProvider);
      return await repo.getRequests();
    });
  }

  Future<void> createRequest({
    required String toVpa,
    required int amountPaise,
    String note = '',
  }) async {
    final repo = ref.read(collectRepositoryProvider);
    await repo.createRequest(toVpa: toVpa, amountPaise: amountPaise, note: note);
    await refresh();
  }

  Future<void> payRequest(String id, String pin) async {
    final repo = ref.read(collectRepositoryProvider);
    await repo.payRequest(id, 'hash_${pin.hashCode}');
    ref.invalidate(accountProvider);
    await refresh();
  }

  Future<void> declineRequest(String id) async {
    final repo = ref.read(collectRepositoryProvider);
    await repo.declineRequest(id);
    await refresh();
  }
}
