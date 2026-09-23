import 'package:equatable/equatable.dart';

/// Virtual Payment Address (UPI ID) model
class Vpa extends Equatable {
  final String address;
  final String verifiedName;
  final String bankName;

  const Vpa({
    required this.address,
    required this.verifiedName,
    required this.bankName,
  });

  factory Vpa.fromJson(Map<String, dynamic> json) {
    return Vpa(
      address: json['address'] as String,
      verifiedName: json['verifiedName'] as String,
      bankName: json['bankName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'verifiedName': verifiedName,
        'bankName': bankName,
      };

  @override
  List<Object?> get props => [address, verifiedName, bankName];
}
