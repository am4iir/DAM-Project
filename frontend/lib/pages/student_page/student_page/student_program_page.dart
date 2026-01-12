import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/Studentpages/student_program_widgets.dart';

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
          : Column(
              children: [
                buildDaySelector(
                  context: context,
                  days: _days,
                  selectedDayIndex: _selectedDayIndex,
                  onDaySelected: (index) {
                    setState(() => _selectedDayIndex = index);
                  },
                ),
                buildClassList(
                  context: context,
                  timetable: _timetable,
                  days: _days,
                  selectedDayIndex: _selectedDayIndex,
                ),
              ],
            ),
    );
  }
}
