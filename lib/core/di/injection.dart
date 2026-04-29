import 'package:get_it/get_it.dart';
import 'package:pro.stations.wetaxi.ma/core/l10n/locale_notifier.dart';
import 'package:pro.stations.wetaxi.ma/core/network/api_client.dart';
import 'package:pro.stations.wetaxi.ma/core/network/socket_service.dart';
import 'package:pro.stations.wetaxi.ma/core/shared/datasources/mock_data_source.dart';
import 'package:pro.stations.wetaxi.ma/core/storage/local_storage.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/domain/repositories/auth_repository.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/domain/usecases/login_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/home/presentation/bloc/home_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/data/repositories/order_repository_impl.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/repositories/order_repository.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/usecases/complete_order_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/presentation/bloc/order_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/data/repositories/queue_repository_impl.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/repositories/queue_repository.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/usecases/get_queue_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/usecases/join_queue_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/data/repositories/seat_repository_impl.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/repositories/seat_repository.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/usecases/get_seat_availability_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/usecases/recharge_client_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Locale
  final localeNotifier = LocaleNotifier();
  await localeNotifier.init();
  sl.registerSingleton(localeNotifier);

  // Core infrastructure
  sl.registerLazySingleton(() => LocalStorage());
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => SocketService());

  // Mock data source (orders only)
  sl.registerLazySingleton<MockDataSource>(() => MockDataSource());

  // Auth feature
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(loginUseCase: sl(), authRepository: sl(), socketService: sl()),
  );

  // Orders feature (mock)
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => AcceptOrderUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOrderUseCase(sl()));
  sl.registerFactory(
    () => OrderBloc(getOrders: sl(), acceptOrder: sl(), completeOrder: sl()),
  );

  // Queue feature (real API)
  sl.registerLazySingleton<QueueRepository>(() => QueueRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetQueueUseCase(sl()));
  sl.registerLazySingleton(() => JoinQueueUseCase(sl()));

  // Seats feature (real API)
  sl.registerLazySingleton<SeatRepository>(() => SeatRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetSeatAvailabilityUseCase(sl()));

  // Home feature
  sl.registerFactory(() => HomeBloc(queueRepository: sl(), seatRepository: sl(), socketService: sl()));

  // Wallet feature (real API)
  sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetWalletUseCase(sl()));
  sl.registerLazySingleton(() => RechargeClientUseCase(sl()));
  sl.registerFactory(
    () => WalletBloc(getWallet: sl(), rechargeClient: sl()),
  );
}
