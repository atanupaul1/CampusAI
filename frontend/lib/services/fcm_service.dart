import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class FCMService {
  final ApiService _apiService;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  FCMService(this._apiService);

  /// Initialize FCM and set up listeners.
  Future<void> initialize() async {
    // 1. Request permissions (especially for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('User granted notification permission');
      
      // 2. Get the token
      String? token = await _fcm.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      // 3. Listen for token refreshes
      _fcm.onTokenRefresh.listen(_registerToken);

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
        }

        if (message.notification != null) {
          if (kDebugMode) {
            print('Message also contained a notification: ${message.notification!.title}');
          }
          // Note: You can show a local snackbar or dialog here
        }
      });

      // 5. Handle background/terminated state click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) print('Notification clicked: ${message.data}');
        // Note: Navigate to the specific event if event_id is present
      });
    } else {
      if (kDebugMode) print('User declined or has not accepted permission');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      await _apiService.registerDeviceToken(token, platform);
      if (kDebugMode) print('FCM Token registered: $token');
    } catch (e) {
      if (kDebugMode) print('Error registering FCM token: $e');
    }
  }
}
