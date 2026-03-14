import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (Values passed via --dart-define)
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(adminAuthProvider);

    final baseTheme = GoogleFonts.outfitTextTheme();

    return MaterialApp(
      title: 'Campus ADMIN',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Automatically follow user settings
      
      // Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F7F2), // Premium Cream
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAFA098),
          brightness: Brightness.light,
          surface: const Color(0xFFEFECE3), // Card beige
        ),
        textTheme: baseTheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D1D1D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),

      // Dark Theme (Premium Vibe)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep Obsidian
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAFA098),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E), // Dark card
          onSurface: const Color(0xFFE0E0E0),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252525),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEFECE3),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      home: _getHome(authState),
    );
  }

  Widget _getHome(AdminAuthState authState) {
    switch (authState.status) {
      case AdminAuthStatus.authenticated:
        return const DashboardScreen();
      case AdminAuthStatus.unauthorized:
      case AdminAuthStatus.unauthenticated:
        return const LoginScreen();
      case AdminAuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
