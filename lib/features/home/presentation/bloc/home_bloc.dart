import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro.stations.wetaxi.ma/core/network/socket_service.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/entities/queue_entry.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/repositories/queue_repository.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/entities/passenger_entity.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/entities/taxi_entity.dart';
import 'package:pro.stations.wetaxi.ma/features/seats/domain/repositories/seat_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

// Internal — fired by socket listener, no loading spinner shown
class _SocketRefresh extends HomeEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final int myPosition;
  final int totalInQueue;
  final int estimatedMinutes;
  final int occupiedSeats;
  final int totalSeats;
  final String line;
  final String destination;
  final List<PassengerEntity> passengers;
  final bool hasTaxi;
  final String? taxiStatus;

  HomeLoaded({
    required this.myPosition,
    required this.totalInQueue,
    required this.estimatedMinutes,
    required this.occupiedSeats,
    required this.totalSeats,
    required this.line,
    required this.destination,
    required this.passengers,
    required this.hasTaxi,
    this.taxiStatus,
  });

  @override
  List<Object?> get props =>
      [myPosition, totalInQueue, occupiedSeats, line, passengers];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final QueueRepository _queueRepository;
  final SeatRepository _seatRepository;
  final SocketService _socketService;

  StreamSubscription<SocketEvent>? _socketSub;
  String? _subscribedStationId;

  HomeBloc({
    required QueueRepository queueRepository,
    required SeatRepository seatRepository,
    required SocketService socketService,
  })  : _queueRepository = queueRepository,
        _seatRepository = seatRepository,
        _socketService = socketService,
        super(HomeInitial()) {
    on<LoadHomeData>(_onLoad);
    on<_SocketRefresh>(_onSocketRefresh);

    // Listen to all socket events — station channel triggers a silent refresh
    _socketSub = _socketService.events.listen((event) {
      if (event.channel.startsWith('station/')) {
        add(_SocketRefresh());
      }
    });
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    _socketService.unsubscribeByOwner('HomeBloc');
    return super.close();
  }

  // ── Full load (shows spinner) ──────────────────────────────────────────────

  Future<void> _onLoad(LoadHomeData e, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final loaded = await _fetchData();
    if (loaded != null) {
      _subscribeToSocket(loaded.$1);
      emit(loaded.$2);
    } else {
      emit(HomeLoaded(
        myPosition: 0,
        totalInQueue: 0,
        estimatedMinutes: 0,
        occupiedSeats: 0,
        totalSeats: 6,
        line: 'Aucune ligne',
        destination: '-',
        passengers: const [],
        hasTaxi: false,
      ));
    }
  }

  // ── Silent socket refresh (no spinner) ────────────────────────────────────

  Future<void> _onSocketRefresh(_SocketRefresh e, Emitter<HomeState> emit) async {
    final loaded = await _fetchData();
    if (loaded != null) {
      _subscribeToSocket(loaded.$1);
      emit(loaded.$2);
    }
  }

  // ── Shared fetch logic ────────────────────────────────────────────────────

  Future<(TaxiEntity?, HomeLoaded)?> _fetchData() async {
    try {
      final taxiFuture = _seatRepository.getTaxiInfo();
      final queueFuture = _queueRepository.getQueue();

      final TaxiEntity? taxi = await taxiFuture;
      final List<QueueEntry> queues = await queueFuture;
      final QueueEntry? firstQueue = queues.firstOrNull;

      if (taxi == null && firstQueue == null) return null;

      final int position =
          firstQueue?.position ?? taxi?.queuePosition ?? 0;
      final int totalInQueue = firstQueue?.totalInQueue ?? 0;

      final loaded = HomeLoaded(
        myPosition: position,
        totalInQueue: totalInQueue,
        estimatedMinutes: position * 5,
        occupiedSeats:
            taxi?.seatsOccupied ?? firstQueue?.seatsOccupied ?? 0,
        totalSeats: taxi?.seatsTotal ?? firstQueue?.seatsTotal ?? 6,
        line: taxi?.origin ?? _parseOrigin(firstQueue?.line ?? ''),
        destination:
            taxi?.destination ?? _parseDest(firstQueue?.line ?? ''),
        passengers: taxi?.passengers ?? const [],
        hasTaxi: taxi != null,
        taxiStatus: taxi?.status,
      );
      return (taxi, loaded);
    } catch (_) {
      return null;
    }
  }

  // ── Socket channel subscription ───────────────────────────────────────────

  void _subscribeToSocket(TaxiEntity? taxi) {
    if (taxi == null || taxi.stationId.isEmpty) return;
    // Only resubscribe if the station changed
    if (_subscribedStationId == taxi.stationId) return;
    if (_subscribedStationId != null) {
      _socketService.unsubscribeByOwner('HomeBloc');
    }
    _subscribedStationId = taxi.stationId;
    _socketService.subscribe(
      SocketChannel(
        channel: 'station/${taxi.stationId}',
        owner: 'HomeBloc',
      ),
    );
  }

  String _parseOrigin(String line) {
    final parts = line.split(' → ');
    return parts.isNotEmpty ? parts[0] : line;
  }

  String _parseDest(String line) {
    final parts = line.split(' → ');
    return parts.length > 1 ? parts[1] : '-';
  }
}
