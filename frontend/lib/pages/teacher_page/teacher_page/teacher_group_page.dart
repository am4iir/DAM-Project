import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend/widgets/Teacherpages/teacher_group_widgets.dart';

class TeacherGroupPage extends StatefulWidget {
  const TeacherGroupPage({super.key});

  @override
  State<TeacherGroupPage> createState() => _TeacherGroupPageState();
}

class _TeacherGroupPageState extends State<TeacherGroupPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<dynamic> _students = [];
  Map<String, dynamic> _stats = {};
  String? _errorMessage;
  String? _teacherId;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Color> _groupColors = [
    const Color(0xFF6C63FF),
    const Color(0xFFFF6584),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFF03A9F4),
    const Color(0xFF9C27B0),
    const Color(0xFF00BCD4),
    const Color(0xFFE91E63),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );
    _loadTeacherId();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    setState(() {
      _teacherId = id?.toString();
    });
    if (_teacherId != null) {
      _fetchStudents();
    } else {
      setState(() {
        _errorMessage = "Teacher identity not found. Please log in again.";
      });
    }
  }

  Future<void> _fetchStudents() async {
    if (_teacherId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/teacher/allStudent/$_teacherId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _students = data['students'] ?? [];
          _stats = data['stats'] ?? {'totalStudents': 0, 'totalGroups': 0};
          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
      } else {
        setState(() {
          _errorMessage = "Access restricted: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Connection error. Please check your network.";
        _isLoading = false;
      });
    }
  }

  List<String> get _uniqueGroups {
    final groups = _students
        .map((s) => s['group_name']?.toString() ?? 'General')
        .toSet()
        .toList();
    groups.sort();
    return ['All', ...groups];
  }

  List<dynamic> get _filteredStudents {
    return _students.where((student) {
      final matchesSearch =
          student['username'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          student['email'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesFilter =
          _selectedFilter == 'All' || student['group_name'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color _getGroupColor(String groupName) {
    if (groupName == 'All') return const Color(0xFF6C63FF);
    final index = _uniqueGroups
        .where((g) => g != 'All')
        .toList()
        .indexOf(groupName);
    if (index < 0) return _groupColors[0];
    return _groupColors[index % _groupColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFD),
      body: _isLoading
          ? buildTeacherGroupLoadingState(context)
          : _errorMessage != null
          ? buildTeacherGroupErrorState(
              context: context,
              errorMessage: _errorMessage!,
              onRetry: _fetchStudents,
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _fetchStudents,
        displacement: 20,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: buildTeacherGroupHeader(context)),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(child: _buildStatsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(child: _buildSearchAndFilter()),
          
            _filteredStudents.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: buildTeacherGroupEmptyState(
                      context: context,
                      hasFilters:
                          _searchQuery.isNotEmpty || _selectedFilter != 'All',
                      onClearFilters: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = 'All';
                        });
                      },
                    ),
                  )
                : SliverPadding(

                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final student = _filteredStudents[index];
                        final groupColor = _getGroupColor(
                          student['group_name'] ?? 'General',
                        );
                        return buildTeacherGroupStudentCard(
                          context: context,
                          student: student,
                          index: index,
                          groupColor: groupColor,
                          onTap: () => _showStudentDetails(student),
                        );
                      }, childCount: _filteredStudents.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: buildTeacherGroupStatCard(
              context: context,
              icon: Icons.people_rounded,
              label: 'Enrollments',
              value: '${_stats['totalStudents'] ?? 0}',
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: buildTeacherGroupStatCard(
              context: context,
              icon: Icons.hub_rounded,
              label: 'Live Groups',
              value: '${_stats['totalGroups'] ?? 0}',
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTeacherGroupSearchField(
            context: context,
            onChanged: (value) => setState(() => _searchQuery = value),
            searchQuery: _searchQuery,
            onClear: () => setState(() => _searchQuery = ''),
          ),
          const SizedBox(height: 24),

          if (_uniqueGroups.length > 2) ...[
            const Text(
              'Filter by Group',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _uniqueGroups.length,
                itemBuilder: (context, index) {
                  final group = _uniqueGroups[index];
                  final isSelected = _selectedFilter == group;
                  final color = _getGroupColor(group);

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: FilterChip(
                        label: Text(
                          group,
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = group),
                        backgroundColor: color.withOpacity(0.08),
                        selectedColor: color,
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : color.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Directory Result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3142).withOpacity(0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Text(
                  '${_filteredStudents.length} Students',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(dynamic student) {
    final groupColor = _getGroupColor(student['group_name'] ?? 'General');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 40),

           
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: groupColor.withOpacity(0.1),
                      width: 8,
                    ),
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [groupColor, groupColor.withBlue(240)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: groupColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      getInitials(student['username'] ?? 'U'),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            Text(
              student['username'] ?? 'Unknown Student',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              student['email'] ?? 'no-email@edu.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: buildTeacherGroupDetailCard(
                      context: context,
                      icon: Icons.grid_view_rounded,
                      label: 'Academic Group',
                      value: student['group_name'] ?? 'General',
                      color: groupColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildTeacherGroupDetailCard(
                      context: context,
                      icon: Icons.school_rounded,
                      label: 'Studies Level',
                      value: student['level'] ?? 'L1',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F3F9),
                        foregroundColor: const Color(0xFF2D3142),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [groupColor, groupColor.withBlue(240)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: groupColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {}, // Future: message student
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
