import 'dart:async';
import '../errors/bank_error.dart';

/// In-memory mock backend client providing realistic simulation of all 8 PayLite endpoints
/// Includes idempotency cache, PENDING->SUCCESS status transitions, verification, and collect requests.
class FakeApiClient {
  static final FakeApiClient _instance = FakeApiClient._internal();
  factory FakeApiClient() => _instance;

  FakeApiClient._internal() {
    _initSampleData();
  }

  // Account Data
  int primaryBalancePaise = 2450000; // ₹24,500.00
  final String primaryVpa = "sachin@okpaylite";
  final String maskedNumber = "•••• 4892";

  // Registered VPAs
  final Map<String, Map<String, String>> _vpaDirectory = {};

  // Payments Ledger
  final List<Map<String, dynamic>> _payments = [];

  // Idempotency cache: key -> response
  final Map<String, Map<String, dynamic>> _idempotencyCache = {};

  // Collect Requests
  final List<Map<String, dynamic>> _collectRequests = [];

  void _initSampleData() {
    _vpaDirectory['priya@paylite'] = {
      'address': 'priya@paylite',
      'verifiedName': 'Priya Sharma',
      'bankName': 'PayLite Bank',
    };
    _vpaDirectory['ramesh.vendor@paylite'] = {
      'address': 'ramesh.vendor@paylite',
      'verifiedName': 'Ramesh Vegetables',
      'bankName': 'HDFC Bank',
    };
    _vpaDirectory['asha.t@okaxis'] = {
      'address': 'asha.t@okaxis',
      'verifiedName': 'Asha Kulkarni',
      'bankName': 'Axis Bank',
    };
    _vpaDirectory['rahul@oksbi'] = {
      'address': 'rahul@oksbi',
      'verifiedName': 'Rahul Verma',
      'bankName': 'State Bank of India',
    };

    // Initial payments
    _payments.add({
      'id': 'pay_101',
      'direction': 'SENT',
      'counterparty': 'ramesh.vendor@paylite',
      'counterpartyName': 'Ramesh Vegetables',
      'amountPaise': 34000, // ₹340.00
      'note': 'Vegetables & grocery',
      'status': 'SUCCESS',
      'upiRef': 'UPI49201948201',
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toUtc().toIso8601String(),
    });

    _payments.add({
      'id': 'pay_102',
      'direction': 'RECEIVED',
      'counterparty': 'priya@paylite',
      'counterpartyName': 'Priya Sharma',
      'amountPaise': 85000, // ₹850.00
      'note': 'Dinner split (Pizza)',
      'status': 'SUCCESS',
      'upiRef': 'UPI49201948202',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toUtc().toIso8601String(),
    });

    _payments.add({
      'id': 'pay_103',
      'direction': 'SENT',
      'counterparty': 'rahul@oksbi',
      'counterpartyName': 'Rahul Verma',
      'amountPaise': 150000, // ₹1,500.00
      'note': 'Book subscription',
      'status': 'SUCCESS',
      'upiRef': 'UPI49201948203',
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).toUtc().toIso8601String(),
    });

