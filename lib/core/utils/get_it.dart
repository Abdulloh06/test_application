
import 'package:calendar_app/features/data/data_sources/database_helper.dart';
import 'package:calendar_app/features/data/data_sources/events_locale_data_source.dart';
import 'package:calendar_app/features/data/repository/events_repository_impl.dart';
import 'package:calendar_app/features/domain/repository/events_repository.dart';
import 'package:calendar_app/features/domain/usecases/add_event.dart';
import 'package:calendar_app/features/domain/usecases/delete_event.dart';
import 'package:calendar_app/features/domain/usecases/get_events.dart';
import 'package:calendar_app/features/domain/usecases/update_event.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_bloc.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setUpGetIt() async {

  // database
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.db);

  // data source
  getIt.registerSingleton<EventsLocaleDataSource>(EventsLocaleDataSource(getIt()));


  // usecases
  getIt.registerSingleton<GetEventsUseCase>(GetEventsUseCase(EventRepositoryImpl(getIt())));
  getIt.registerSingleton<AddEventUsecase>(AddEventUsecase(EventRepositoryImpl(getIt())));
  getIt.registerSingleton<UpdateEventUsecase>(UpdateEventUsecase(EventRepositoryImpl(getIt())));
  getIt.registerSingleton<DeleteEventUsecase>(DeleteEventUsecase(EventRepositoryImpl(getIt())));
  
  // bloc 
  getIt.registerFactory<EventsBloc>(() => EventsBloc(getIt(), getIt(), getIt(), getIt()));
}