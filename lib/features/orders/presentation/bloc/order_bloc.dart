import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/entities/taxi_order.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/usecases/complete_order_usecase.dart';

// Events
abstract class OrderEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadOrders extends OrderEvent {}
class AcceptOrder extends OrderEvent {
  final String orderId;
  AcceptOrder(this.orderId);
  @override List<Object?> get props => [orderId];
}
class CompleteOrder extends OrderEvent {
  final String orderId;
  CompleteOrder(this.orderId);
  @override List<Object?> get props => [orderId];
}
class CancelOrder extends OrderEvent {
  final String orderId;
  CancelOrder(this.orderId);
  @override List<Object?> get props => [orderId];
}

// States
abstract class OrderState extends Equatable {
  @override List<Object?> get props => [];
}
class OrderInitial extends OrderState {}
class OrderLoading extends OrderState {}
class OrderLoaded extends OrderState {
  final List<TaxiOrder> orders;
  OrderLoaded(this.orders);
  @override List<Object?> get props => [orders];
}
class OrderActionLoading extends OrderState {
  final List<TaxiOrder> orders;
  final String orderId;
  OrderActionLoading(this.orders, this.orderId);
  @override List<Object?> get props => [orderId];
}
class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrders;
  final AcceptOrderUseCase acceptOrder;
  final CompleteOrderUseCase completeOrder;

  OrderBloc({required this.getOrders, required this.acceptOrder, required this.completeOrder})
      : super(OrderInitial()) {
    on<LoadOrders>(_onLoad);
    on<AcceptOrder>(_onAccept);
    on<CompleteOrder>(_onComplete);
    on<CancelOrder>(_onCancel);
  }

  Future<void> _onLoad(LoadOrders e, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try { emit(OrderLoaded(await getOrders())); }
    catch (e) { emit(OrderError(e.toString())); }
  }

  Future<void> _onAccept(AcceptOrder e, Emitter<OrderState> emit) async {
    final cur = state is OrderLoaded ? (state as OrderLoaded).orders : <TaxiOrder>[];
    emit(OrderActionLoading(cur, e.orderId));
    try { await acceptOrder(e.orderId); emit(OrderLoaded(await getOrders())); }
    catch (err) { emit(OrderError(err.toString())); }
  }

  Future<void> _onComplete(CompleteOrder e, Emitter<OrderState> emit) async {
    final cur = state is OrderLoaded ? (state as OrderLoaded).orders : <TaxiOrder>[];
    emit(OrderActionLoading(cur, e.orderId));
    try { await completeOrder(e.orderId); emit(OrderLoaded(await getOrders())); }
    catch (err) { emit(OrderError(err.toString())); }
  }

  Future<void> _onCancel(CancelOrder e, Emitter<OrderState> emit) async {
    emit(OrderLoaded(await getOrders()));
  }
}
