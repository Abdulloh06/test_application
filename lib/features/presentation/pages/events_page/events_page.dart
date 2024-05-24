import 'package:calendar_app/core/utils/date_format_utils.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_bloc.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_state.dart';
import 'package:calendar_app/features/presentation/pages/add_events/add_events_page.dart';
import 'package:calendar_app/features/presentation/pages/event_select_page/event_select_page.dart';
import 'package:calendar_app/features/presentation/widgets/calendar_widget.dart';
import 'package:calendar_app/features/presentation/widgets/events_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  String date = '';
  DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<EventsBloc, EventsState>(
          builder: (context, state) {
            if (state is EventsLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EventsInitState) {
              return Column(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      CalendarWidget(
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2950),
                        currentDate: currentDate,
                        initialDate: DateTime.now(),
                        onDateChanged: (value) {
                          setState(() {
                            date = DateFormatUtils.formatDefault(value);
                          });
                        },
                        events: state.events,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Schedule',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.add, size: 15, color: Colors.white,),
                                  style: ButtonStyle(
                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10))),
                                    backgroundColor: const WidgetStatePropertyAll(
                                        Colors.blue),
                                    padding: const WidgetStatePropertyAll(EdgeInsets
                                        .symmetric(horizontal: 22, vertical: 8)),
                                  ),
                                  onPressed: () =>
                                      Navigator.push(context, MaterialPageRoute(builder: (
                                          context) => const AddEventsPage())),
                                  label: const Text(
                                    "Add event",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.events.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Visibility(
                            visible: date.isNotEmpty ? state.events[index].date == date : true,
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventSelectPage(event: state.events[index]))),
                              child: EventsCard(
                                name: state.events[index].name,
                                description: state.events[index].description,
                                location: state.events[index].location,
                                date: state.events[index].date,
                                priority: state.events[index].priority,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Text('Unable to load events');
            }
          },
        ),
      ),
    );
  }
}
