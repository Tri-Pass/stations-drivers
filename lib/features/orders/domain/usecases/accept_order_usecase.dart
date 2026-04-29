import '../repositories/order_repository.dart';

class AcceptOrderUseCase {
  final OrderRepository repository;
  AcceptOrderUseCase(this.repository);
  Future<void> call(String orderId) => repository.acceptOrder(orderId);
}
