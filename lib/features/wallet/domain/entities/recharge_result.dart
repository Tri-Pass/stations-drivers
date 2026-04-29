import 'package:equatable/equatable.dart';

class RechargeResult extends Equatable {
  final bool success;
  final String clientName;
  final String clientPhone;
  final double newBalance;

  const RechargeResult({
    required this.success,
    required this.clientName,
    required this.clientPhone,
    required this.newBalance,
  });

  @override
  List<Object?> get props => [clientPhone, newBalance];
}
