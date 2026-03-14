import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = authState.user?.displayName ?? 'Student';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _Header(),
              
              const SizedBox(height: 24),
              
              // Welcome Banner
              _WelcomeBanner(displayName: displayName),
              
              const SizedBox(height: 24),
              
              // Action Cards Grid
              Column(
                children: [
                  _ChatActionCard(
                    onTap: () => ref.read(navigationProvider.notifier).state = 1,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _GridActionCard(
                          icon: Icons.calendar_today_rounded,
                          title: 'Events',
                          subtitle: '4 TODAY',
                          iconBgColor: const Color(0xFFE7F0FF),
                          iconColor: const Color(0xFF357AF6),
                          onTap: () => ref.read(navigationProvider.notifier).state = 2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _GridActionCard(
                          icon: Icons.help_outline_rounded,
                          title: 'FAQs',
                          subtitle: 'HELP CENTER',
                          iconBgColor: const Color(0xFFFFF4E5),
                          iconColor: const Color(0xFFF9A825),
                          onTap: () => ref.read(navigationProvider.notifier).state = 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Tip of the Day
              Text(
                'TIP OF THE DAY',
                style: textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.2,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _TipCard(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFD5D11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Hub',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Campus Life',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String displayName;

  const _WelcomeBanner({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/banners/home_banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back, $displayName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ChatActionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFD5D11),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: const Text(
          'Chat with AI',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          'Your 24/7 academic assistant',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.smart_toy_rounded, color: Color(0xFFFD5D11)),
        ),
      ),
    );
  }
}

class _GridActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _GridActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  static const _tips = [
    "The Pomodoro Technique is great for staying focused. Study for 25 minutes, then take a 5-minute break.",
    "Stay hydrated! Drinking water helps maintain concentration and energy levels during long study sessions.",
    "Review your notes within 24 hours of a lecture to improve long-term retention by up to 80%.",
    "A clean workspace leads to a clear mind. Spend 5 minutes decluttering your desk before you start.",
    "Try 'Active Recall' instead of re-reading. Test yourself on the material to strengthen memory pathways.",
    "Prioritize sleep! Your brain processes and stores information during deep sleep cycles.",
    "Use the 'Eat the Frog' method: tackle your most difficult or stressful task first thing in the morning."
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate index based on 6-hour intervals
    final hoursSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 60);
    final tipIndex = (hoursSinceEpoch ~/ 6) % _tips.length;
    final activeTip = _tips[tipIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE8E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Color(0xFFFD5D11), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '"$activeTip"',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
