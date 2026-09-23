import '../domain/payment.dart';
import '../../../core/network/fake_api_client.dart';

abstract class PaymentRepository {
  Future<Payment> pay({
    required String vpa,
    required int amountPaise,
    required String note,
    required String pinHash,
    required String idempotencyKey,
  });

  Future<Payment> getPayment(String id);

  Future<List<Payment>> getHistory({
    String? cursor,
    int limit = 20,
    String? filter,
    String? query,
  });
}

class FakePaymentRepository implements PaymentRepository {
  final FakeApiClient _apiClient;

  FakePaymentRepository({FakeApiClient? apiClient})
      : _apiClient = apiClient ?? FakeApiClient();

  @override
  Future<Payment> pay({
    required String vpa,
    required int amountPaise,
    required String note,
    required String pinHash,
    required String idempotencyKey,
  }) async {
    final response = await _apiClient.makePayment(
      vpa: vpa,
      amountPaise: amountPaise,
      note: note,
      pinHash: pinHash,
      idempotencyKey: idempotencyKey,
    );
    return Payment.fromJson(response);
  }

  @override
  Future<Payment> getPayment(String id) async {
    final response = await _apiClient.getPayment(id);
    return Payment.fromJson(response);
  }

  @override
  Future<List<Payment>> getHistory({
    String? cursor,
    int limit = 20,
    String? filter,
    String? query,
  }) async {
    final response = await _apiClient.getHistory(
      cursor: cursor,
      limit: limit,
      filter: filter,
      query: query,
    );
    final items = response['items'] as List<dynamic>;
    return items.map((item) => Payment.fromJson(item as Map<String, dynamic>)).toList();
  }
}
