import '../entities/taxi_order.dart';

abstract class OrderRepository {
  Future<List<TaxiOrder>> getOrders();
  Future<TaxiOrder?> getActiveOrder();
  Future<void> acceptOrder(String orderId);
  Future<void> completeOrder(String orderId);
  Future<void> cancelOrder(String orderId);
}
