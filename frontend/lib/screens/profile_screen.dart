import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import 'feedback_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  void _editName(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(authProvider.notifier).updateProfile(displayName: newName);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAvatarMenu(String avatarUrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fullscreen_rounded, color: Color(0xFFFD5D11)),
              title: const Text('View Photo', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _viewFullPhoto(avatarUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFFFD5D11)),
              title: const Text('Add or Update Picture', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded, color: Color(0xFFFD5D11)),
              title: const Text('Set from URL or Seed', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _editAvatarByUrl(avatarUrl);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewFullPhoto(String url) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(ctx),
          ),
        ),
        body: Center(
          child: Hero(
            tag: 'profile_pic',
            child: Image.network(
              url,
              fit: BoxFit.contain,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator(color: Colors.white);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );
      
      if (image != null) {
        // Show loading
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading picture...')),
        );
        
        await ref.read(authProvider.notifier).uploadAndSaveAvatar(File(image.path));
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _editAvatarByUrl(String? currentUrl) {
    final controller = TextEditingController(text: currentUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Avatar URL or Seed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter an image URL or a Dicebear seed.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Avatar URL or Seed',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              String input = controller.text.trim();
              if (input.isNotEmpty) {
                if (!input.startsWith('http')) {
                  input = 'https://api.dicebear.com/7.x/avataaars/png?seed=$input';
                }
                ref.read(authProvider.notifier).updateProfile(avatarUrl: input);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final textTheme = Theme.of(context).textTheme;
    final displayName = user?.displayName ?? 'Alex Johnson';
    final avatarUrl = user?.avatarUrl ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=Alex';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // Avatar Section
            GestureDetector(
              onTap: () => _showAvatarMenu(avatarUrl),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Hero(
                    tag: 'profile_pic',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                          colorFilter: authState.isProfileUpdating 
                            ? ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
                            : null,
                        ),
                      ),
                      child: authState.isProfileUpdating 
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFD5D11),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _editName(displayName),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'alex.johnson@university.edu',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Info List
            _ProfileInfoCard(
              icon: Icons.email_rounded,
              title: 'EMAIL',
              value: user?.email ?? 'alex.johnson@university.edu',
              iconColor: const Color(0xFFFD5D11),
              iconBgColor: const Color(0xFFFFF0E8),
            ),
            _ProfileInfoCard(
              icon: Icons.calendar_today_rounded,
              title: 'MEMBER SINCE',
              value: 'September 2023',
              iconColor: const Color(0xFFFD5D11),
              iconBgColor: const Color(0xFFFFF0E8),
            ),
            _ProfileInfoCard(
              icon: Icons.info_rounded,
              title: 'APP VERSION',
              value: 'v2.4.8 (Stable)',
              iconColor: const Color(0xFFFD5D11),
              iconBgColor: const Color(0xFFFFF0E8),
            ),
            _ProfileInfoCard(
              icon: Icons.chat_bubble_rounded,
              title: 'Share Feedback',
              value: 'Help us improve your experience',
              iconColor: const Color(0xFFFD5D11),
              iconBgColor: const Color(0xFFFFF0E8),
              showArrow: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD5D11),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: const Color(0xFFFD5D11).withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
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
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final Color iconBgColor;
  final bool showArrow;
  final VoidCallback? onTap;

  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.iconBgColor,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
          ),
        ),
        trailing: showArrow ? Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400) : null,
      ),
    );
  }
}
