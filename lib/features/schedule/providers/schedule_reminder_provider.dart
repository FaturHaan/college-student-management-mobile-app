import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:student_management_app/core/services/notification_service.dart';
import 'package:student_management_app/features/schedule/data/models/schedule_model.dart';

const String _reminderPrefix = 'reminder_';

/// Mengelola preferensi pengingat jadwal per kelas.
/// Data disimpan di settingsBox dengan key "reminder_{scheduleId}" = minutesBefore (int).
/// Jika key tidak ada, berarti pengingat mati untuk jadwal tersebut.
class ScheduleReminderNotifier extends StateNotifier<Map<String, int>> {
  ScheduleReminderNotifier() : super({}) {
    _loadReminders();
  }

  void _loadReminders() {
    final box = Hive.box('settingsBox');
    final Map<String, int> reminders = {};
    for (var key in box.keys) {
      if (key is String && key.startsWith(_reminderPrefix)) {
        final scheduleId = key.substring(_reminderPrefix.length);
        final value = box.get(key);
        if (value is int) {
          reminders[scheduleId] = value;
        }
      }
    }
    state = reminders;
  }

  /// Cek apakah pengingat aktif untuk jadwal tertentu
  bool isReminderEnabled(String scheduleId) {
    return state.containsKey(scheduleId);
  }

  /// Ambil waktu pengingat (dalam menit) untuk jadwal tertentu
  int getReminderMinutes(String scheduleId) {
    return state[scheduleId] ?? 60; // Default 60 menit jika belum di-set
  }

  /// Aktifkan/perbarui pengingat untuk jadwal tertentu
  Future<void> setReminder(ScheduleModel schedule, int minutesBefore) async {
    final box = Hive.box('settingsBox');
    await box.put('$_reminderPrefix${schedule.id}', minutesBefore);

    // Schedule notifikasi
    await NotificationService().scheduleClassReminder(schedule, minutesBefore: minutesBefore);

    state = {...state, schedule.id: minutesBefore};
  }

  /// Matikan pengingat untuk jadwal tertentu
  Future<void> removeReminder(String scheduleId) async {
    final box = Hive.box('settingsBox');
    await box.delete('$_reminderPrefix$scheduleId');

    // Cancel notifikasi
    await NotificationService().cancelClassReminder(scheduleId);

    final newState = {...state};
    newState.remove(scheduleId);
    state = newState;
  }

  /// Bersihkan semua pengingat (dipanggil saat clear jadwal)
  Future<void> clearAllReminders() async {
    final box = Hive.box('settingsBox');
    for (var key in state.keys) {
      await box.delete('$_reminderPrefix$key');
      await NotificationService().cancelClassReminder(key);
    }
    state = {};
  }
}

final scheduleReminderProvider =
    StateNotifierProvider<ScheduleReminderNotifier, Map<String, int>>((ref) {
  return ScheduleReminderNotifier();
});
