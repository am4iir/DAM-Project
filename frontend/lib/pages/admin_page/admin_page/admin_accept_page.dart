import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/widgets/Adminpages/admin_accept_widgets.dart';

class AdminAcceptPage extends StatefulWidget {
  const AdminAcceptPage({super.key});

  @override
  State<AdminAcceptPage> createState() => _AdminAcceptPageState();
}

class _AdminAcceptPageState extends State<AdminAcceptPage> {
  late Future<List<dynamic>> _usersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final String _baseUrl = 'http://10.0.2.2:3001/admin';

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _fetchPendingUsers();
    });
  }

  Future<List<dynamic>> _fetchPendingUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/show_users'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['users'] ?? [];
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _handleUserAction(int userId, bool accept) async {
    final endpoint = accept ? 'accept' : 'reject';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': userId}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${accept ? 'accepted' : 'rejected'} successfully',
            ),
            backgroundColor: accept ? Colors.green : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${accept ? 'accept' : 'reject'} user'),
            backgroundColor: Colors.red,
          ),
        );
      }

      _refreshUsers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: RefreshIndicator(
        onRefresh: () async => _refreshUsers(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: cs.background,
              title: const Text(
                'User Requests',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            SliverToBoxAdapter(
              child: FutureBuilder<List<dynamic>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AdminAcceptLoadingState();
                  }

                  if (snapshot.hasError) {
                    return AdminAcceptErrorState(onRetry: _refreshUsers);
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const AdminAcceptEmptyState();
                  }

                  final users = snapshot.data!;
                  final filteredUsers = users.where((user) {
                    final username = (user['username'] ?? '')
                        .toString()
                        .toLowerCase();
                    final email = (user['email'] ?? '')
                        .toString()
                        .toLowerCase();

                    return username.contains(_searchQuery) ||
                        email.contains(_searchQuery);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminAcceptHeaderCard(totalUsers: filteredUsers.length),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by username or email',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: cs.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: cs.outline.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'All Requests',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${filteredUsers.length} users',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return AdminUserRow(
                            user: user,
                            onAccept: () => _handleUserAction(user['id'], true),
                            onReject: () =>
                                _handleUserAction(user['id'], false),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
