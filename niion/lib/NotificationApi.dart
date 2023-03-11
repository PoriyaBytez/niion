import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationApi {
  static final _ntfcs = FlutterLocalNotificationsPlugin();
  static final onNtfc = BehaviorSubject<NotificationResponse?>();

  static Future _ntfcDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('1', 'Niion Notifications',
            channelDescription: 'Don\'t miss any updates from Niion',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _ntfcs.initialize(settings,
        onDidReceiveNotificationResponse: (payload) async {
      onNtfc.add(payload);
    });
  }

  static Future showNtfc(
          {int id = 0, String? title, String? body, String? payload}) async =>
      _ntfcs.show(id, title, body, await _ntfcDetails(), payload: payload);

  static Future showUniqueNtfc(
          {required int id,
          String? title,
          String? body,
          String? payload}) async =>
      _ntfcs.show(id, title, body, await _ntfcDetails(), payload: payload);

  static Future cancelNtfc({required int id}) async => _ntfcs.cancel(id);
}
