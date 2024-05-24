import 'package:calendar_app/features/data/models/event_model.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_bloc.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_event.dart';
import 'package:calendar_app/features/presentation/pages/add_events/add_events_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventSelectPage extends StatelessWidget {
  const EventSelectPage({super.key, required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: SvgPicture.asset('assets/icons/arrow_back.svg'),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventsPage(edit: true, event: event))),
                        child: const Row(
                          children: [
                            Icon(Icons.edit_note, color: Colors.white,),
                            Text('Edit', style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.description,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: Colors.white,),
                      const SizedBox(width: 5),
                      Text(event.date, style: const TextStyle(color: Colors.white,),),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Visibility(
                    visible: event.location.isNotEmpty,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white,),
                        const SizedBox(width: 5),
                        Text(event.location, style: const TextStyle(color: Colors.white,),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    const Text(
                      'Reminder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      '15 minutes before',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        style: ButtonStyle(
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
                          backgroundColor: const WidgetStatePropertyAll(Color(0xFFFEE8E9)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)
                          )),
                        ),
                        onPressed: () {
                          context.read<EventsBloc>().add(EventsDeleteEvent(id: event.id));
                          Navigator.pop(context);
                        },
                        label: const Text(
                          'Delete event',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
