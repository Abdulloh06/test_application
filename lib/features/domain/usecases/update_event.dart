import 'package:calendar_app/core/usecases/usecase.dart';
import 'package:calendar_app/features/data/models/event_model.dart';

import '../repository/events_repository.dart';

class UpdateEventUsecase extends Usecase<int, EventModel> {

  final EventsRepository _repository;

  UpdateEventUsecase(this._repository);

  @override
  Future<int> call({required params}) {
    return _repository.updateEvent(params);
  }

}