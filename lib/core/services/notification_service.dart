import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:student_management_app/features/schedule/data/models/schedule_model.dart';
import 'package:student_management_app/features/tasks/data/models/task_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Top level function for notification tap logic if needed
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('Notification tapped background: ${notificationResponse.actionId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Stream controller untuk aksi tap di notifikasi
  static final onNotificationResponse = ValueNotifier<String?>(null);

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Default timezone

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Ketika user tap action button pada notifikasi (misal: Selesai / Sedang Dikerjakan)
        if (response.payload != null) {
          onNotificationResponse.value = '${response.actionId}|${response.payload}';
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  int _generateId(String stringId, {int offset = 0}) {
    return stringId.hashCode.abs() + offset;
  }

  /// Menjadwalkan pengingat jadwal kelas sesuai preferensi user (dalam menit sebelum kelas)
  Future<void> scheduleClassReminder(ScheduleModel schedule, {int minutesBefore = 60}) async {
    final startTimeStr = schedule.waktu.split(' - ').first; // Asumsi "08:00"
    final parts = startTimeStr.split(':');
    if (parts.length < 2) return;

    int hour = int.tryParse(parts[0]) ?? 8;
    int minute = int.tryParse(parts[1]) ?? 0;

    // Mundurkan sesuai preferensi user
    final totalMinutes = hour * 60 + minute - minutesBefore;
    hour = (totalMinutes ~/ 60) % 24;
    if (hour < 0) hour += 24;
    minute = totalMinutes % 60;
    if (minute < 0) minute += 60;

    final dayOfWeek = _getDayOfWeek(schedule.hari);
    var nextInstance = _nextInstanceOfTime(dayOfWeek, hour, minute);

    // Format body notifikasi sesuai waktu pengingat
    String timeLabel;
    if (minutesBefore >= 120) {
      timeLabel = '${minutesBefore ~/ 60} jam';
    } else if (minutesBefore >= 60) {
      timeLabel = '1 jam';
    } else {
      timeLabel = '$minutesBefore menit';
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'class_reminder_channel',
      'Pengingat Kelas',
      channelDescription: 'Notifikasi yang mengingatkan waktu kelas',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: _generateId(schedule.id),
      title: 'Persiapan Kelas: ${schedule.namaMk}',
      body: 'Kelas ${schedule.namaMk} akan dimulai $timeLabel lagi di ruang ${schedule.ruangan}',
      scheduledDate: nextInstance,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelClassReminder(String scheduleId) async {
    await flutterLocalNotificationsPlugin.cancel(id: _generateId(scheduleId));
  }

  /// Menjadwalkan pengingat tugas sesuai preferensi (dalam jam sebelum deadline)
  Future<void> scheduleTaskReminder(TaskModel task) async {
    final now = tz.TZDateTime.now(tz.local);
    final deadline = tz.TZDateTime.from(task.deadline, tz.local);

    // Tambahkan action buttons (Revisi 7)
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminder_channel',
      'Pengingat Tugas',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('action_sedang_dikerjakan', 'Kerjakan', titleColor: Colors.orange),
        const AndroidNotificationAction('action_selesai', 'Selesai', titleColor: Colors.green),
      ],
    );
    final NotificationDetails details = NotificationDetails(android: androidDetails);

    // Pengingat sesuai preferensi (dalam jam sebelum deadline)
    final hX = deadline.subtract(Duration(hours: task.reminderBeforeHours));

    // Format body notifikasi
    final hours = task.reminderBeforeHours;
    String bodyText;
    if (hours >= 24) {
      final days = hours ~/ 24;
      bodyText = 'Tugas "${task.title}" dikumpulkan $days hari lagi.';
    } else {
      bodyText = 'Tugas "${task.title}" dikumpulkan $hours jam lagi.';
    }

    // Jangan jadwalkan jika waktu notifikasi sudah lewat
    if (hX.isAfter(now)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: _generateId(task.id, offset: 1),
        title: 'Pengingat Tugas!',
        body: bodyText,
        scheduledDate: hX,
        notificationDetails: details,
        payload: task.id, // Payload berisi Task ID
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await flutterLocalNotificationsPlugin.cancel(id: _generateId(taskId, offset: 1));
  }

  // Helpers
  int _getDayOfWeek(String hari) {
    switch (hari.toLowerCase()) {
      case 'senin': return DateTime.monday;
      case 'selasa': return DateTime.tuesday;
      case 'rabu': return DateTime.wednesday;
      case 'kamis': return DateTime.thursday;
      case 'jumat': return DateTime.friday;
      case 'sabtu': return DateTime.saturday;
      case 'minggu': return DateTime.sunday;
      default: return DateTime.monday;
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int dayOfWeek, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
