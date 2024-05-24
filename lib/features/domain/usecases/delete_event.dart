
import 'package:calendar_app/core/usecases/usecase.dart';

import '../repository/events_repository.dart';

class DeleteEventUsecase extends Usecase<int, int> {

  final EventsRepository _repository;

  DeleteEventUsecase(this._repository);

  @override
  Future<int> call({required int params}) {
    return _repository.deleteEvent(params);
  }
}