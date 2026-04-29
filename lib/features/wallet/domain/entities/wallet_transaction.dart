import 'package:equatable/equatable.dart';

class WalletTransaction extends Equatable {
  final String id;
  final String description;
  final double amount;
  final bool isCredit;
  final DateTime date;

  const WalletTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.isCredit,
    required this.date,
  });

  @override
  List<Object?> get props => [id];
}
