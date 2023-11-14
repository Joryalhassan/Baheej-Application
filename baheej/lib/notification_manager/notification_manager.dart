import 'package:baheej/notification_manager/notification_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> iniNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('flutter_logo');

    DarwinInitializationSettings initializationSettingsIos =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    InitializationSettings initializationSettings =
        InitializationSettings(iOS: initializationSettingsIos);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> simpleNotificationShow() async {
    DarwinNotificationDetails iosNotificationDetails =
        const DarwinNotificationDetails(
      subtitle: 'Channel_description',
      badgeNumber: 1, // Set badge number here
    );

    NotificationDetails notificationDetails =
        NotificationDetails(iOS: iosNotificationDetails);

    await notificationsPlugin.show(
        0, 'simple notifcation', 'New User send message', notificationDetails);
  }
}
