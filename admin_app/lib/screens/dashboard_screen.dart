import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'event_management_screen.dart';
import 'faq_management_screen.dart';
import 'feedback_management_screen.dart';
import 'app_config_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeView(onNavigate: _changeTab),
          const EventManagementScreen(),
          const FeedbackManagementScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BottomNavIcon(
                  icon: Icons.home_rounded,
                  isActive: _currentIndex == 0,
                  onTap: () => _changeTab(0),
                ),
                _BottomNavIcon(
                  icon: Icons.calendar_view_month_rounded,
                  isActive: _currentIndex == 1,
                  onTap: () => _changeTab(1),
                ),
                _BottomNavIcon(
                  icon: Icons.chat_bubble_outline_rounded,
                  isActive: _currentIndex == 2,
                  onTap: () => _changeTab(2),
                ),
                _BottomNavIcon(
                  icon: Icons.person_outline_rounded,
                  isActive: _currentIndex == 3,
                  onTap: () {
                    if (!mounted) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Drag handle
                            Container(
                              width: 48,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white24 
                                    : Colors.black12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Administrator Profile',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white 
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Options
                            _ProfileOptionTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Edit Profile Information',
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Profile coming soon')));
                              },
                            ),
                            const SizedBox(height: 12),
                            _ProfileOptionTile(
                              icon: Icons.camera_alt_outlined,
                              title: 'Change Avatar',
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change Avatar coming soon')));
                              },
                            ),
                            const SizedBox(height: 12),
                            _ProfileOptionTile(
                              icon: Icons.notifications_none_rounded,
                              title: 'Notification Preferences',
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon')));
                              },
                            ),
                            const SizedBox(height: 12),
                            _ProfileOptionTile(
                              icon: Icons.security_rounded,
                              title: 'Security Settings',
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security Settings coming soon')));
                              },
                            ),
                            const SizedBox(height: 32),
                            
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.red.withOpacity(0.15) 
                                      : const Color(0xFFFFE5E5),
                                  foregroundColor: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.redAccent.shade100 
                                      : Colors.redAccent,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                onPressed: () {
                                  Navigator.pop(context); // Close sheet
                                  ref.read(adminAuthProvider.notifier).signOut();
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeView extends ConsumerWidget {
  final Function(int) onNavigate;

  const _HomeView({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(adminAuthProvider).user;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF1E1E1E) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,\n${user?.displayName ?? 'Administrator'}',
                          style: textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'System Active: Ver 1.0.0',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white60 
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Shield-like Profile Icon Outline
                  Container(
                    width: 72,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.05) 
                          : const Color(0xFFF2F2F2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white.withOpacity(0.1) 
                              : const Color(0xFFE0E0E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF9E9E9E),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'Management Tools',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _AdminCard(
                        title: 'Events:',
                        subtitle: 'Manage Campus',
                        icon: Icons.calendar_today_rounded,
                        height: 220,
                        onTap: () => onNavigate(1),
                      ),
                      const SizedBox(height: 16),
                      _AdminCard(
                        title: 'Feedback:',
                        subtitle: 'User Voice',
                        icon: Icons.chat_outlined,
                        height: 180,
                        onTap: () => onNavigate(2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _AdminCard(
                        title: 'FAQs:',
                        subtitle: 'AI Knowledge',
                        icon: Icons.auto_awesome_rounded,
                        height: 180,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FAQManagementScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AdminCard(
                        title: 'Settings:',
                        subtitle: 'App Config',
                        icon: Icons.tune_rounded,
                        height: 220,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AppConfigScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double height;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.height = 200,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between icon and text
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFAFA098), // Muted greyish brown 
                  size: 36,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFFAFA098) : Colors.grey[400],
        ),
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withOpacity(0.05) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87, 
                size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
