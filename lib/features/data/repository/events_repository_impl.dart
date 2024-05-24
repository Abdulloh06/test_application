import 'package:calendar_app/features/data/data_sources/events_locale_data_source.dart';
import 'package:calendar_app/features/data/models/event_model.dart';
import 'package:calendar_app/features/domain/repository/events_repository.dart';

class EventRepositoryImpl implements EventsRepository {
  final EventsLocaleDataSource dataSource;

  EventRepositoryImpl(this.dataSource);

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      final eventModels = await dataSource.getEvents();
      return eventModels;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> addEvents(EventModel event) async {
    try {
      await dataSource.insertEvent(event);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<int> deleteEvent(int id) async {
    try {
      final res = await dataSource.deleteEvent(id);
      return res;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<int> updateEvent(EventModel event) async {
    try {
      final res = await dataSource.updateEvent(event);
      return res;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
