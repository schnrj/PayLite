import '../domain/session.dart';
import '../../../core/network/fake_api_client.dart';
import '../../../core/security/secure_session_store.dart';

abstract class AuthRepository {
  Future<Session> login(String customerId, String pin);
  Future<Session?> restoreSession();
  Future<void> logout();
}

class FakeAuthRepository implements AuthRepository {
  final FakeApiClient _apiClient;
  final SecureSessionStore _sessionStore;

  FakeAuthRepository({
    FakeApiClient? apiClient,
    SecureSessionStore? sessionStore,
  })  : _apiClient = apiClient ?? FakeApiClient(),
        _sessionStore = sessionStore ?? SecureSessionStore();

  @override
  Future<Session> login(String customerId, String pin) async {
    final response = await _apiClient.login(customerId, pin);
    final session = Session.fromJson(response);
    await _sessionStore.saveSession(
      token: session.token,
      deviceId: session.deviceId,
      customerId: session.customerId,
    );
    return session;
  }

  @override
  Future<Session?> restoreSession() async {
    final data = await _sessionStore.loadSession();
    if (data != null) {
      return Session(
        token: data['token']!,
        deviceId: data['deviceId']!,
        customerId: data['customerId']!,
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _sessionStore.clearSession();
  }
}
