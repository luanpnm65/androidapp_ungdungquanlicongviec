import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz; // ← THÊM DÒNG NÀY
import 'package:timezone/data/latest.dart' as tzdata; // ← THÊM DÒNG NÀY
import '../models/cong_viec.dart';
import 'cong_viec_controller.dart';

class ThongBaoController extends GetxController {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _khoiTaoThongBao();
  }

  Future<void> _khoiTaoThongBao() async {
    // Khởi tạo timezone
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await notificationsPlugin.initialize(initSettings);
  }

  Future<void> _guiThongBao({
    required int id,
    required String tieude,
    required String noidung,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'quan_ly_cong_viec',
        'Quản lý công việc',
        channelDescription: 'Thông báo deadline công việc',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await notificationsPlugin.show(
        id,
        tieude,
        noidung,
        details,
      );

      print('Đã gửi thông báo: $tieude');
    } catch (e) {
      print('Lỗi gửi thông báo: $e');
    }
  }

  Future<void> guiThongBaoNgayMay({
    required String tieude,
    required String noidung,
    required DateTime thoiGian,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'quan_ly_cong_viec',
        'Quản lý công việc',
        channelDescription: 'Thông báo deadline công việc',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Chuyển DateTime sang TZDateTime
      final tzDateTime = tz.TZDateTime.from(thoiGian, tz.local);

      await notificationsPlugin.zonedSchedule(
        thoiGian.hashCode,
        tieude,
        noidung,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('Đã lên lịch thông báo: $tieude');
    } catch (e) {
      print('Lỗi lên lịch thông báo: $e');
    }
  }
}