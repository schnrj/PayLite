import '../errors/bank_error.dart';

/// Maps HTTP status codes, network errors, and server response shapes to BankError
class ErrorMapper {
  static BankError fromResponse(int? statusCode, dynamic data, {String? defaultMessage}) {
    String message = defaultMessage ?? 'An unexpected error occurred';
    String? traceId;
    String? errorCode;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('error') && data['error'] is Map<String, dynamic>) {
        final err = data['error'] as Map<String, dynamic>;
        message = err['message']?.toString() ?? message;
        traceId = err['traceId']?.toString();
        errorCode = err['code']?.toString();
      } else {
        message = data['message']?.toString() ?? message;
        traceId = data['traceId']?.toString();
        errorCode = data['code']?.toString();
      }
    }

    // Specific error code check
    if (errorCode == 'INSUFFICIENT_FUNDS' || message.toLowerCase().contains('insufficient funds')) {
      return InsufficientFundsError(message: message, traceId: traceId);
    }
    if (errorCode == 'LIMIT_EXCEEDED' || message.toLowerCase().contains('limit exceeded')) {
      return LimitExceededError(message: message, traceId: traceId);
    }
    if (errorCode == 'VPA_NOT_FOUND' || message.toLowerCase().contains('vpa not found') || statusCode == 404) {
      return VpaNotFoundError(message: message, traceId: traceId);
    }
    if (errorCode == 'KEY_REUSED' || statusCode == 409) {
      return KeyReusedError(message: message, traceId: traceId);
    }
    if (errorCode == 'EXPIRED' || statusCode == 410) {
      return ExpiredError(message: message, traceId: traceId);
    }

    switch (statusCode) {
      case 401:
        return AuthError(message: message, traceId: traceId);
      case 423:
        return AccountLockedError(message: message, traceId: traceId);
      case 404:
        return NotFoundError(message: message, traceId: traceId);
      default:
        return ServerFailureError(
          statusCode: statusCode,
          message: message,
          traceId: traceId,
        );
    }
  }

  static BankError fromException(dynamic exception) {
    if (exception is BankError) return exception;
    return NetworkConnectionError(message: exception.toString());
  }
}
