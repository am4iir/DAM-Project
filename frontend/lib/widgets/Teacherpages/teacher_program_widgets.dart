import 'package:flutter/material.dart';


Widget buildTeacherDaySelector({
  required BuildContext context,
  required List<String> days,
  required int selectedDayIndex,
  required Function(int) onDaySelected,
}) {
  return Container(
    height: 90,
    padding: const EdgeInsets.symmetric(vertical: 16),
    color: Colors.white,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        bool isSelected = selectedDayIndex == index;
        return GestureDetector(
          onTap: () => onDaySelected(index),
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.grey[200]!,
              ),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}


Widget buildTeacherClassList({
  required BuildContext context,
  required List<dynamic> timetable,
  required List<String> days,
  required int selectedDayIndex,
}) {
  final filteredClasses = timetable
      .where((c) => c['day'] == days[selectedDayIndex])
      .toList();

  if (filteredClasses.isEmpty) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee_rounded, size: 64, color: Colors.brown[200]),
            const SizedBox(height: 16),
            const Text(
              'No classes to teach today!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  return Expanded(
    child: ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredClasses.length,
      itemBuilder: (context, index) {
        final item = filteredClasses[index];
        return buildTeacherClassCard(item: item);
      },
    ),
  );
}


Widget buildTeacherClassCard({required dynamic item}) {
  return IntrinsicHeight(
    child: Row(
      children: [
        Column(
          children: [
            Text(
              item['time'].split(' - ')[0],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Expanded(
              child: VerticalDivider(thickness: 2, color: Colors.blueAccent),
            ),
            Text(
              item['time'].split(' - ')[1],
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['subject'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['type'] ?? 'Lecture',
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['room'] ?? 'Room TBD',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.groups_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Group: ${item['group_name'] ?? 'Unknown'}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
