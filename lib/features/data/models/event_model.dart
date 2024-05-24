
import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {

  const EventModel({
    required super.id,
    required super.name,
    required super.description,
    required super.date,
    required super.location,
    required super.priority,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      location: json['location'] as String,
      priority: json['priority'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'date': date,
      'location': location,
      'priority': priority,
    };
  }
}
