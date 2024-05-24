import 'package:calendar_app/core/usecases/usecase.dart';
import 'package:calendar_app/features/data/models/event_model.dart';
import 'package:calendar_app/features/domain/repository/events_repository.dart';

class GetEventsUseCase implements Usecase<List, void> {
  final EventsRepository _repository;

  GetEventsUseCase(this._repository);

  @override
  Future<List<EventModel>> call({void params}) {
    return _repository.getEvents();
  }
}
