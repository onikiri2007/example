import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';
import 'package:push_notification/push_notification.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/services/services.dart';

const String channelId = "yodel";
const String channelName = "Notifications";
const String channelDesc = "notifications for shifts";

class NotificationData {
  final int id;
  final bool isMyShift;
  final int notificationId;

  NotificationData({
    @required this.id,
    this.isMyShift = false,
    this.notificationId,
  });
}

abstract class PushNotificationService {
  Stream<NotificationData> get onMessageReceived;
  Stream<String> get onTokenRefresh;
  Future<String> getToken();
  Future<ServiceResult> requestNotificationPermission();
  void dispose();
}

class PushNotificationServiceImpl
    with ServiceMixin
    implements PushNotificationService {
  final PushNotification _notification;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final PublishSubject<NotificationData> _notificationSubject =
      PublishSubject();

  PushNotificationServiceImpl({
    PushNotification pushNotification,
  }) : this._notification = pushNotification ?? PushNotification();

  @override
  Future<String> getToken() async => await _notification.getToken();

  @override
  Stream<NotificationData> get onMessageReceived => _notificationSubject.stream;

  @override
  Stream<String> get onTokenRefresh => _notification.onTokenRefresh;

  @override
  Future<ServiceResult> requestNotificationPermission() async {
    try {
      final success = await _notification.requestNotificationPermissions();
      if (success) {
        _notification.configure(
          onLaunch: (map) async {
            print("onLaunch: $map");
            _notificationSubject.add(_parseNotificationMessage(map));
          },
          onMessage: (map) async {
            print("onMessage: $map");

            _showLocalNotification(map);
          },
          onOpen: (map) async {
            print("onOpen: $map");
            _notificationSubject.add(_parseNotificationMessage(map));
          },
          onResume: (map) async {
            print("onResume: $map");
            if (Platform.isAndroid) {
              _notificationSubject.add(_parseNotificationMessage(map));
            }
          },
        );
        return ServiceResult.successWithNoData();
      }
    } on PlatformException catch (ex) {
      return ServiceResult.failure(errorMessage: ex.message);
    }

    return ServiceResult.failure();
  }

  NotificationData _parseNotificationMessage(Map<String, dynamic> map) {
    final outerData = map["data"];

    if (Platform.isIOS) {
      final innerData = outerData["data"] ?? outerData;
      return NotificationData(
        id: innerData["shiftId"],
        isMyShift: innerData["isWorkerNotification"] ?? false,
        notificationId: innerData["notificationId"],
      );
    } else {
      final String idString =
          outerData != null ? outerData["shiftId"] : map["shiftId"];

      final bool isMyShift = outerData != null
          ? outerData["isWorkerNotification"]
          : map["isWorkerNotification"];

      final String notificationIdString = outerData != null
          ? outerData["notificationId"]
          : map["notificationId"];

      final id = int.tryParse(idString);

      final notificationid = int.tryParse(notificationIdString);

      return NotificationData(
        id: id,
        isMyShift: isMyShift ?? false,
        notificationId: notificationid,
      );
    }
  }

  Future _showLocalNotification(Map<String, dynamic> map) async {
    if (Platform.isAndroid) {
      var initializationSettingsAndroid =
          new AndroidInitializationSettings('app_icon');
      var initializationSettingsIOS = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _onSelectNotification);
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          channelId, channelName, channelDesc,
          importance: Importance.Max,
          priority: Priority.High,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      var notification = map["notification"];
      var payload = map["data"];
      await _flutterLocalNotificationsPlugin.show(0, notification["title"],
          notification["body"], platformChannelSpecifics,
          payload: json.encode(payload));
    }
  }

  @override
  void dispose() {
    _notificationSubject.close();
  }

  Future _onSelectNotification(String payload) async {
    if (payload != null && payload.isNotEmpty) {
      final map = json.decode(payload);
      _notificationSubject.add(_parseNotificationMessage(map));
    }
  }
}
