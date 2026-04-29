import '../entities/recharge_result.dart';
import '../entities/wallet_info.dart';

abstract class WalletRepository {
  Future<WalletInfo> getWallet();
  Future<RechargeResult> rechargeByPhone(String phone, double amount);
  Future<RechargeResult> rechargeByNfc(String nfcTagId, double amount);
}
