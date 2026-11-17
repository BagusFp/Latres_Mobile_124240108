import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Inisialisasi plugin notifikasi
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Inisialisasi zona waktu untuk scheduled notification
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);

    // Minta izin notifikasi untuk Android 13+ (API 33+)
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  /// Menampilkan Immediate Local Notification
  static Future<void> showImmediateNotification({
    int id = 1,
    String title = 'TV Series Reminder',
    String body = 'Episode baru TV Series favoritmu sudah tersedia!',
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'tvmaze_immediate_channel',
      'TVMaze Notifikasi Langsung',
      channelDescription: 'Saluran untuk notifikasi langsung TVMaze',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  /// Menjadwalkan Local Notification (Scheduled)
  static Future<void> scheduleNotification({
    int id = 2,
    String title = 'Pengingat Waktu Nonton',
    String body = 'Jangan lupa nonton series favoritmu sekarang!',
    int delaySeconds = 5,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'tvmaze_scheduled_channel',
      'TVMaze Notifikasi Terjadwal',
      channelDescription: 'Saluran untuk notifikasi terjadwal TVMaze',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTime =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds));

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
