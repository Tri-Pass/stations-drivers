import '../entities/recharge_result.dart';
import '../repositories/wallet_repository.dart';

class RechargeClientUseCase {
  final WalletRepository repository;
  RechargeClientUseCase(this.repository);

  Future<RechargeResult> byPhone(String phone, double amount) =>
      repository.rechargeByPhone(phone, amount);

  Future<RechargeResult> byNfc(String nfcTagId, double amount) =>
      repository.rechargeByNfc(nfcTagId, amount);
}
