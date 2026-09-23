import '../../../core/utils/validators.dart';

class QrPayload {
  final String vpa;
  final String? payeeName;
  final double? fixedAmountRupees;

  const QrPayload({
    required this.vpa,
    this.payeeName,
    this.fixedAmountRupees,
  });

  bool get hasFixedAmount => fixedAmountRupees != null && fixedAmountRupees! > 0;
}

/// Parses UPI URI format: upi://pay?pa=...&pn=...&am=... (Feature F3)
class QrParser {
  static QrPayload parse(String rawData) {
    final clean = rawData.trim();

    if (!clean.startsWith('upi://pay')) {
      // Check if raw text is just a valid VPA itself
      if (Validators.isValidVpa(clean)) {
        return QrPayload(vpa: Validators.normalizeVpa(clean));
      }
      throw const FormatException('This is not a valid payment QR');
    }

    try {
      final uri = Uri.parse(clean);
      final pa = uri.queryParameters['pa'];

      if (pa == null || pa.trim().isEmpty) {
        throw const FormatException('This is not a valid payment QR: missing UPI ID');
      }

      final normalizedVpa = Validators.normalizeVpa(pa);
      final payeeName = uri.queryParameters['pn'];
      final amStr = uri.queryParameters['am'];
      final double? fixedAmount = amStr != null ? double.tryParse(amStr) : null;

      return QrPayload(
        vpa: normalizedVpa,
        payeeName: payeeName,
        fixedAmountRupees: fixedAmount,
      );
    } catch (e) {
      if (e is FormatException) rethrow;
      throw const FormatException('This is not a valid payment QR');
    }
  }
}
