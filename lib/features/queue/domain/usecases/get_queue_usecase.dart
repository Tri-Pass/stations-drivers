import '../entities/queue_entry.dart';
import '../repositories/queue_repository.dart';

class GetQueueUseCase {
  final QueueRepository repository;
  GetQueueUseCase(this.repository);
  Future<List<QueueEntry>> call() => repository.getQueue();
}
