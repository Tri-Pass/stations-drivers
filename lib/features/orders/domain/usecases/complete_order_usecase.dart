import '../repositories/order_repository.dart';

class CompleteOrderUseCase {
  final OrderRepository repository;
  CompleteOrderUseCase(this.repository);
  Future<void> call(String orderId) => repository.completeOrder(orderId);
}
