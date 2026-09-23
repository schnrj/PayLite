import 'package:equatable/equatable.dart';

/// User session model representing an authenticated, bound device state
class Session extends Equatable {
  final String token;
  final String deviceId;
  final String customerId;

  const Session({
    required this.token,
    required this.deviceId,
    required this.customerId,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      token: json['token'] as String,
      deviceId: json['deviceId'] as String,
      customerId: (json['customerId'] ?? 'Customer') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'deviceId': deviceId,
        'customerId': customerId,
      };

  @override
  List<Object?> get props => [token, deviceId, customerId];
}
