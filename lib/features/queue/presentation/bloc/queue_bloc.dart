import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/entities/queue_entry.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/usecases/get_queue_usecase.dart';
import 'package:pro.stations.wetaxi.ma/features/queue/domain/usecases/join_queue_usecase.dart';

// Events
abstract class QueueEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadQueue extends QueueEvent {}

class JoinQueue extends QueueEvent {
  final String lineId;
  JoinQueue(this.lineId);
  @override
  List<Object?> get props => [lineId];
}

// States
abstract class QueueState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {}

class QueueLoading extends QueueState {}

class QueueLoaded extends QueueState {
  final List<QueueEntry> entries;
  final QueueEntry? myEntry;
  QueueLoaded({required this.entries, this.myEntry});
  @override
  List<Object?> get props => [entries, myEntry];
}

class QueueError extends QueueState {
  final String message;
  QueueError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final GetQueueUseCase getQueue;
  final JoinQueueUseCase joinQueue;

  QueueBloc({required this.getQueue, required this.joinQueue})
      : super(QueueInitial()) {
    on<LoadQueue>(_onLoad);
    on<JoinQueue>(_onJoin);
  }

  Future<void> _onLoad(LoadQueue e, Emitter<QueueState> emit) async {
    emit(QueueLoading());
    try {
      final entries = await getQueue();
      emit(QueueLoaded(entries: entries, myEntry: entries.firstOrNull));
    } catch (err) {
      emit(QueueError(err.toString()));
    }
  }

  Future<void> _onJoin(JoinQueue e, Emitter<QueueState> emit) async {
    try {
      await joinQueue(e.lineId);
      add(LoadQueue());
    } catch (err) {
      emit(QueueError(err.toString()));
    }
  }
}
