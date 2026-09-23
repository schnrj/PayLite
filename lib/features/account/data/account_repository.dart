import '../domain/account.dart';
import '../../../core/network/fake_api_client.dart';

abstract class AccountRepository {
  Future<Account> getPrimaryAccount();
}

class FakeAccountRepository implements AccountRepository {
  final FakeApiClient _apiClient;

  FakeAccountRepository({FakeApiClient? apiClient})
      : _apiClient = apiClient ?? FakeApiClient();

  @override
  Future<Account> getPrimaryAccount() async {
    final response = await _apiClient.getPrimaryAccount();
    return Account.fromJson(response);
  }
}
