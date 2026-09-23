import 'package:equatable/equatable.dart';

enum PaymentDirection { sent, received }
enum PaymentStatus { success, pending, failed }

/// Payment transaction model
class Payment extends Equatable {
  final String id;
  final PaymentDirection direction;
  final String counterparty;
  final String counterpartyName;
  final int amountPaise;
  final String note;
  final PaymentStatus status;
  final String upiRef;
  final String createdAt;

  const Payment({
    required this.id,
    required this.direction,
    required this.counterparty,
    required this.counterpartyName,
    required this.amountPaise,
    required this.note,
    required this.status,
    required this.upiRef,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      direction: (json['direction'] == 'SENT') ? PaymentDirection.sent : PaymentDirection.received,
      counterparty: json['counterparty'] as String,
      counterpartyName: (json['counterpartyName'] ?? json['counterparty']) as String,
      amountPaise: json['amountPaise'] as int,
      note: (json['note'] ?? '') as String,
      status: _parseStatus(json['status'] as String?),
      upiRef: (json['upiRef'] ?? '') as String,
      createdAt: json['createdAt'] as String,
    );
  }

  static PaymentStatus _parseStatus(String? status) {
    return switch (status?.toUpperCase()) {
      'SUCCESS' => PaymentStatus.success,
      'PENDING' => PaymentStatus.pending,
      'FAILED' => PaymentStatus.failed,
      _ => PaymentStatus.success,
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'direction': direction == PaymentDirection.sent ? 'SENT' : 'RECEIVED',
        'counterparty': counterparty,
        'counterpartyName': counterpartyName,
        'amountPaise': amountPaise,
        'note': note,
        'status': status.name.toUpperCase(),
        'upiRef': upiRef,
        'createdAt': createdAt,
      };

  @override
  List<Object?> get props => [
        id,
        direction,
        counterparty,
        counterpartyName,
        amountPaise,
        note,
        status,
        upiRef,
        createdAt,
      ];
}
