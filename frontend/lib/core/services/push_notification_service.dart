import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';
import '../utils/debug_logger.dart';

// Top-level — required by firebase_messaging for background/terminated handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized when this fires; nothing extra needed.
}

const _androidChannel = AndroidNotificationChannel(
  'wakeell_bookings',
  'Booking Notifications',
  description: 'Session bookings, acceptances, and reminders',
  importance: Importance.high,
);

class PushNotificationService {
  static const _tag = 'PushNotifService';
  static final _local = FlutterLocalNotificationsPlugin();

  static Future<void> init(ApiClient apiClient) async {
    await _initLocal();
    await _requestPermission();
    await _uploadToken(apiClient);

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) => _saveToken(apiClient, token),
    );

    // Foreground: show a local notification banner (FCM doesn't auto-show on iOS foreground)
    FirebaseMessaging.onMessage.listen((message) => _showLocal(message));

    // Background tap: app was in background, user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Terminated tap: app was fully closed, user tapped notification
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  static Future<void> _initLocal() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit     = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Create the Android high-importance channel
    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  static Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true,
    );
    DebugLogger.log(_tag, 'permission: ${settings.authorizationStatus}');

    // On iOS, tell FCM to display foreground notifications as alerts too
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> _uploadToken(ApiClient apiClient) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(apiClient, token);
    } catch (e) {
      DebugLogger.error(_tag, 'getToken: $e');
    }
  }

  static Future<void> _saveToken(ApiClient apiClient, String token) async {
    try {
      await apiClient.patch('/auth/fcm-token', data: {'fcmToken': token});
      DebugLogger.log(_tag, 'FCM token uploaded');
    } catch (e) {
      DebugLogger.error(_tag, 'uploadToken: $e');
    }
  }

  static void _showLocal(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true,
        ),
      ),
    );
  }

  static void _handleTap(RemoteMessage message) {
    // Navigation is triggered from main.dart via the notification nav key
    DebugLogger.log(_tag, 'notification tapped: ${message.data}');
    final screen = message.data['screen'];
    if (screen == 'bookings') {
      notificationNavCallback?.call();
    }
  }

  // Set by main.dart so this service can trigger navigation without a context
  static void Function()? notificationNavCallback;
}
