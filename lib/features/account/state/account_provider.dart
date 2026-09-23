import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/account.dart';
import '../data/account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return FakeAccountRepository();
});

final accountProvider = AsyncNotifierProvider<AccountNotifier, Account>(() {
  return AccountNotifier();
});

class AccountNotifier extends AsyncNotifier<Account> {
  @override
  Future<Account> build() async {
    final repo = ref.read(accountRepositoryProvider);
    return await repo.getPrimaryAccount();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(accountRepositoryProvider);
      return await repo.getPrimaryAccount();
    });
  }
}
