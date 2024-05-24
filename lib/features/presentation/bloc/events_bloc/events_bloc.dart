import 'package:calendar_app/features/domain/usecases/add_event.dart';
import 'package:calendar_app/features/domain/usecases/delete_event.dart';
import 'package:calendar_app/features/domain/usecases/get_events.dart';
import 'package:calendar_app/features/domain/usecases/update_event.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_event.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEventsUseCase _get;
  final UpdateEventUsecase _update;
  final DeleteEventUsecase _delete;
  final AddEventUsecase _add;

  EventsBloc(this._get, this._update, this._delete, this._add)
      : super(EventsLoadingState()) {
    on<EventsInitEvent>((event, emit) =>
        _getEvents(event: event, emit: emit));
    on<EventsUpdateEvent>(
        (event, emit) => _updateEvent(event: event, emit: emit));
    on<EventsAddEvent>((event, emit) =>
        _addEvent(event: event, emit: emit));
    on<EventsDeleteEvent>(
        (event, emit) => _deleteEvent(event: event, emit: emit));
  }

  Future<void> _getEvents({
    required EventsInitEvent event,
    required Emitter<EventsState> emit,
  }) async {
    emit(EventsLoadingState());

    try {
      var result = await _get.call();
      emit(EventsInitState(events: result));
    } catch (e) {
      emit(EventsErrorState(error: e.toString()));
    }
  }

  Future<void> _addEvent({
    required EventsAddEvent event,
    required Emitter<EventsState> emit,
  }) async {
    emit(EventsLoadingState());
    try {
      await _add.call(params: event.event);
      final list = await _get.call();
      emit(EventsInitState(events: list));
    } catch (e) {
      emit(EventsErrorState(error: e.toString()));
    }
  }

  Future<void> _updateEvent({
    required EventsUpdateEvent event,
    required Emitter<EventsState> emit,
  }) async {
    emit(EventsLoadingState());
    try {
      await _update.call(params: event.event);
      final list = await _get.call();
      emit(EventsInitState(events: list));
    } catch (e) {
      emit(EventsErrorState(error: e.toString()));
    }
  }

  Future<void> _deleteEvent({
    required EventsDeleteEvent event,
    required Emitter<EventsState> emit,
  }) async {
    emit(EventsLoadingState());

    try {
      await _delete.call(params: event.id);
      final list = await _get.call();
      emit(EventsInitState(events: list));
    } catch (e) {
      emit(EventsErrorState(error: e.toString()));
    }
  }
}
