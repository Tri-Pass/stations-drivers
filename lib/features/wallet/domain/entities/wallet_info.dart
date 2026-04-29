import 'package:equatable/equatable.dart';
import 'wallet_transaction.dart';

class WalletInfo extends Equatable {
  final double balance;
  final List<WalletTransaction> transactions;

  const WalletInfo({required this.balance, required this.transactions});

  @override
  List<Object?> get props => [balance];
}
