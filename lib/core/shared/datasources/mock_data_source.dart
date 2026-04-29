import 'package:pro.stations.wetaxi.ma/features/orders/domain/entities/taxi_order.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/entities/queue_entry.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/entities/wallet_info.dart';
import 'package:pro.stations.wetaxi.ma/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/entities/seat_availability.dart';

class MockDataSource {
  static final List<TaxiOrder> _orders = [
    TaxiOrder(
      id: 'ORD-001', passengerName: 'Mohammed Alaoui', passengerPhone: '+212 6 12 34 56 78',
      pickupAddress: 'Bd Zerktouni, Casablanca', dropoffAddress: 'Aéroport Mohammed V',
      fare: 180.0, status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      paymentMethod: PaymentMethod.cash, distance: 28.4, estimatedMinutes: 5,
      numberOfPassengers: 2,
    ),
    TaxiOrder(
      id: 'ORD-002', passengerName: 'Fatima Zahra', passengerPhone: '+212 6 98 76 54 32',
      pickupAddress: 'Casa Port', dropoffAddress: 'Ain Diab',
      fare: 85.0, status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      paymentMethod: PaymentMethod.cash, distance: 12.1, estimatedMinutes: 12,
      numberOfPassengers: 1,
    ),
    TaxiOrder(
      id: 'ORD-003', passengerName: 'Karim Bennani', passengerPhone: '+212 6 55 44 33 22',
      pickupAddress: 'Gare Casa-Voyageurs', dropoffAddress: 'Mhamid, Marrakech',
      fare: 120.0, status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      paymentMethod: PaymentMethod.wallet, distance: 240.0, estimatedMinutes: 0,
      numberOfPassengers: 3,
    ),
    TaxiOrder(
      id: 'ORD-004', passengerName: 'Sara Idrissi', passengerPhone: '+212 6 77 88 99 00',
      pickupAddress: 'Bab Dukkala, Marrakech', dropoffAddress: 'Essaouira',
      fare: 95.0, status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      paymentMethod: PaymentMethod.card, distance: 175.0, estimatedMinutes: 0,
      numberOfPassengers: 2,
    ),
  ];

  static final List<QueueEntry> _queue = [
    const QueueEntry(taxiId: 'DRV-001', line: 'Bab Dukkala → Mhamid', position: 1, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 4, seatsAvailable: 2),
    const QueueEntry(taxiId: 'DRV-002', line: 'Bab Dukkala → Mhamid', position: 2, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 2, seatsAvailable: 4),
    const QueueEntry(taxiId: 'DRV-003', line: 'Bab Dukkala → Mhamid', position: 3, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 0, seatsAvailable: 6),
    const QueueEntry(taxiId: 'DRV-004', line: 'Bab Dukkala → Mhamid', position: 4, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 6, seatsAvailable: 0),
    const QueueEntry(taxiId: 'DRV-005', line: 'Bab Dukkala → Mhamid', position: 5, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 1, seatsAvailable: 5),
    const QueueEntry(taxiId: 'DRV-006', line: 'Bab Dukkala → Mhamid', position: 6, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 3, seatsAvailable: 3),
    const QueueEntry(taxiId: 'DRV-007', line: 'Bab Dukkala → Mhamid', position: 7, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 5, seatsAvailable: 1),
    const QueueEntry(taxiId: 'DRV-008', line: 'Bab Dukkala → Mhamid', position: 8, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 2, seatsAvailable: 4),
    const QueueEntry(taxiId: 'DRV-009', line: 'Bab Dukkala → Mhamid', position: 9, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 0, seatsAvailable: 6),
    const QueueEntry(taxiId: 'DRV-010', line: 'Bab Dukkala → Mhamid', position: 10, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 4, seatsAvailable: 2),
    const QueueEntry(taxiId: 'DRV-011', line: 'Bab Dukkala → Mhamid', position: 11, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 3, seatsAvailable: 3),
    const QueueEntry(taxiId: 'DRV-012', line: 'Bab Dukkala → Mhamid', position: 12, totalInQueue: 12, seatsTotal: 6, seatsOccupied: 1, seatsAvailable: 5),
  ];

  static final WalletInfo _wallet = WalletInfo(
    balance: 2450.50,
    transactions: [
      WalletTransaction(id: 'TXN-001', description: 'Course - Gare Casa-Voyageurs', amount: 85.0, isCredit: true,
        date: DateTime.now().subtract(const Duration(hours: 1))),
      WalletTransaction(id: 'TXN-002', description: 'Course - Aéroport', amount: 120.0, isCredit: true,
        date: DateTime.now().subtract(const Duration(hours: 3))),
      WalletTransaction(id: 'TXN-003', description: 'Retrait', amount: 50.0, isCredit: false,
        date: DateTime.now().subtract(const Duration(hours: 5))),
      WalletTransaction(id: 'TXN-004', description: 'Course - Mhamid', amount: 180.0, isCredit: true,
        date: DateTime.now().subtract(const Duration(days: 1))),
      WalletTransaction(id: 'TXN-005', description: 'Commission Plateforme', amount: 30.0, isCredit: false,
        date: DateTime.now().subtract(const Duration(days: 2))),
    ],
  );

  static final Map<String, SeatAvailability> _seats = {
    'Bab Dukkala': const SeatAvailability(totalSeats: 6, occupiedSeats: 4, line: 'Bab Dukkala', destination: 'Mhamid'),
    'Guéliz':      const SeatAvailability(totalSeats: 6, occupiedSeats: 2, line: 'Guéliz', destination: 'Essaouira'),
    'Menara':      const SeatAvailability(totalSeats: 6, occupiedSeats: 0, line: 'Menara', destination: 'Agadir'),
    'Hivernage':   const SeatAvailability(totalSeats: 6, occupiedSeats: 6, line: 'Hivernage', destination: 'Ouarzazate'),
  };

  static final List<String> _lines = ['Bab Dukkala', 'Guéliz', 'Menara', 'Hivernage'];

  static Future<T> _delay<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return value;
  }

  Future<List<TaxiOrder>> getOrders() => _delay(List.from(_orders));
  Future<TaxiOrder?> getActiveOrder() =>
      _delay(_orders.where((o) => o.status == OrderStatus.active).firstOrNull);

  Future<void> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final i = _orders.indexWhere((o) => o.id == orderId);
    if (i != -1) _orders[i] = _orders[i].copyWith(status: OrderStatus.active);
  }

  Future<void> completeOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final i = _orders.indexWhere((o) => o.id == orderId);
    if (i != -1) _orders[i] = _orders[i].copyWith(status: OrderStatus.completed);
  }

  Future<void> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final i = _orders.indexWhere((o) => o.id == orderId);
    if (i != -1) _orders[i] = _orders[i].copyWith(status: OrderStatus.cancelled);
  }

  Future<List<QueueEntry>> getQueue() => _delay(List.from(_queue));
  Future<void> joinQueue(String lineId) => _delay(null);
  Future<List<String>> getAvailableLines() => _delay(List.from(_lines));

  Future<WalletInfo> getWallet() => _delay(_wallet);
  Future<void> processNfcPayment(double amount) async =>
      await Future.delayed(const Duration(milliseconds: 800));

  Future<SeatAvailability> getSeatAvailability(String line) => _delay(
      _seats[line] ?? const SeatAvailability(totalSeats: 6, occupiedSeats: 0, line: 'Unknown', destination: 'N/A'));
  Future<void> updateSeatOccupancy(String line, int occupied) => _delay(null);
}
