import '../domain/collect_request.dart';
import '../../../core/network/fake_api_client.dart';

abstract class CollectRepository {
  Future<CollectRequest> createRequest({
    required String toVpa,
    required int amountPaise,
    String note = '',
  });

  Future<List<CollectRequest>> getRequests();

  Future<void> payRequest(String id, String pinHash);

  Future<void> declineRequest(String id);
}

class FakeCollectRepository implements CollectRepository {
  final FakeApiClient _apiClient;

  FakeCollectRepository({FakeApiClient? apiClient})
      : _apiClient = apiClient ?? FakeApiClient();

  @override
  Future<CollectRequest> createRequest({
    required String toVpa,
    required int amountPaise,
    String note = '',
  }) async {
    final response = await _apiClient.createCollectRequest(
      toVpa: toVpa,
      amountPaise: amountPaise,
      note: note,
    );
    return CollectRequest.fromJson(response);
  }

  @override
  Future<List<CollectRequest>> getRequests() async {
    final list = await _apiClient.getCollectRequests();
    return list.map((json) => CollectRequest.fromJson(json)).toList();
  }

  @override
  Future<void> payRequest(String id, String pinHash) async {
    await _apiClient.payCollectRequest(id, pinHash);
  }

  @override
  Future<void> declineRequest(String id) async {
    await _apiClient.declineCollectRequest(id);
  }
}
