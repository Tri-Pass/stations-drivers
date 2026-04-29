import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro.stations.wetaxi.ma/core/network/api_client.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/entities/recharge_result.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/entities/wallet_info.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/usecases/recharge_client_usecase.dart';

// Events
abstract class WalletEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {}

class RechargeByPhone extends WalletEvent {
  final String phone;
  final double amount;
  RechargeByPhone(this.phone, this.amount);
  @override
  List<Object?> get props => [phone, amount];
}

class RechargeByNfc extends WalletEvent {
  final String nfcTagId;
  final double amount;
  RechargeByNfc(this.nfcTagId, this.amount);
  @override
  List<Object?> get props => [nfcTagId, amount];
}

// States
abstract class WalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletInfo wallet;
  WalletLoaded(this.wallet);
  @override
  List<Object?> get props => [wallet];
}

class RechargeProcessing extends WalletState {
  final WalletInfo wallet;
  RechargeProcessing(this.wallet);
  @override
  List<Object?> get props => [wallet];
}

class RechargeSuccess extends WalletState {
  final WalletInfo wallet;
  final RechargeResult result;
  RechargeSuccess(this.wallet, this.result);
  @override
  List<Object?> get props => [wallet, result];
}

class WalletError extends WalletState {
  final String message;
  final WalletInfo? wallet;
  WalletError(this.message, {this.wallet});
  @override
  List<Object?> get props => [message];
}

// BLoC
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletUseCase getWallet;
  final RechargeClientUseCase rechargeClient;

  WalletBloc({required this.getWallet, required this.rechargeClient})
      : super(WalletInitial()) {
    on<LoadWallet>(_onLoad);
    on<RechargeByPhone>(_onPhone);
    on<RechargeByNfc>(_onNfc);
  }

  Future<void> _onLoad(LoadWallet e, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      emit(WalletLoaded(await getWallet()));
    } on ApiException catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onPhone(RechargeByPhone e, Emitter<WalletState> emit) async {
    final current = _currentWallet();
    if (current == null) return;
    emit(RechargeProcessing(current));
    try {
      final result = await rechargeClient.byPhone(e.phone, e.amount);
      emit(RechargeSuccess(await getWallet(), result));
    } on ApiException catch (err) {
      emit(WalletError(err.message, wallet: current));
    } catch (_) {
      emit(WalletError('Erreur lors de la recharge', wallet: current));
    }
  }

  Future<void> _onNfc(RechargeByNfc e, Emitter<WalletState> emit) async {
    final current = _currentWallet();
    if (current == null) return;
    emit(RechargeProcessing(current));
    try {
      final result = await rechargeClient.byNfc(e.nfcTagId, e.amount);
      emit(RechargeSuccess(await getWallet(), result));
    } on ApiException catch (err) {
      emit(WalletError(err.message, wallet: current));
    } catch (_) {
      emit(WalletError('Erreur lors de la recharge', wallet: current));
    }
  }

  WalletInfo? _currentWallet() {
    final s = state;
    if (s is WalletLoaded) return s.wallet;
    if (s is RechargeProcessing) return s.wallet;
    if (s is RechargeSuccess) return s.wallet;
    if (s is WalletError) return s.wallet;
    return null;
  }
}
