import 'package:equatable/equatable.dart';

/// Primary user bank account
class Account extends Equatable {
  final String id;
  final String maskedNumber;
  final int balancePaise;
  final String primaryVpa;

  const Account({
    required this.id,
    required this.maskedNumber,
    required this.balancePaise,
    required this.primaryVpa,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      maskedNumber: json['maskedNumber'] as String,
      balancePaise: json['balancePaise'] as int,
      primaryVpa: json['primaryVpa'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'maskedNumber': maskedNumber,
        'balancePaise': balancePaise,
        'primaryVpa': primaryVpa,
      };

  @override
  List<Object?> get props => [id, maskedNumber, balancePaise, primaryVpa];
}
