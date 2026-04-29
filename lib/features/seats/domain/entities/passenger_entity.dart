import 'package:equatable/equatable.dart';

class PassengerEntity extends Equatable {
  final int seatNumber;
  final String name;
  final String? ticketCode;

  const PassengerEntity({
    required this.seatNumber,
    required this.name,
    this.ticketCode,
  });

  @override
  List<Object?> get props => [seatNumber, ticketCode];
}
