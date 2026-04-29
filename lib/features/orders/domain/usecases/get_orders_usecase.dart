import '../entities/taxi_order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;
  GetOrdersUseCase(this.repository);
  Future<List<TaxiOrder>> call() => repository.getOrders();
}
