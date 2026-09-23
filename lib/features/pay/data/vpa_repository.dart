import '../domain/vpa.dart';
import '../../../core/network/fake_api_client.dart';

abstract class VpaRepository {
  Future<Vpa> verify(String address);
}

class FakeVpaRepository implements VpaRepository {
  final FakeApiClient _apiClient;

  FakeVpaRepository({FakeApiClient? apiClient})
      : _apiClient = apiClient ?? FakeApiClient();

  @override
  Future<Vpa> verify(String address) async {
    final response = await _apiClient.verifyVpa(address);
    return Vpa.fromJson(response);
  }
}
