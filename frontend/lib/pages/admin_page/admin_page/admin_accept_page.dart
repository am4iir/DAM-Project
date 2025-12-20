import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminAcceptPage extends StatefulWidget {
  const AdminAcceptPage({super.key});

  @override
  State<AdminAcceptPage> createState() => _AdminAcceptPageState();
}

class _AdminAcceptPageState extends State<AdminAcceptPage> {
  late Future<List<dynamic>> _usersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final String _baseUrl = 'http://10.0.2.2:3000/admin';

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
            behavior: SnackBarBehavior.floating,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: RefreshIndicator(
        onRefresh: () async => _refreshUsers(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: cs.background.withValues(alpha: 0.9),
              title: const Text(
                'User Requests',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                  onPressed: _refreshUsers,
                  icon: const Icon(Icons.refresh),
                ),
              ],
              bottom: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: cs.background,
                title: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by username or email',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: cs.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FutureBuilder<List<dynamic>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingState();
                  }
                  if (snapshot.hasError) {
                    return _ErrorState(onRetry: _refreshUsers);
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const _EmptyState();
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

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _UserRow(
                        user: filteredUsers[index],
                        onAccept: () =>
                            _handleUserAction(filteredUsers[index]['id'], true),
                        onReject: () => _handleUserAction(
                          filteredUsers[index]['id'],
                          false,
                        ),
                      );
                    },
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

class _UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _UserRow({
    required this.user,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final username = user['username'] ?? 'Unknown';
    final email = user['email'] ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primary.withOpacity(0.1),
            child: Text(
              username[0].toUpperCase(),
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),

          /// User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          /// Actions
          IconButton(
            onPressed: onReject,
            icon: const Icon(Icons.close),
            color: Colors.redAccent,
            tooltip: 'Reject',
          ),
          IconButton(
            onPressed: onAccept,
            icon: const Icon(Icons.check),
            color: Colors.green,
            tooltip: 'Accept',
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: const [
          Icon(Icons.check_circle_outline, size: 72, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No pending requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
