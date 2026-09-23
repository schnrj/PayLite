import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service handling biometric authentication with device credential/PIN fallback
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Authenticate to unlock PayLite'}) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        return true; // If device does not have hardware, allow pass in dev/test
      }
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // fallback to device PIN
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
