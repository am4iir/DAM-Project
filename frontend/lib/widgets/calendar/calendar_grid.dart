import 'package:flutter/material.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final List<DateTime> absentDates;
  final List<DateTime> leaveDates;
  final Color primaryColor;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.absentDates,
    required this.leaveDates,
    required this.primaryColor,
  });

  // Pre-compute date sets for faster lookups (O(1) instead of O(n))
  Set<int> _getAbsentDateSet() {
    return absentDates
        .where((d) => d.year == currentMonth.year && d.month == currentMonth.month)
        .map((d) => d.day)
        .toSet();
  }

  Set<int> _getLeaveDateSet() {
    return leaveDates
        .where((d) => d.year == currentMonth.year && d.month == currentMonth.month)
        .map((d) => d.day)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    // Convert weekday (1=Monday, 7=Sunday) to 0=Sunday, 6=Saturday
    final firstWeekday = (firstDayOfMonth.weekday % 7);
    
    // Pre-compute date sets once for the entire month
    final absentDateSet = _getAbsentDateSet();
    final leaveDateSet = _getLeaveDateSet();

    return Column(
      children: [
        // Days of week header - use const for better performance
        Row(
          children: const [
            Expanded(child: _DayHeader(day: 'S')),
            Expanded(child: _DayHeader(day: 'M')),
            Expanded(child: _DayHeader(day: 'T')),
            Expanded(child: _DayHeader(day: 'W')),
            Expanded(child: _DayHeader(day: 'T')),
            Expanded(child: _DayHeader(day: 'F')),
            Expanded(child: _DayHeader(day: 'S')),
          ],
        ),
        const SizedBox(height: 12),

        // Calendar days - optimized with pre-computed sets
        ...List.generate(6, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                if (dayNumber < 1 || dayNumber > lastDayOfMonth.day) {
                  return const Expanded(child: SizedBox());
                }

                // Fast O(1) lookup instead of O(n) any() check
                final isAbsent = absentDateSet.contains(dayNumber);
                final isLeave = leaveDateSet.contains(dayNumber);

                Color? circleColor;
                if (isAbsent) {
                  circleColor = Colors.red;
                } else if (isLeave) {
                  circleColor = primaryColor;
                }

                return Expanded(
                  child: Center(
                    child: circleColor != null
                        ? _CalendarDay(
                            dayNumber: dayNumber,
                            color: circleColor,
                          )
                        : _CalendarDayText(dayNumber: dayNumber),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

// Extracted widgets for better performance and const optimization
class _DayHeader extends StatelessWidget {
  final String day;
  const _DayHeader({required this.day});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        day,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int dayNumber;
  final Color color;
  const _CalendarDay({required this.dayNumber, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$dayNumber',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayText extends StatelessWidget {
  final int dayNumber;
  const _CalendarDayText({required this.dayNumber});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$dayNumber',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

