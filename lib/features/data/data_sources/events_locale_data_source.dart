import 'package:calendar_app/features/data/models/event_model.dart';
import 'database_helper.dart';

class EventsLocaleDataSource {
  late final DatabaseHelper databaseHelper;

  EventsLocaleDataSource(this.databaseHelper);

  Future<void> insertEvent(EventModel event) async {
    final db = await databaseHelper.database;
    await db.insert('events', event.toJson());
  }

  Future<List<EventModel>> getEvents() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> eventsList = await db.query('events');
    final List<EventModel> events = [];
    for (var studentMap in eventsList) {
      events.add(EventModel.fromJson(studentMap));
    }

    return events;
  }

  Future<int> updateEvent(EventModel event) async {
    final db = await databaseHelper.database;
    return await db.update(
      'events',
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
