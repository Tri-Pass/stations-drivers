import 'package:equatable/equatable.dart';

enum OrderStatus { pending, active, completed, cancelled }
enum PaymentMethod { cash, nfc, card, wallet }

class TaxiOrder extends Equatable {
  final String id;
  final String passengerName;
  final String passengerPhone;
  final String pickupAddress;
  final String dropoffAddress;
  final double fare;
  final OrderStatus status;
  final DateTime createdAt;
  final PaymentMethod paymentMethod;
  final double distance;
  final int estimatedMinutes;
  final int numberOfPassengers;

  const TaxiOrder({
    required this.id,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.fare,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
    required this.distance,
    required this.estimatedMinutes,
    this.numberOfPassengers = 1,
  });

  String get abbreviatedName {
    final parts = passengerName.trim().split(' ');
    if (parts.length > 1) return '${parts[0]} ${parts[1][0]}.';
    return passengerName;
  }

  TaxiOrder copyWith({OrderStatus? status}) => TaxiOrder(
        id: id,
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        fare: fare,
        status: status ?? this.status,
        createdAt: createdAt,
        paymentMethod: paymentMethod,
        distance: distance,
        estimatedMinutes: estimatedMinutes,
        numberOfPassengers: numberOfPassengers,
      );

  @override
  List<Object?> get props => [id, status];
}
