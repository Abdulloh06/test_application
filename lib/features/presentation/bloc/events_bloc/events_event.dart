import 'package:calendar_app/features/data/models/event_model.dart';
import 'package:equatable/equatable.dart';

abstract class EventsEvent extends Equatable {}

class EventsInitEvent extends EventsEvent {
  @override
  List<Object?> get props => [];
}

class EventsAddEvent extends EventsEvent {
  final EventModel event;

  EventsAddEvent({required this.event});

  @override
  List<Object?> get props => [event];
}


class EventsUpdateEvent extends EventsEvent {
  final EventModel event;

  EventsUpdateEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventsDeleteEvent extends EventsEvent {
  final int id;

  EventsDeleteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}