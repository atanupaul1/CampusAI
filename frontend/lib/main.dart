/// Campus AI — App Entry Point
///
/// Initializes Supabase, sets up the Material 3 theme with a
/// university-themed color scheme, configures GoRouter for
/// navigation, and wraps everything in Riverpod's ProviderScope.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Pass your Supabase URL and Anon Key via --dart-define:
  //   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://your-project.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'your-supabase-anon-key'),
  );

  runApp(const ProviderScope(child: CampusAIApp()));
}

class CampusAIApp extends ConsumerWidget {
  const CampusAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Campus AI',
      debugShowCheckedModeBanner: false,

      // -------------------- Theme --------------------
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFDFCF9), // Premium Cream/Off-white
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF05A22), // Vibrant Orange
          primary: const Color(0xFFF05A22),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF1D1B1E),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFF8F7F2),
          surfaceContainer: const Color(0xFFF2F1EC),
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF05A22),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep Obsidian
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF05A22),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFE0E0E0),
          surfaceContainerLowest: const Color(0xFF121212),
          surfaceContainerLow: const Color(0xFF1A1A1A),
          surfaceContainer: const Color(0xFF242424),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252525),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          indicatorColor: const Color(0xFFF05A22).withOpacity(0.2),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF05A22),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,

      // -------------------- Routing --------------------
      home: authState.status == AuthStatus.authenticated
          ? const AppShell()
          : const LoginScreen(),
    );
  }
}
