import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final String date;
  final String location;
  final String priority;

  const EventEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.priority,
  });

  @override
  List<Object?> get props => [id, name, description, date, location, priority];

}
