import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'events_provider.dart';
import 'chat_provider.dart';

/// Provider to handle backend "warm-up" on app startup.
/// Especially useful for Render/free-tier backends that go to sleep.
final warmupProvider = Provider<void>((ref) {
  // Pre-load events to wake up the backend database/API
  ref.read(eventsProvider.notifier).loadEvents();
  
  // Try to pre-load chat sessions
  ref.read(chatProvider.notifier).loadSessions();
  
  print('Warmup: Triggered initial data fetch to wake up backend.');
});
