/// Sealed error class representing domain and network errors across PayLite
sealed class BankError {
  final String message;
  final String? traceId;

  const BankError(this.message, {this.traceId});

  @override
  String toString() => '$runtimeType: $message${traceId != null ? ' (trace: $traceId)' : ''}';
}

class NetworkConnectionError extends BankError {
  const NetworkConnectionError({
    String message = 'Unable to connect to server. Please check your internet connection.',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class AuthError extends BankError {
  const AuthError({
    String message = 'Session expired or invalid credentials. Please log in again.',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class AccountLockedError extends BankError {
  const AccountLockedError({
    String message = 'Your account has been temporarily locked for security reasons.',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class InsufficientFundsError extends BankError {
  const InsufficientFundsError({
    String message = 'Insufficient balance in your primary account.',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class LimitExceededError extends BankError {
  const LimitExceededError({
    String message = 'Transfer limit exceeded (Maximum ₹1,00,000 per transaction).',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class VpaNotFoundError extends BankError {
  const VpaNotFoundError({
    String message = 'No account found for this UPI ID.',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class KeyReusedError extends BankError {
  const KeyReusedError({
    String message = 'This transaction has already been processed or key reused.',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class ExpiredError extends BankError {
  const ExpiredError({
    String message = 'This payment or collect request has expired.',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class NotFoundError extends BankError {
  const NotFoundError({
    String message = 'Requested resource was not found.',
    String? traceId,
  }) : super(message, traceId: traceId);
}

class ServerFailureError extends BankError {
  final int? statusCode;
  const ServerFailureError({
    String message = 'An unexpected server error occurred. Please try again later.',
    this.statusCode,
    String? traceId,
  }) : super(message, traceId: traceId);
}
