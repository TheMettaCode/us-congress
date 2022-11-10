import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationApi {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init({bool initScheduled = false}) async {
    const androidSetting =
        AndroidInitializationSettings('@drawable/ic_notification');
    const iOSSetting = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSetting, iOS: iOSSetting);
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      // onDidReNotification: (String payload) async {
      //   // ACTION TO TAKE ON NOTIFICATION SELECTED
      //   logger.d(
      //       '***** Notification Was Selected (notification api): $payload *****');
      //   onNotifications.add(payload);
      // },
    );
  }

  static final onNotifications = BehaviorSubject<String>();

  // static Future<void> showNotification({
  //   int id = 0,
  //   String channelId = 'default',
  //   String channelName = 'Default Channel Name',
  //   String channelDescription = 'No Channel Description',
  //   String title,
  //   String body,
  //   Color color,
  //   Map<String, dynamic> payload,
  // }) async =>
  //     _notifications.show(
  //       id,
  //       title,
  //       body,
  //       await _notificationDetails(channelId, channelName, channelDescription,
  //           body, title, color, payload),
  //       payload: payload.toString(),
  //     );

  // static Future _notificationDetails(
  //     String channelId,
  //     String channelName,
  //     String channelDescription,
  //     String bigText,
  //     String title,
  //     Color color,
  //     Map<String, dynamic> payload) async {
  //   return NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       channelId,
  //       channelName,
  //       channelDescription,
  //       importance: Importance.max,
  //       icon: '@drawable/ic_notification',
  //       largeIcon: DrawableResourceAndroidBitmap('app_icon_round'),
  //       groupKey: channelName,
  //       color: color,
  //       enableLights: true,
  //       ledColor: color,
  //       enableVibration: true,
  //       styleInformation: BigTextStyleInformation(bigText,
  //           contentTitle: title, summaryText: 'by MettaCode'),
  //       priority: Priority.defaultPriority,
  //     ),
  //     iOS: IOSNotificationDetails(),
  //   );
  // }

// DEMONSTRATION BELOW FROM https://medium.com/flutterdevs/local-push-notification-in-flutter-763605b84985

  static showBigTextNotification(
      int id,
      String channelId,
      String channelName,
      String channelDescription,
      String bigTextSummaryTitle,
      String bigTextTitle,
      String bigTextBody,
      dynamic additionalData) async {
    // Box userDatabase = Hive.box<dynamic>(appDatabase);
    // List<dynamic> _notificationsList = userDatabase.get('notificationsList');
    var android = AndroidNotificationDetails(channelId, channelName,
        priority: Priority.high,
        importance: Importance.max,
        enableLights: true,
        icon: '@drawable/ic_notification',
        largeIcon: const DrawableResourceAndroidBitmap('app_icon_round'),
        styleInformation: BigTextStyleInformation(bigTextBody,
            contentTitle: bigTextTitle, summaryText: bigTextSummaryTitle),
        enableVibration: true,
        groupKey: channelId);
    var iOS = const DarwinNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    // _notificationsList.insert(0,
    //     '${DateTime.now().toUtc()}<|:|>$bigTextTitle<|:|>$bigTextBody<|:|>${additionalData.toString()}');
    // if (_notificationsList.length > 20) _notificationsList.removeLast();
    // logger.d(
    //     '***** NOTIFICATIONS LIST (notification_api): ${_notificationsList.length} - $_notificationsList');
    // userDatabase.put('notificationsList', _notificationsList);
    await flutterLocalNotificationsPlugin.show(
        id, bigTextTitle, bigTextBody, platform,
        payload: additionalData.toString());
  }

  static Future<void> showBigPictureNotification() async {
    var bigPictureStyleInformation = const BigPictureStyleInformation(
      DrawableResourceAndroidBitmap("flutter_devs"),
      largeIcon: DrawableResourceAndroidBitmap("flutter_devs"),
      contentTitle: 'flutter devs',
      summaryText: 'summaryText',
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id', 'big text channel name',
        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', platformChannelSpecifics,
        payload: "big image notifications");
  }

  static Future<void> scheduleNotification() async {
    var scheduledNotificationDateTime =
        DateTime.now().add(const Duration(seconds: 5));
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'channel id',
      'channel name',
      icon: 'flutter_devs',
      largeIcon: DrawableResourceAndroidBitmap('@drawable/ic_notification'),
    );
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    // UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation = ;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Schedule Title',
        'Schedule Body',
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: null,
        androidAllowWhileIdle: true);
  }

  static Future<void> showNotificationMediaStyle() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'media channel id',
      'media channel name',
      color: Colors.red,
      enableLights: true,
      largeIcon: DrawableResourceAndroidBitmap("flutter_devs"),
      styleInformation: MediaStyleInformation(),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'notification title', 'notification body', platformChannelSpecifics);
  }

  static Future<void> cancelNotification(int id, String tag) async {
    await flutterLocalNotificationsPlugin.cancel(id, tag: tag);
  }
}
