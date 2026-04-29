import 'package:pro.stations.wetaxi.ma/core/network/api_client.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/entities/recharge_result.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/entities/wallet_info.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final ApiClient _apiClient;
  WalletRepositoryImpl(this._apiClient);

  @override
  Future<WalletInfo> getWallet() async {
    final data = await _apiClient.get('/me');
    final driver = data['driver'] as Map<String, dynamic>;
    final balance = (driver['balance'] as num?)?.toDouble() ?? 0;
    return WalletInfo(balance: balance, transactions: const []);
  }

  @override
  Future<RechargeResult> rechargeByPhone(String phone, double amount) async {
    final data = await _apiClient.post('/recharge', {
      'phone': phone,
      'amount': amount.toInt(),
    });
    return _mapResult(data);
  }

  @override
  Future<RechargeResult> rechargeByNfc(String nfcTagId, double amount) async {
    final data = await _apiClient.post('/recharge', {
      'nfcTagId': nfcTagId,
      'amount': amount.toInt(),
    });
    return _mapResult(data);
  }

  RechargeResult _mapResult(Map<String, dynamic> data) {
    final client = data['client'] as Map<String, dynamic>;
    return RechargeResult(
      success: data['success'] as bool? ?? true,
      clientName: (client['name'] ?? '') as String,
      clientPhone: (client['phone'] ?? '') as String,
      newBalance: (client['newBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}
