import '../repositories/queue_repository.dart';

class JoinQueueUseCase {
  final QueueRepository repository;
  JoinQueueUseCase(this.repository);
  Future<void> call(String lineId) => repository.joinQueue(lineId);
}
