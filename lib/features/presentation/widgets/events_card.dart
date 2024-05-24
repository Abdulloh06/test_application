import 'package:flutter/material.dart';

class EventsCard extends StatelessWidget {
  const EventsCard({
    super.key,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.priority,
  });
  final String name;
  final String description;
  final String location;
  final String date;
  final String priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Color(int.parse('0xFF$priority')).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Color(int.parse('0xFF$priority')),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled),
                        const SizedBox(width: 5),
                        Text(date),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Visibility(
                      visible: location.isNotEmpty,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded),
                          const SizedBox(width: 5),
                          Text(location),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
