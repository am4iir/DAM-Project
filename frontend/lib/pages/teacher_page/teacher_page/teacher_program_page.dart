import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherProgramPage extends StatefulWidget {
  const TeacherProgramPage({super.key});

  @override
  State<TeacherProgramPage> createState() => _TeacherProgramPageState();
}

class _TeacherProgramPageState extends State<TeacherProgramPage> {
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
  int? _teacherId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getInt('id');
    debugPrint('=== Teacher Program Page ===');
    debugPrint('Stored teacher ID: $storedId');

    if (storedId != null) {
      setState(() {
        _teacherId = storedId;
      });
      _fetchTimetable();
    } else {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('No teacher ID found in SharedPreferences');
    }
  }

  Future<void> _fetchTimetable() async {
    if (_teacherId == null) return;

    debugPrint('Fetching timetable for teacher ID: $_teacherId');

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3001/admin/programs/timetable/teacher/$_teacherId',
        ),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _timetable = data['timetable'] ?? [];
          _isLoading = false;
        });
        debugPrint('Loaded ${_timetable.length} classes');
      } else {
        debugPrint('Failed to load timetable: ${response.statusCode}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading timetable: $e');
      if (mounted) setState(() => _isLoading = false);
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
          'My Teaching Schedule',
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
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
}
