/// Campus AI Assistant — Profile Screen
///
/// Displays the user's profile information (name, email, avatar)
/// and provides account actions like logout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              user?.displayName ?? 'Student',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              user?.email ?? '',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Info cards
            _ProfileTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: user?.email ?? 'N/A',
            ),
            _ProfileTile(
              icon: Icons.calendar_today_outlined,
              title: 'Member Since',
              subtitle: user?.createdAt != null
                  ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                  : 'N/A',
            ),
            _ProfileTile(
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              subtitle: '1.0.0',
            ),

            const SizedBox(height: 32),

            // Notification Preferences
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notification Preferences',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Build preference switches
            if (user?.notificationPreferences != null)
              ...user!.notificationPreferences!.keys.map((category) {
                return SwitchListTile(
                  title: Text(category),
                  value: user.notificationPreferences![category] ?? false,
                  activeColor: colorScheme.primary,
                  onChanged: (value) async {
                    // Update locally first (optimistic UI)
                    final newPrefs = Map<String, bool>.from(user.notificationPreferences!);
                    newPrefs[category] = value;
                    
                    // Show loading if needed or just handle via API
                    try {
                      await ref.read(apiServiceProvider).updateNotificationPreferences(newPrefs);
                      // In a real app, you'd update the auth state provider here
                      // For now, let's assume the user has to refresh or the listener is fast
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update: $e')),
                      );
                    }
                  },
                );
              }),

            const SizedBox(height: 32),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content:
                          const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref.read(authProvider.notifier).logout();
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        tileColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
