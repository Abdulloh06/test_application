import 'package:calendar_app/core/utils/get_it.dart';
import 'package:calendar_app/features/domain/usecases/add_event.dart';
import 'package:calendar_app/features/domain/usecases/delete_event.dart';
import 'package:calendar_app/features/domain/usecases/get_events.dart';
import 'package:calendar_app/features/domain/usecases/update_event.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_bloc.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_event.dart';
import 'package:calendar_app/features/presentation/pages/events_page/events_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpGetIt();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsBloc>(
      create: (_) => EventsBloc(
        getIt.get<GetEventsUseCase>(),
        getIt.get<UpdateEventUsecase>(),
        getIt.get<DeleteEventUsecase>(),
        getIt.get<AddEventUsecase>(),
      )..add(EventsInitEvent()),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Events app',
        home: EventsApp(),
      ),
    );
  }
}

class EventsApp extends StatelessWidget {
  const EventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventsPage();
  }
}
