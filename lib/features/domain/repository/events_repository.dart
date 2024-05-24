import 'package:calendar_app/features/data/models/event_model.dart';

abstract class EventsRepository {
  Future<List<EventModel>> getEvents();

  Future<void> addEvents(EventModel event);

  Future<int> updateEvent(EventModel event);

  Future<int> deleteEvent(int id);
}
