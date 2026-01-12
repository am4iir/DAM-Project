import 'package:flutter/material.dart';


Widget buildAdminSliverAppBar(ThemeData theme, ColorScheme cs) {
  return SliverAppBar(
    backgroundColor: cs.background,
    pinned: true,
    elevation: 0,
    expandedHeight: 100,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'Dashboard',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
      centerTitle: false,
      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
    ),
  );
}


Widget buildAdminWelcomeCard(ThemeData theme, ColorScheme cs, String username) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [cs.primary, cs.primary.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: cs.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back,',
                style: TextStyle(
                  color: cs.onPrimary.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                username,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your platform efficiently',
                style: TextStyle(
                  color: cs.onPrimary.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.onPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.admin_panel_settings,
            size: 40,
            color: cs.onPrimary,
          ),
        ),
      ],
    ),
  );
}


Widget buildAdminStatCard(
  ColorScheme cs,
  IconData icon,
  String value,
  String label,
  Color accentColor, {
  bool isLoading = false,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cs.outline.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accentColor, size: 24),
        ),
        const SizedBox(height: 12),
        isLoading
            ? Container(
                height: 28,
                width: 50,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accentColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6)),
        ),
      ],
    ),
  );
}



Widget buildAdminActivityItem(
  ColorScheme cs,
  IconData icon,
  String title,
  String subtitle,
  String time,
  Color accentColor,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: cs.outline.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.4)),
        ),
      ],
    ),
  );
}
