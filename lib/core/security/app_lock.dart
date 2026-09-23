import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'biometric_service.dart';

final appLockProvider = ChangeNotifierProvider<AppLockNotifier>((ref) {
  return AppLockNotifier(BiometricService());
});

/// Controls background lock and biometric unlock state
class AppLockNotifier extends ChangeNotifier {
  final BiometricService _biometricService;
  bool _isLocked = false;
  bool _enabled = true;

  AppLockNotifier(this._biometricService);

  bool get isLocked => _isLocked;
  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }

  void onAppPaused() {
    if (_enabled && !_isLocked) {
      _isLocked = true;
      notifyListeners();
    }
  }

  Future<bool> unlock() async {
    final success = await _biometricService.authenticate(
      reason: 'Unlock PayLite to view balance and make payments',
    );
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
    return success;
  }

  void lockManually() {
    _isLocked = true;
    notifyListeners();
  }
}
