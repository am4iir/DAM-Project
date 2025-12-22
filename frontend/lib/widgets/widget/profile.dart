import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatelessWidget {
  final String username;
  final String email;
  final String role;
  final IconData roleIcon;
  final VoidCallback onLogout;
  final List<Widget>? extraMenuItems;

  const ProfileView({
    super.key,
    required this.username,
    required this.email,
    required this.role,
    required this.roleIcon,
    required this.onLogout,
    this.extraMenuItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(theme, cs),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(theme, cs),
                const SizedBox(height: 32),
                _buildSectionTitle(theme, 'Account Information'),
                const SizedBox(height: 12),
                _buildInfoCard(cs, Icons.person_outline, 'Username', username),
                const SizedBox(height: 12),
                _buildInfoCard(cs, Icons.email_outlined, 'Email', email),
                const SizedBox(height: 12),
                _buildInfoCard(cs, roleIcon, 'Role', role),
                const SizedBox(height: 32),
                _buildSectionTitle(theme, 'Settings'),
                const SizedBox(height: 12),
                _buildMenuTile(cs, Icons.help_outline, 'Help & Support', () {}),
                _buildMenuTile(cs, Icons.info_outline, 'About', () {}),
                _buildMenuTile(cs, Icons.lock_outline, 'Privacy Policy', () {}),
                _buildMenuTile(cs, Icons.phone_outlined, 'Contact Us', () {}),
                if (extraMenuItems != null) ...extraMenuItems!,
                const SizedBox(height: 40),
                _buildLogoutButton(context, cs),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, ColorScheme cs) {
    return SliverAppBar(
      backgroundColor: cs.background,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, ColorScheme cs) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cs.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: cs.primary.withOpacity(0.1),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ColorScheme cs,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    ColorScheme cs,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurface.withOpacity(0.7), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme cs) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.pop();
                    onLogout();
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
      ),
    );
  }
}
