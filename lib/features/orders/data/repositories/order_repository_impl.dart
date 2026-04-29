import 'package:pro.stations.wetaxi.ma/core/shared/datasources/mock_data_source.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/entities/taxi_order.dart';
import 'package:pro.stations.wetaxi.ma/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final MockDataSource dataSource;
  OrderRepositoryImpl(this.dataSource);

  @override Future<List<TaxiOrder>> getOrders() => dataSource.getOrders();
  @override Future<TaxiOrder?> getActiveOrder() => dataSource.getActiveOrder();
  @override Future<void> acceptOrder(String id) => dataSource.acceptOrder(id);
  @override Future<void> completeOrder(String id) => dataSource.completeOrder(id);
  @override Future<void> cancelOrder(String id) => dataSource.cancelOrder(id);
}