    // Sample Collect Request
    _collectRequests.add({
      'id': 'col_201',
      'from': 'priya@paylite',
      'fromName': 'Priya Sharma',
      'to': 'sachin@okpaylite',
      'amountPaise': 45000, // ₹450.00
      'note': 'Weekend Movie ticket',
      'status': 'PENDING',
      'expiresAt': DateTime.now().add(const Duration(hours: 48)).toUtc().toIso8601String(),
    });
  }

  // POST /auth/login
  Future<Map<String, dynamic>> login(String customerId, String pin) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (customerId.trim().isEmpty || pin.length < 4) {
      throw const AuthError(message: 'Invalid Customer ID or PIN format');
    }
    if (pin == '0000') {
      throw const AccountLockedError(message: 'Your account is locked. Please contact support.');
    }
    return {
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'deviceId': 'device_mock_arm64_01',
      'customerId': customerId,
    };
  }

  // GET /accounts/primary
  Future<Map<String, dynamic>> getPrimaryAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': 'acc_default_01',
      'maskedNumber': maskedNumber,
      'balancePaise': primaryBalancePaise,
      'primaryVpa': primaryVpa,
    };
  }

  // GET /vpa/{address}
  Future<Map<String, String>> verifyVpa(String address) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalized = address.trim().toLowerCase();
    if (_vpaDirectory.containsKey(normalized)) {
      return _vpaDirectory[normalized]!;
    }
    // Generic fallback for any other valid format address
    if (normalized.contains('@')) {
      final parts = normalized.split('@');
      return {
        'address': normalized,
        'verifiedName': '${parts[0].toUpperCase()} (Verified)',
        'bankName': 'Unified Payments Bank',
      };
    }
    throw const VpaNotFoundError(message: 'No account found for this UPI ID');
  }

  // POST /payments
  Future<Map<String, dynamic>> makePayment({
    required String vpa,
    required int amountPaise,
    required String note,
    required String pinHash,
    required String idempotencyKey,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Check Idempotency Key
    if (_idempotencyCache.containsKey(idempotencyKey)) {
      return _idempotencyCache[idempotencyKey]!;
    }

    if (amountPaise > 10000000) { // ₹1,00,000 limit
      throw const LimitExceededError();
    }
    if (amountPaise > primaryBalancePaise) {
      throw const InsufficientFundsError();
    }

    // Debit Balance
    primaryBalancePaise -= amountPaise;

    final verified = await verifyVpa(vpa);
    final String paymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}';
    final String upiRef = 'UPI${DateTime.now().millisecondsSinceEpoch}';

    // Model pending vs success realistically
    // If amount is higher than ₹10,000, start as PENDING to demonstrate polling
    final String status = amountPaise > 1000000 ? 'PENDING' : 'SUCCESS';

    final paymentRecord = {
      'id': paymentId,
      'direction': 'SENT',
      'counterparty': vpa,
      'counterpartyName': verified['verifiedName'] ?? vpa,
      'amountPaise': amountPaise,
      'note': note.isEmpty ? 'Payment via PayLite' : note,
      'status': status,
      'upiRef': upiRef,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    _payments.insert(0, paymentRecord);
    _idempotencyCache[idempotencyKey] = paymentRecord;

    // Simulate auto-resolution from PENDING -> SUCCESS in 4 seconds
    if (status == 'PENDING') {
      Timer(const Duration(seconds: 4), () {
        paymentRecord['status'] = 'SUCCESS';
      });
    }

    return paymentRecord;
  }

  // GET /payments/{id}
  Future<Map<String, dynamic>> getPayment(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final match = _payments.firstWhere(
      (p) => p['id'] == id,
      orElse: () => throw const NotFoundError(message: 'Payment not found'),
    );
    return Map<String, dynamic>.from(match);
  }

  // GET /payments?cursor=&filter=&q=
  Future<Map<String, dynamic>> getHistory({
    String? cursor,
    int limit = 20,
    String? filter, // 'SENT', 'RECEIVED', 'FAILED'
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var results = List<Map<String, dynamic>>.from(_payments);

    if (filter != null && filter.isNotEmpty && filter != 'ALL') {
      results = results.where((p) => p['direction'] == filter || p['status'] == filter).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((p) =>
        (p['counterparty'] as String).toLowerCase().contains(q) ||
        (p['counterpartyName'] as String).toLowerCase().contains(q) ||
        (p['note'] as String).toLowerCase().contains(q)
      ).toList();
    }

    return {
      'items': results,
      'nextCursor': null, // In-memory all returned
    };
  }

  // POST /collect-requests
  Future<Map<String, dynamic>> createCollectRequest({
    required String toVpa,
    required int amountPaise,
    String note = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newReq = {
      'id': 'col_${DateTime.now().millisecondsSinceEpoch}',
      'from': primaryVpa,
      'fromName': 'Sachin (You)',
      'to': toVpa,
      'amountPaise': amountPaise,
      'note': note,
      'status': 'PENDING',
      'expiresAt': DateTime.now().add(const Duration(hours: 48)).toUtc().toIso8601String(),
    };
    _collectRequests.insert(0, newReq);
    return newReq;
  }

  // GET /collect-requests
  Future<List<Map<String, dynamic>>> getCollectRequests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_collectRequests);
  }

  // POST /collect-requests/{id}/pay
  Future<Map<String, dynamic>> payCollectRequest(String id, String pinHash) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final req = _collectRequests.firstWhere(
      (r) => r['id'] == id,
      orElse: () => throw const NotFoundError(message: 'Request not found'),
    );

    final expiresAt = DateTime.parse(req['expiresAt']);
    if (DateTime.now().isAfter(expiresAt)) {
      req['status'] = 'EXPIRED';
      throw const ExpiredError(message: 'This collect request has expired');
    }

    // Debit and create payment
    final amount = req['amountPaise'] as int;
    if (amount > primaryBalancePaise) {
      throw const InsufficientFundsError();
    }
    primaryBalancePaise -= amount;
    req['status'] = 'PAID';

    final paymentRecord = {
      'id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
      'direction': 'SENT',
      'counterparty': req['from'],
      'counterpartyName': req['fromName'],
      'amountPaise': amount,
      'note': 'Collect payment: ${req['note']}',
      'status': 'SUCCESS',
      'upiRef': 'UPI${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    _payments.insert(0, paymentRecord);

    return paymentRecord;
  }

  // POST /collect-requests/{id}/decline
  Future<void> declineCollectRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final req = _collectRequests.firstWhere(
      (r) => r['id'] == id,
      orElse: () => throw const NotFoundError(message: 'Request not found'),
    );
    req['status'] = 'DECLINED';
  }
}
