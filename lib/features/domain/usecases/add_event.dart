
import 'package:calendar_app/core/usecases/usecase.dart';
import 'package:calendar_app/features/data/models/event_model.dart';
import 'package:calendar_app/features/domain/repository/events_repository.dart';

class AddEventUsecase extends Usecase<void, EventModel> {

  final EventsRepository _repository;

  AddEventUsecase(this._repository);

  @override
  Future<void> call({required EventModel params}) {
    return _repository.addEvents(params);
  }
}