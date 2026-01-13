import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminProgramPage extends StatefulWidget {
  final Map<String, dynamic>? group;
  const AdminProgramPage({super.key, this.group});

  @override
  State<AdminProgramPage> createState() => _AdminProgramPageState();
}

class _AdminProgramPageState extends State<AdminProgramPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDayIndex = 0;

  final List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  late List<Map<String, dynamic>> _timetable;

  final List<String> _slots = [
    '08:30 - 10:00',
    '10:00 - 11:30',
    '11:30 - 13:00',
    '13:00 - 14:30',
    '14:30 - 16:00',
  ];

  bool _isPublishing = false;
  List<dynamic> _dbTeachers = [];
  List<dynamic> _dbModules = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    _fetchGroupData();
    _timetable = [];
  }

  Future<void> _fetchGroupData() async {
    final groupId = widget.group?['id'];
    print(groupId);
    debugPrint(' Fetching data for Group ID: $groupId');
    if (groupId == null) {
      _showError('Error: No Group ID provided');
      if (mounted) setState(() => _isLoadingData = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse(
          'http://10.0.2.2:3001/admin/programs/group/$groupId/teachers',
        ),
      );
      if (res.statusCode == 200) {
        setState(() => _dbTeachers = json.decode(res.body)['teachers'] ?? []);
      } else {
        _showError('Teachers error: ${res.statusCode}');
      }
    } catch (e) {
      _showError('Teachers connection failed: $e');
    }

    try {
      final res = await http.get(
        Uri.parse('http://10.0.2.2:3001/admin/modules/all'),
      );
      if (res.statusCode == 200) {
        final List<dynamic> allModules = json.decode(res.body)['modules'] ?? [];
        final groupLevel = widget.group?['level'];

        debugPrint('--- Module Filtering Debug ---');
        debugPrint('Group Level: "$groupLevel"');
        debugPrint('Total Modules Fetched: ${allModules.length}');

        setState(() {
          final groupLevel = widget.group?['level']?.toString();
          if (groupLevel != null) {
            _dbModules = allModules.where((m) {
              final mLevel = m['level'].toString().trim().toLowerCase();
              final gLevel = groupLevel.trim().toLowerCase();
              return mLevel == gLevel;
            }).toList();
          } else {
            _dbModules = allModules;
          }
          debugPrint('Total Modules Displayed: ${_dbModules.length}');
        });
      } else {
        _showError('Modules error: ${res.statusCode}');
      }
    } catch (e) {
      _showError('Modules connection failed: $e');
    }

    await _fetchExistingTimetable();

    if (mounted) setState(() => _isLoadingData = false);
  }

  void _showError(String msg) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    });
  }

  Future<void> _fetchExistingTimetable() async {
    final groupId = widget.group?['id'];
    if (groupId == null) return;
    try {
      final res = await http.get(
        Uri.parse('http://10.0.2.2:3001/admin/programs/timetable/$groupId'),
      );
      if (res.statusCode == 200) {
        setState(() {
          _timetable = (json.decode(res.body)['timetable'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching timetable: $e');
    }
  }

  Future<void> _publishTimetable() async {
    final groupId = widget.group?['id'];
    if (groupId == null) {
      _showError('Error: Cannot publish without a valid Group ID');
      return;
    }
    setState(() => _isPublishing = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3001/admin/programs/save-timetable'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'groupId': groupId, 'timetable': _timetable}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Timetable published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMsg = 'Server error (${response.statusCode})';
        try {
          if (response.headers['content-type']?.contains('application/json') ??
              false) {
            errorMsg = json.decode(response.body)['error'] ?? errorMsg;
          } else {
            errorMsg =
                'Server returned HTML instead of JSON. Check route order in server.js.';
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isPublishing = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddClassDialog() {
    if (_dbModules.isEmpty || _dbTeachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data is missing (modules or teachers)')),
      );
      return;
    }

    final String? groupLevel = widget.group?['level']?.toString();

    final filteredModules = _dbModules.where((module) {
      if (groupLevel == null) return false;

      final mLevel = module['level'].toString().trim().toLowerCase();
      final gLevel = groupLevel.trim().toLowerCase();

      return mLevel == gLevel;
    }).toList();

    if (filteredModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No modules found for level: $groupLevel')),
      );
      return;
    }

    dynamic selectedModule = filteredModules[0];
    String selectedTime = _slots[0];
    String selectedDay = _days[_selectedDayIndex];
    String selectedType = 'Lecture';
    final roomController = TextEditingController(text: 'Room 1');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'New Schedule Entry',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogDropdown<dynamic>(
                  label: 'Module / Subject',
                  value: selectedModule,
                  items: filteredModules
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            '${m['name']} (${m['teacher_name'] ?? 'No Teacher'})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedModule = v!),
                ),
                _buildDialogDropdown<String>(
                  label: 'Day',
                  value: selectedDay,
                  items: _days
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedDay = v!),
                ),
                _buildDialogDropdown<String>(
                  label: 'Time Slot',
                  value: selectedTime,
                  items: _slots
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedTime = v!),
                ),
                _buildDialogDropdown<String>(
                  label: 'Type',
                  value: selectedType,
                  items: ['Lecture', 'Practical', 'Lab', 'Seminar']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    prefixIcon: Icon(Icons.meeting_room),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // 1. Local check (already in this group's list)
                final isLocalConflict = _timetable.any(
                  (e) => e['day'] == selectedDay && e['time'] == selectedTime,
                );

                if (isLocalConflict) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Conflict: This group already has a class on $selectedDay at $selectedTime',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // 2. Database check (teacher availability)
                final tId = selectedModule['teacher_id'];
                final gId = widget.group?['id'];

                if (tId != null) {
                  try {
                    final res = await http.get(
                      Uri.parse(
                        'http://10.0.2.2:3001/admin/programs/check-conflict?teacherId=$tId&day=$selectedDay&time=$selectedTime&groupId=${gId ?? -1}',
                      ),
                    );

                    if (res.statusCode == 200) {
                      final data = json.decode(res.body);
                      if (data['conflict'] == true) {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Teacher Conflict'),
                            content: Text(data['message']),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('I will choose another time'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                    }
                  } catch (e) {
                    debugPrint('Conflict check failed: $e');
                  }
                }

                setState(() {
                  _timetable.add({
                    'subject': selectedModule['name'],
                    'teacher_id': selectedModule['teacher_id'],
                    'teacher_name': selectedModule['teacher_name'],
                    'time': selectedTime,
                    'day': selectedDay,
                    'type': selectedType,
                    'room': roomController.text,
                  });
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add to Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                items: items,
                onChanged: onChanged,
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteClass(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Class'),
        content: Text(
          'Do you want to delete ${item['subject']} from the schedule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _timetable.remove(item));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.group != null
              ? 'Schedule: ${widget.group!['name']}'
              : 'Global Schedule',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_tabController.index == 0)
            _isPublishing
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _publishTimetable,
                    icon: const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.blueAccent,
                    ),
                    tooltip: 'Publish to Students',
                  ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'My Timetable'),
            Tab(text: 'Subject List'),
          ],
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Builder(
          builder: (context) {
            // Using the rounded animation value makes the button change
            // exactly at the 50% swipe mark for a much snappier feel.
            final int currentIndex =
                _tabController.animation?.value.round() ?? _tabController.index;

            if (currentIndex != 0) return const SizedBox.shrink();

            return FloatingActionButton.extended(
              key: ValueKey<int>(currentIndex),
              onPressed: _showAddClassDialog,
              icon: const Icon(Icons.add_alarm_rounded),
              label: const Text(
                'Schedule Class',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blueAccent,
            );
          },
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildTimetableTab(), _buildSubjectsTab()],
            ),
    );
  }

  Widget _buildTimetableTab() {
    final filteredSchedule = _timetable
        .where((e) => e['day'] == _days[_selectedDayIndex])
        .toList();

    return Column(
      children: [
        // Day Selector
        Container(
          height: 90,
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              bool isSelected = _selectedDayIndex == index;
              final dayName = _days[index];
              final classCount = _timetable
                  .where((e) => e['day'] == dayName)
                  .length;

              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                    border: Border.all(
                      color: isSelected ? Colors.blueAccent : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName.substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (classCount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$classCount ${classCount == 1 ? "class" : "classes"}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.blueAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // List of Classes
        Expanded(
          child: filteredSchedule.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wb_sunny_rounded,
                        size: 64,
                        color: Colors.orange[200],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No classes scheduled for today',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredSchedule.length,
                  itemBuilder: (context, index) {
                    final item = filteredSchedule[index];
                    final teacherName = item['teacher_name'] ?? 'No Teacher';
                    final roomName = item['room'] ?? 'TBD';

                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          // Time Markers
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
                                child: VerticalDivider(
                                  thickness: 2,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(
                                item['time'].split(' - ')[1],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Class Card
                          Expanded(
                            child: GestureDetector(
                              onLongPress: () => _confirmDeleteClass(item),
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
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['subject'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            item['type'],
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () =>
                                              _confirmDeleteClass(item),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.1,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: Colors.red,
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
                                          roomName,
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
                                          teacherName,
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubjectsTab() {
    if (_dbModules.isEmpty) {
      return const Center(
        child: Text(
          'No modules found in database',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final List<Color> cardColors = [
      Colors.blue,
      Colors.teal,
      Colors.indigo,
      Colors.purple,
      Colors.blueGrey,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _dbModules.length,
      itemBuilder: (context, index) {
        final module = _dbModules[index];
        final color = cardColors[index % cardColors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level: ${module['level']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    if (module['teacher_name'] != null ||
                        module['username'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${module['teacher_name'] ?? module['username']}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _confirmDeleteModule(module),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteModule(dynamic module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: Text(
          'Are you sure you want to delete ${module['name']}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteModule(module['module_id']);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteModule(int moduleId) async {
    try {
      final res = await http.delete(
        Uri.parse('http://10.0.2.2:3001/admin/modules/delete/$moduleId'),
      );
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Module deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchGroupData(); // Refresh data
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete module: ${res.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting module: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
