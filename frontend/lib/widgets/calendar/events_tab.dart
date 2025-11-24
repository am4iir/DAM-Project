import 'package:flutter/material.dart';
import 'timetable_item.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  String _selectedDay = 'Monday';

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Day Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDay,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    setState(() {
                      _selectedDay = value;
                    });
                  },
                  itemBuilder: (context) => _days
                      .map((day) => PopupMenuItem(
                            value: day,
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Events List
          Column(
            children: [
              TimetableItem(
                startTime: '10:50am',
                endTime: '11:05am',
                title: 'Morning Break',
                color: Colors.blue[100]!,
                isBreak: true,
              ),
              TimetableItem(
                startTime: '11:05am',
                endTime: '11:54am',
                title: 'Mathematics',
                subtitle: 'by ken Shakumar',
                color: Colors.yellow[100]!,
              ),
              TimetableItem(
                startTime: '12:00pm',
                endTime: '12:50pm',
                title: 'Mathematics',
                subtitle: 'by ken Shakumar',
                color: Colors.purple[100]!,
              ),
              TimetableItem(
                startTime: '12:50pm',
                endTime: '1:40pm',
                title: 'Mathematics',
                subtitle: 'by ken Shakumar',
                color: Colors.grey[300]!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

