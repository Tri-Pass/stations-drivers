import '../entities/seat_availability.dart';
import '../entities/taxi_entity.dart';

abstract class SeatRepository {
  Future<SeatAvailability> getSeatAvailability(String line);
  Future<void> updateSeatOccupancy(String line, int occupied);
  Future<TaxiEntity?> getTaxiInfo();
}
