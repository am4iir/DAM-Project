import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/Teacherpages/teacher_program_widgets.dart';

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
          : Column(
              children: [
                buildTeacherDaySelector(
                  context: context,
                  days: _days,
                  selectedDayIndex: _selectedDayIndex,
                  onDaySelected: (index) {
                    setState(() => _selectedDayIndex = index);
                  },
                ),
                buildTeacherClassList(
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
