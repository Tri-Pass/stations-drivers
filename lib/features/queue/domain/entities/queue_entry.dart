import 'package:equatable/equatable.dart';

class QueueEntry extends Equatable {
  final String taxiId;
  final String line;
  final String? lineId;
  final String? station;
  final int position;
  final int totalInQueue;
  final String? status;
  final int seatsTotal;
  final int seatsOccupied;
  final int seatsAvailable;

  const QueueEntry({
    required this.taxiId,
    required this.line,
    this.lineId,
    this.station,
    required this.position,
    required this.totalInQueue,
    this.status,
    required this.seatsTotal,
    required this.seatsOccupied,
    required this.seatsAvailable,
  });

  @override
  List<Object?> get props => [taxiId, position];
}
