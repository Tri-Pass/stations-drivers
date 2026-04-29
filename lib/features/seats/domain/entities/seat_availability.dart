import 'package:equatable/equatable.dart';

class SeatAvailability extends Equatable {
  final int totalSeats;
  final int occupiedSeats;
  final String line;
  final String destination;

  const SeatAvailability({
    required this.totalSeats,
    required this.occupiedSeats,
    required this.line,
    required this.destination,
  });

  int get availableSeats => totalSeats - occupiedSeats;

  @override
  List<Object?> get props => [line, occupiedSeats];
}
