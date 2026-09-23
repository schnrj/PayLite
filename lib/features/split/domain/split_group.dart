import 'package:equatable/equatable.dart';

class SplitParticipant extends Equatable {
  final String id;
  final String vpa;
  final String name;
  final int amountPaise;
  final bool isPaid;

  const SplitParticipant({
    required this.id,
    required this.vpa,
    required this.name,
    required this.amountPaise,
    this.isPaid = false,
  });

  SplitParticipant copyWith({
    String? id,
    String? vpa,
    String? name,
    int? amountPaise,
    bool? isPaid,
  }) {
    return SplitParticipant(
      id: id ?? this.id,
      vpa: vpa ?? this.vpa,
      name: name ?? this.name,
      amountPaise: amountPaise ?? this.amountPaise,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  List<Object?> get props => [id, vpa, name, amountPaise, isPaid];
}

class SplitGroup extends Equatable {
  final String id;
  final int totalPaise;
  final List<SplitParticipant> participants;

  const SplitGroup({
    required this.id,
    required this.totalPaise,
    required this.participants,
  });

  @override
  List<Object?> get props => [id, totalPaise, participants];
}
