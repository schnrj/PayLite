import 'package:equatable/equatable.dart';

enum CollectStatus { pending, paid, declined, expired }

/// Collect request entity for requesting money (Feature F7)
class CollectRequest extends Equatable {
  final String id;
  final String from;
  final String fromName;
  final String to;
  final int amountPaise;
  final String note;
  final CollectStatus status;
  final String expiresAt;

  const CollectRequest({
    required this.id,
    required this.from,
    required this.fromName,
    required this.to,
    required this.amountPaise,
    required this.note,
    required this.status,
    required this.expiresAt,
  });

  factory CollectRequest.fromJson(Map<String, dynamic> json) {
    return CollectRequest(
      id: json['id'] as String,
      from: json['from'] as String,
      fromName: (json['fromName'] ?? json['from']) as String,
      to: json['to'] as String,
      amountPaise: json['amountPaise'] as int,
      note: (json['note'] ?? '') as String,
      status: _parseStatus(json['status'] as String?),
      expiresAt: json['expiresAt'] as String,
    );
  }

  static CollectStatus _parseStatus(String? s) {
    return switch (s?.toUpperCase()) {
      'PENDING' => CollectStatus.pending,
      'PAID' => CollectStatus.paid,
      'DECLINED' => CollectStatus.declined,
      'EXPIRED' => CollectStatus.expired,
      _ => CollectStatus.pending,
    };
  }

  bool get isExpired {
    try {
      return DateTime.now().isAfter(DateTime.parse(expiresAt));
    } catch (_) {
      return false;
    }
  }

  @override
  List<Object?> get props => [id, from, fromName, to, amountPaise, note, status, expiresAt];
}
