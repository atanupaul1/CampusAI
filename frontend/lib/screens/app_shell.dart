import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../providers/warmup_provider.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import 'faq_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = [
    HomeScreen(),
    ChatScreen(),
    EventsScreen(),
    FAQScreen(), 
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger backend warmup/preload
    ref.watch(warmupProvider);
    
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedIndex: currentIndex,
          indicatorColor: Colors.transparent,
          onDestinationSelected: (index) {
            ref.read(navigationProvider.notifier).state = index;
          },
          destinations: [
            _buildNavDestination(
              context,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
            ),
            _buildNavDestination(
              context,
              icon: Icons.chat_bubble_outline_rounded,
              selectedIcon: Icons.chat_bubble_rounded,
              label: 'Chat',
            ),
            _buildNavDestination(
              context,
              icon: Icons.calendar_month_outlined,
              selectedIcon: Icons.calendar_month_rounded,
              label: 'Events',
            ),
             _buildNavDestination(
              context,
              icon: Icons.help_outline_rounded,
              selectedIcon: Icons.help_rounded,
              label: 'FAQs',
            ),
            _buildNavDestination(
              context,
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return NavigationDestination(
      icon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
      selectedIcon: Icon(selectedIcon, color: primaryColor),
      label: label,
    );
  }
}
