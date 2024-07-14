import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidFlutterLocalNotificationsPlugin? androidLocalNotificationPlugin;

  Future<void> initialize() async {
    androidLocalNotificationPlugin =
        localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await localNotificationsPlugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')));
  }

  Future<bool> requestPermission() async {
    if (androidLocalNotificationPlugin != null) {
      androidLocalNotificationPlugin?.requestNotificationsPermission() ?? false;
    }
    return false;
  }
}
