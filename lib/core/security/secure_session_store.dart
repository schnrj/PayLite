import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure session store saving tokens and device ID to Keychain/Keystore
class SecureSessionStore {
  final FlutterSecureStorage _storage;

  SecureSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  static const String _keyToken = 'paylite_token';
  static const String _keyDeviceId = 'paylite_device_id';
  static const String _keyCustomerId = 'paylite_customer_id';

  Future<void> saveSession({
    required String token,
    required String deviceId,
    required String customerId,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyDeviceId, value: deviceId);
    await _storage.write(key: _keyCustomerId, value: customerId);
  }

  Future<Map<String, String>?> loadSession() async {
    try {
      final token = await _storage.read(key: _keyToken);
      final deviceId = await _storage.read(key: _keyDeviceId);
      final customerId = await _storage.read(key: _keyCustomerId);

      if (token != null && deviceId != null) {
        return {
          'token': token,
          'deviceId': deviceId,
          'customerId': customerId ?? 'Customer',
        };
      }
    } catch (_) {
      // In case of platform storage error or testing environment
    }
    return null;
  }

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyDeviceId);
      await _storage.delete(key: _keyCustomerId);
    } catch (_) {}
  }
}
