/// Campus AI Assistant — Home Dashboard Screen
///
/// Greeting banner with the user's name plus quick-action cards
/// for Chat, Events, FAQ, and Profile.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayName = authState.user?.displayName ?? 'Student';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Hey, $displayName! 👋',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What can I help you with today?',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // Quick Action Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
                children: [
                  _ActionCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat with AI',
                    subtitle: 'Ask me anything',
                    color: colorScheme.primary,
                    bgColor: colorScheme.primaryContainer,
                    onTap: () => _navigateToTab(context, 1),
                  ),
                  _ActionCard(
                    icon: Icons.event_rounded,
                    label: 'Events',
                    subtitle: 'Campus happenings',
                    color: colorScheme.tertiary,
                    bgColor: colorScheme.tertiaryContainer,
                    onTap: () => _navigateToTab(context, 2),
                  ),
                  _ActionCard(
                    icon: Icons.help_outline_rounded,
                    label: 'FAQs',
                    subtitle: 'Quick answers',
                    color: colorScheme.secondary,
                    bgColor: colorScheme.secondaryContainer,
                    onTap: () => _navigateToTab(context, 1),
                  ),
                  _ActionCard(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    subtitle: 'Your account',
                    color: colorScheme.error,
                    bgColor: colorScheme.errorContainer,
                    onTap: () => _navigateToTab(context, 3),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Tip of the Day card
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: colorScheme.primary, size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tip of the Day',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try asking "What events are happening this week?" in the chat!',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    // Access the nearest AppShell's tab controller
    // This works because AppShell uses an IndexedStack
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Navigate to tab $index'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: bgColor.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
