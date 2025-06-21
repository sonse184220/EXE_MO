import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dependency_injection/injection.dart';

class GlobalFCMHandler extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalFCMHandler({super.key, required this.child});

  @override
  ConsumerState<GlobalFCMHandler> createState() => _GlobalFCMHandlerState();
}

class _GlobalFCMHandlerState extends ConsumerState<GlobalFCMHandler> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    // Request notification permissions (for iOS mainly)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permission');

      // Initialize the FCM token in the provider
      await ref.read(fcmTokenProvider.notifier).initializeToken();

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        ref.read(fcmTokenProvider.notifier).updateToken(newToken);
        print('🔄 FCM Token refreshed: $newToken');
        // TODO: Send updated token to your server
      });

      // Get the FCM device token
      // final fcmToken = await FirebaseMessaging.instance.getToken();
      print('📱 Device FCM Token: ${ref.read(fcmTokenProvider)}');

      // TODO: Send this token to your server to associate it with the user/session

      // Initialize local notifications (Android)
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await flutterLocalNotificationsPlugin.initialize(initSettings);

      // Foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔔 Foreground FCM message received: ${message.notification?.title}');

        final notification = message.notification;
        if (notification != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'channel_id',
                'Channel Name',
                channelDescription: 'Your app notification channel',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
              ),
            ),
          );
        }
      });

      // Handle background & terminated state tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('🟡 User tapped on notification: ${message.notification?.title}');
        // TODO: Navigate or process data
      });

    } else {
      print('❌ Notification permission denied');
    }
  }

  // Future<void> _initFCM() async {
  //   // Request permissions
  //   await FirebaseMessaging.instance.requestPermission();
  //
  //   final fcmToken = await FirebaseMessaging.instance.getToken();
  //   print('📱 Device FCM Token: $fcmToken haha');
  //
  //   // Initialize local notification plugin
  //   const AndroidInitializationSettings androidSettings =
  //   AndroidInitializationSettings('@mipmap/ic_launcher');
  //   const InitializationSettings initSettings =
  //   InitializationSettings(android: androidSettings);
  //
  //   await flutterLocalNotificationsPlugin.initialize(initSettings);
  //
  //   // Handle foreground messages
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('🔔 Foreground FCM message received: ${message.notification?.title}');
  //     final notification = message.notification;
  //     if (notification != null) {
  //       flutterLocalNotificationsPlugin.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         const NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             'channel_id',
  //             'Channel Name',
  //             importance: Importance.max,
  //             priority: Priority.high,
  //           ),
  //         ),
  //       );
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class FCMTokenNotifier extends StateNotifier<String?> {
  FCMTokenNotifier() : super(null);

  Future<void> initializeToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      state = token;
      print('📱 FCM Token stored in provider: $token');
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  void updateToken(String? newToken) {
    state = newToken;
  }
}
