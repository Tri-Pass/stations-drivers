import '../entities/seat_availability.dart';
import '../repositories/seat_repository.dart';

class GetSeatAvailabilityUseCase {
  final SeatRepository repository;
  GetSeatAvailabilityUseCase(this.repository);
  Future<SeatAvailability> call(String line) => repository.getSeatAvailability(line);
}
