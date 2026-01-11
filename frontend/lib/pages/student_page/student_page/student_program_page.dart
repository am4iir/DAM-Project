import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProgramPage extends StatefulWidget {
  final int groupId; // Pass the group ID of the student
  const StudentProgramPage({super.key, this.groupId = 1});

  @override
  State<StudentProgramPage> createState() => _StudentProgramPageState();
}

class _StudentProgramPageState extends State<StudentProgramPage> {
  int _selectedDayIndex = 0;
  final List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];
  List<dynamic> _timetable = [];
  bool _isLoading = true;

  int? _currentGroupId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getInt('group_id');

    setState(() {
      _currentGroupId = storedId ?? widget.groupId;
    });

    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    if (_currentGroupId == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3001/admin/programs/timetable/$_currentGroupId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _timetable = data['timetable'] ?? [];
          _isLoading = false;
        });
      } else {
        debugPrint('Failed to load timetable: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading timetable: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'My Weekly Schedule',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchTimetable();
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [_buildDaySelector(), _buildClassList()]),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          bool isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
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
                  _days[index],
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

  Widget _buildClassList() {
    final filteredClasses = _timetable
        .where((c) => c['day'] == _days[_selectedDayIndex])
        .toList();

    if (filteredClasses.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny_rounded, size: 64, color: Colors.orange[200]),
              const SizedBox(height: 16),
              const Text(
                'Enjoy your free time!',
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
          return _buildClassCard(item);
        },
      ),
    );
  }

  Widget _buildClassCard(dynamic item) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Text(
                item['time'].split(' - ')[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
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
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['type'] ?? 'Lecture',
                          style: const TextStyle(
                            color: Colors.blue,
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.person_3_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['teacher_name'] ?? 'No teacher',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
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
}
