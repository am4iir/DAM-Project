import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Navbar extends StatefulWidget {
  const Navbar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return GNav(
      selectedIndex: widget.selectedIndex,
      onTabChange: widget.onChanged,
      rippleColor: Colors.grey.shade300,
      hoverColor: Colors.grey.shade300,
      gap: 8,
      color: const Color.fromARGB(255, 0, 0, 0),
      activeColor: Theme.of(context).colorScheme.onBackground,
      iconSize: 24,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      tabBackgroundColor: Colors.grey.shade300,
      tabs: widget.items.map((item) {
        return GButton(
          icon: item['icon'] as IconData,
          text: item['text'] as String,
        );
      }).toList(),
    );
  }
}
