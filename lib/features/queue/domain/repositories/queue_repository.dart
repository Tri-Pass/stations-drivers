import '../entities/queue_entry.dart';

abstract class QueueRepository {
  Future<List<QueueEntry>> getQueue();
  Future<void> joinQueue(String lineId);
}
