import 'package:equatable/equatable.dart';
import 'passenger_entity.dart';

class TaxiEntity extends Equatable {
  final String id;
  final String origin;
  final String destination;
  final double price;
  final String lineId;
  final String stationId;
  final String stationName;
  final String status;
  final int seatsTotal;
  final int seatsOccupied;
  final int seatsAvailable;
  final List<PassengerEntity> passengers;
  final int queuePosition;

  const TaxiEntity({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
    required this.lineId,
    required this.stationId,
    required this.stationName,
    required this.status,
    required this.seatsTotal,
    required this.seatsOccupied,
    required this.seatsAvailable,
    required this.passengers,
    required this.queuePosition,
  });

  @override
  List<Object?> get props => [id, seatsOccupied, status];
}
