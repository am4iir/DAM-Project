import 'package:flutter/material.dart';
import 'timetable_item.dart';

class TimetableTab extends StatefulWidget {
  const TimetableTab({super.key});

  @override
  State<TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  String _selectedDay = 'Sunday';

  final List<String> _days = ['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday'];

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
                      Icons.calendar_today,
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

          // Timetable List
          Column(
            children: [
              TimetableItem(
                startTime: '8:30am',
                endTime: '10:00am',
                title: 'Mathematics',
                subtitle: 'by ken Shakumar',
                color:Colors.blue[100]!,
              ),
              TimetableItem(
                startTime: '10:00am',
                endTime: '11:30am',
                title: 'Mathematics',
                subtitle: 'by ken Shakumar',
                color: Colors.blue[100]!,
              ),
              TimetableItem(
                startTime: '11:30pm',
                endTime: '13:00pm',
                title: 'Mathematics',
                subtitle: 'by ken Shakumar',
                color: Colors.blue[100]!,
              ),
              TimetableItem(
                startTime: '13:00am',
                endTime: '14:30am',
                title: 'Mathematics',
                subtitle: 'by ken Shakumar',
                color: Colors.blue[100]!,
              ),
              TimetableItem(
                startTime: '14:30pm',
                endTime: '16:00pm',
                title: 'Mathematics',
                subtitle: 'by ken Shakumar',
                color :Colors.blue[100]!,
              ),
           
            ],
          ),
        ],
      ),
    );
  }
}

