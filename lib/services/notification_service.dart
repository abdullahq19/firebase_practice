import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth_practice/screens/car/view/add_car_page.dart';
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
  static const _title = 'Image Upload Status';
  static const _description = 'Image Uploaded to Firebase Storage';

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

  Future<void> showNotification(String downloadURL) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/image.jpg');
      final ref = FirebaseStorage.instance.refFromURL(downloadURL);
      await ref.writeToFile(tempFile);

      await localNotificationsPlugin.show(
          1,
          _title,
          _description,
          NotificationDetails(
              android: AndroidNotificationDetails(_channelID, _channelName,
                  styleInformation: BigPictureStyleInformation(
                      FilePathAndroidBitmap(downloadURL)),
                  importance: Importance.max,
                  priority: Priority.max,
                  visibility: NotificationVisibility.public,
                  largeIcon: FilePathAndroidBitmap(tempFile.path))));
    } catch (e) {
      log(e.toString());
    }
  }
}
