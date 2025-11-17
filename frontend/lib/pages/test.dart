import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List users = [];

  Future<void> fetchUsers() async {
    final url = Uri.parse(
      'http://10.0.2.2:3000/users',
    ); // أو http://192.168.1.10:3000/users
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        users = data['users']; // <-- take only the array
      });
    } else {
      print('Failed to load users');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Users",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            tileColor: Theme.of(context).colorScheme.surface,
            title: Text(
              user['username'],
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              user['email'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            trailing: Text(
              "${user['role']}",
              style: TextStyle(
                color: user['role'] == 1
                    ? Theme.of(context).colorScheme.error
                    : user['role'] == 2
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
