import 'package:calendar_app/features/data/models/event_model.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_bloc.dart';
import 'package:calendar_app/features/presentation/bloc/events_bloc/events_event.dart';
import 'package:calendar_app/features/presentation/widgets/custom_text_field.dart';
import 'package:calendar_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEventsPage extends StatefulWidget {
  const AddEventsPage({super.key, this.edit = false, this.event});

  final bool edit;
  final EventModel? event;

  @override
  State<AddEventsPage> createState() => _AddEventsPageState();
}

class _AddEventsPageState extends State<AddEventsPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _locationController = TextEditingController();

  final _dateController = TextEditingController();

  final _priorityController = TextEditingController();

  final List<String> _priorities = [
    '009FEE', 'EE2B00', 'EE8F00',
  ];

  bool _validated = false;

  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      _titleController.text = widget.event!.name;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.description;
      _dateController.text = widget.event!.date;
      _priorityController.text = widget.event!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: 'Event name',
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Event description',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _locationController,
                      label: 'Event location',
                    ),
                    const SizedBox(height: 16),
                    PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      itemBuilder: (context) {
                        return List.generate(_priorities.length, (i) {
                          return PopupMenuItem(
                            onTap: () {
                              setState(() {
                                _priorityController.text = _priorities[i];
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              height: 50,
                              width: 50,
                              color: Color(int.parse('0xFF${_priorities[i]}')),
                            ),
                          );
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Priority color',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 1, color: _priorityController.text.isEmpty && _validated ? Colors.red : Colors.transparent)
                            ),
                            child: Visibility(
                              visible: _priorityController.text.isNotEmpty,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                height: 50,
                                width: 50,
                                color: Color(int.parse('0xFF${_priorityController.text}')),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _priorityController.text.isEmpty && _validated,
                            child: const Column(
                              children: [
                                SizedBox(height: 5),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'This field is required',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xffbf0000),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _dateController,
                      label: 'Event time',
                      readOnly: true,
                      onTap: () async {
                        var date = _dateController.text.isNotEmpty
                            ? DateFormat('dd.MM.yyyy')
                                .parse(_dateController.text)
                            : DateTime.now();
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          currentDate: date,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2950),
                        );
                        if (newDate != null) {
                          _dateController.text = DateFormat('dd.MM.yyyy')
                              .format(newDate)
                              .toString();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 11)),
                    backgroundColor: const WidgetStatePropertyAll(Colors.blue),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                  ),
                  onPressed: () {
                    setState(() {
                      _validated = !_validated;
                    });
                    if(_formKey.currentState!.validate()) {
                      if (widget.edit) {
                        context.read<EventsBloc>().add(
                          EventsUpdateEvent(
                              event: EventModel(
                                id: widget.event!.id,
                                name: _titleController.text,
                                description: _descriptionController.text,
                                date: _dateController.text,
                                location: _locationController.text,
                                priority: _priorityController.text,
                              )),
                        );
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const EventsApp()), (route) => false);
                      } else {
                        context.read<EventsBloc>().add(
                          EventsAddEvent(
                              event: EventModel(
                                id: 0,
                                name: _titleController.text,
                                description: _descriptionController.text,
                                date: _dateController.text,
                                location: _locationController.text,
                                priority: _priorityController.text,
                              )),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text(
                    'Add event',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
