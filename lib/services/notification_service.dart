import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidFlutterLocalNotificationsPlugin? androidLocalNotificationPlugin;

  static const _channelID = 'UPIMG';
  static const _channelName = 'UPLOAD_IMAGE_CHANNEL';
  static const _title = 'Alert';
  static const _description = 'Image Notification';

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

  // download and save image as a file from firebase storage image url
  Future<String> downloadAndSaveImage(String url) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/image.jpg');
    final response = await get(Uri.parse(url));
    await tempFile.writeAsBytes(response.bodyBytes);
    return tempFile.path;
  }

  // show notification function
  Future<void> showNotification(String downloadURL) async {
    try {
      final imageUrl = await downloadAndSaveImage(downloadURL);
      final bigPictureStyleInformation =
          BigPictureStyleInformation(FilePathAndroidBitmap(imageUrl));

      final notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(_channelID, _channelName,
              importance: Importance.max,
              priority: Priority.max,
              styleInformation: bigPictureStyleInformation,
              visibility: NotificationVisibility.public));

      await localNotificationsPlugin.show(
          1, _title, _description, notificationDetails);
    } catch (e) {
      log(e.toString());
    }
  }
}
