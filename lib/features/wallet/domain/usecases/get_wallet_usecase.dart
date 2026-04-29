import '../entities/wallet_info.dart';
import '../repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository repository;
  GetWalletUseCase(this.repository);
  Future<WalletInfo> call() => repository.getWallet();
}
