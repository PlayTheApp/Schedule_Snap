import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:schedule_snap/style.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import '../Selected_image.dart';
import '../model/task.dart';

class NotifyHeler {
  NotifyHeler._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static initialize() async {
    _configTimezone();
  }

  static check() async {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
  }

  static Future showNotification({required int id, required String title, required String body, var payload, required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'text id',
      'text title',
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    var not = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id, title, body, not);

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"), // 앱 아이콘 이미지 사용
      ),
      onDidReceiveNotificationResponse: (details) {
        print("ㅎㅇ");
      },
    );

    // 0 - 초기화
    // 1 - 일정 생성
  }

  @pragma('vm:entry-point')
  static Future<void> notificationTapBackground(NotificationResponse details) async {
    await Get.to(() => Selected_image());
  }

  //   @pragma('vm:entry-point')
  // static Future<void> notificationTapBackground(NotificationResponse details) async {
  //   FlutterLocalNotificationsPlugin _localNotification = FlutterLocalNotificationsPlugin();
  //   NotificationAppLaunchDetails? detail = await _localNotification.getNotificationAppLaunchDetails();
  //   if (detail != null) {
  //     if (detail.didNotificationLaunchApp) {
  //       if (details.payload != null) {
  //         NotifyHeler.showNotification(id: 0, title: '초기화 완료 !', body: '개의 일정을 모두 삭제 했습니다.', fln: flutterLocalNotificationsPlugin);
  //       }
  //     }
  //   }
  // }

  static Future scheduledNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!.toInt(),
        "${task.Title}",
        (task.Comment == "" && task.URL_Text == "" && task.open_app == "")
            ? "일정이 시작되었습니다."
            : (task.Comment != "" && task.URL_Text == "" && task.open_app == "")
                ? "${task.Comment}"
                : (task.Comment == "" && (task.URL_Text != "" || task.open_app != ""))
                    ? "일정이 시작되었습니다. \n (클릭시 지정된 행동을 수행합니다.)"
                    : "${task.Comment} \n (클릭시 지정된 행동을 수행합니다.)",
        _converTime(hour, minutes),
        // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
          'text id',
          'text title',
          playSound: true,
          importance: Importance.max,
          priority: Priority.high,
        )),
        // androidAllowWhileIdle: true,  // 이건 왜 못쓰는거지?
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: (task.value == 0 && task.URL_Text != "")
            ? task.URL_Text
            : (task.value == 1 && task.open_app != "")
                ? task.open_app
                : null // 앱 / 사이트
        );

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"), // 앱 아이콘 이미지 사용
      ),
      onDidReceiveNotificationResponse: (details) {
        if (task.value == 0 && details.payload != "") {
          Fluttertoast.showToast(
            msg: "사이트를 오픈합니다.",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: MainColor,
            fontSize: 15,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );
          launchUrl(Uri.https(details.payload!), mode: LaunchMode.externalApplication);
        } else if (task.value == 1 && details.payload != "") {
          Fluttertoast.showToast(
            msg: "${task.app_name}을 실행합니다.",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: MainColor, 
            fontSize: 15,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );
          DeviceApps.openApp(details.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

// 스케줄된 알림을 취소하는 함수
  static Future<void> cancelScheduledNotification(int notificationId) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    print("이전 알림 취소");
  }

// 스케줄된 알림을 모두 취소하는 함수
  static Future<void> cancelAllScheduledNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancelAll();
    print("이전 알림 모두 취소");
  }

  static Future<void> _configTimezone() async {
    tz.initializeTimeZones(); // 시간대 데이터베이스 초기화
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  static tz.TZDateTime _converTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }
}
