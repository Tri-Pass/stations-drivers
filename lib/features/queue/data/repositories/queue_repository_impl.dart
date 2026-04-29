import 'package:pro.stations.wetaxi.ma/core/network/api_client.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/entities/queue_entry.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/repositories/queue_repository.dart';

class QueueRepositoryImpl implements QueueRepository {
  final ApiClient _apiClient;
  QueueRepositoryImpl(this._apiClient);

  @override
  Future<List<QueueEntry>> getQueue() async {
    final data = await _apiClient.get('/queue');
    final queues = data['queues'] as List;
    return queues.map((q) {
      return QueueEntry(
        taxiId: q['taxiId'] as String,
        line: q['line'] as String,
        lineId: q['lineId'] as String?,
        station: q['station'] is String ? q['station'] as String : null,
        position: (q['position'] as num).toInt(),
        totalInQueue: (q['totalInQueue'] as num).toInt(),
        status: q['status'] as String?,
        seatsTotal: (q['seatsTotal'] as num).toInt(),
        seatsOccupied: (q['seatsOccupied'] as num).toInt(),
        seatsAvailable: (q['seatsAvailable'] as num).toInt(),
      );
    }).toList();
  }

  @override
  Future<void> joinQueue(String lineId) async {
    await _apiClient.put('/line', {'lineId': lineId});
  }
}
