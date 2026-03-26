import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// A single notification item displayed in the UI.
class AppNotification {
  final String title;
  final String body;

  /// Payload type from the backend. Known values:
  /// 'pickup_alert' | 'complaint_resolved' | 'delay_alert' | 'app_update' | 'general'
  final String type;

  final DateTime timestamp;
  final bool isNew;

  const AppNotification({required this.title, required this.body, required this.type, required this.timestamp, this.isNew = true});

  /// Builds an AppNotification from an FCM RemoteMessage payload.
  /// Expected payload shape:
  /// { "title": "...", "body": "...", "type": "pickup_alert", "timestamp": "ISO8601" }
  factory AppNotification.fromRemoteMessage(RemoteMessage message) {
    DateTime ts = DateTime.now();
    if (message.sentTime != null) ts = message.sentTime!;

    return AppNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      type: message.data['type'] as String? ?? 'general',
      timestamp: ts,
      isNew: true,
    );
  }
}

/// Handles FCM permission, device token retrieval, and foreground message streaming.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Broadcast stream — any widget can subscribe to receive live incoming notifications.
  static final StreamController<AppNotification> _controller = StreamController<AppNotification>.broadcast();

  static Stream<AppNotification> get stream => _controller.stream;

  /// Asks the user for notification permission.
  /// On iOS this shows the system popup. On Android 13+ it shows the runtime prompt.
  static Future<void> requestPermission() async {
    final NotificationSettings settings = await _messaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  /// Returns the unique FCM device token for this install.
  /// This token is printed to the debug console — pass it to your backend
  /// teammate so they can save it alongside the user's profile in the database.
  static Future<String?> getDeviceToken() async {
    final String? token = await _messaging.getToken();
    debugPrint('[FCM] Device token: $token');
    return token;
  }

  /// Starts listening for messages that arrive while the app is in the foreground.
  /// Each message is pushed onto [stream] so subscribed widgets can react.
  /// Background / terminated notifications are handled natively by Android/iOS.
  static void listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _controller.add(AppNotification.fromRemoteMessage(message));
      }
    });
  }
}
