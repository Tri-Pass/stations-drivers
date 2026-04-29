import 'package:pro.stations.wetaxi.ma/core/network/api_client.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/entities/passenger_entity.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/entities/seat_availability.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/entities/taxi_entity.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/repositories/seat_repository.dart';

class SeatRepositoryImpl implements SeatRepository {
  final ApiClient _apiClient;
  SeatRepositoryImpl(this._apiClient);

  @override
  Future<SeatAvailability> getSeatAvailability(String line) async {
    final data = await _apiClient.get('/taxi');
    final taxi = data['taxi'];
    if (taxi == null) {
      return const SeatAvailability(
        totalSeats: 6,
        occupiedSeats: 0,
        line: '-',
        destination: '-',
      );
    }
    final lineData = taxi['line'] as Map<String, dynamic>?;
    return SeatAvailability(
      totalSeats: (taxi['seatsTotal'] as num).toInt(),
      occupiedSeats: (taxi['seatsOccupied'] as num).toInt(),
      line: (lineData?['origin'] ?? line) as String,
      destination: (lineData?['destination'] ?? '-') as String,
    );
  }

  @override
  Future<TaxiEntity?> getTaxiInfo() async {
    final data = await _apiClient.get('/taxi');
    final taxi = data['taxi'];
    if (taxi == null) return null;

    final lineData = taxi['line'] as Map<String, dynamic>?;
    final stationData = taxi['station'] as Map<String, dynamic>?;
    final passengersList = taxi['passengers'] as List? ?? [];

    return TaxiEntity(
      id: (taxi['id'] ?? '') as String,
      origin: (lineData?['origin'] ?? '-') as String,
      destination: (lineData?['destination'] ?? '-') as String,
      price: (lineData?['price'] as num? ?? 0).toDouble(),
      lineId: (lineData?['id'] ?? '') as String,
      stationId: (stationData?['_id'] ?? stationData?['id'] ?? '') as String,
      stationName: (stationData?['name'] ?? '-') as String,
      status: (taxi['status'] ?? 'queued') as String,
      seatsTotal: (taxi['seatsTotal'] as num).toInt(),
      seatsOccupied: (taxi['seatsOccupied'] as num).toInt(),
      seatsAvailable: (taxi['seatsAvailable'] as num).toInt(),
      passengers: passengersList
          .map((p) => PassengerEntity(
                seatNumber: (p['seatNumber'] as num).toInt(),
                name: (p['name'] as String?) ?? '',
                ticketCode: p['ticketCode'] as String?,
              ))
          .toList(),
      queuePosition: (taxi['queuePosition'] as num? ?? 0).toInt(),
    );
  }

  @override
  Future<void> updateSeatOccupancy(String line, int occupied) async {}
}
