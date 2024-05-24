
import 'package:calendar_app/features/data/models/event_model.dart';
import 'package:equatable/equatable.dart';

abstract class EventsState extends Equatable {}

class EventsInitState extends EventsState {
  final List<EventModel> events;

  EventsInitState({required this.events});

  @override
  List<Object?> get props => [events];
}

class EventsLoadingState extends EventsState {
  @override
  List<Object?> get props => [];
}

class EventsErrorState extends EventsState {
  final String error;

  EventsErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}