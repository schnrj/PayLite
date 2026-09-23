/// Input validation logic conforming to payment specifications
class Validators {
  static final RegExp _vpaRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');

  /// Normalizes VPA address: trims trailing/leading spaces and converts to lowercase
  static String normalizeVpa(String vpa) {
    return vpa.trim().toLowerCase();
  }

  static bool isValidVpa(String vpa) {
    final clean = normalizeVpa(vpa);
    return _vpaRegex.hasMatch(clean);
  }

  static String? validateVpa(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a UPI ID';
    }
    if (!isValidVpa(value)) {
      return 'Enter a valid UPI ID (e.g. username@bank)';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than ₹0';
    }
    if (amount > 100000) {
      return 'Amount exceeds single transaction limit of ₹1,00,000';
    }
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your UPI PIN';
    }
    if (value.length < 4 || value.length > 6) {
      return 'UPI PIN must be 4 to 6 digits';
    }
    if (int.tryParse(value) == null) {
      return 'PIN must contain only numbers';
    }
    return null;
  }

  static String? validateCustomerId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Customer ID';
    }
    if (value.trim().length < 3) {
      return 'Customer ID is too short';
    }
    return null;
  }
}
