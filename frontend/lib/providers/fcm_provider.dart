import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../services/fcm_service.dart';

final fcmServiceProvider = Provider<FCMService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FCMService(apiService);
});

/// A simple provider to trigger FCM initialization.
final fcmInitializerProvider = FutureProvider<void>((ref) async {
  final authState = ref.watch(authProvider);
  
  // Only initialize if the user is authenticated
  if (authState.status == AuthStatus.authenticated) {
    final fcmService = ref.read(fcmServiceProvider);
    await fcmService.initialize();
  }
});
