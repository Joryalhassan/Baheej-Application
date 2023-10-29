import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationHandler {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  LocalNotificationHandler() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_ID',

      'channel_name',

      // 'channel_description',

      importance: Importance.max,

      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  Future<void> showNotificationWithCustomMessage(
      String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_ID',
      'channel_name',
      // 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }
}
