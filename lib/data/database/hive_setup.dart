import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_management_app/features/profile/data/models/profile_model.dart';
import 'package:student_management_app/features/profile/providers/profile_provider.dart';
import 'package:student_management_app/features/schedule/data/models/schedule_model.dart';

import 'package:student_management_app/features/tasks/data/models/task_model.dart';
import 'package:student_management_app/features/finance/data/models/transaction_model.dart';
import 'package:student_management_app/features/ipk/data/models/grade_model.dart';

class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register semua adapter
    Hive.registerAdapter(ProfileModelAdapter());
    Hive.registerAdapter(ScheduleModelAdapter());

    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(GradeModelAdapter());

    // Buka semua box yang dibutuhkan
    await Hive.openBox<ProfileModel>(profileBoxName);
    await Hive.openBox<ScheduleModel>('schedulesBox');

    await Hive.openBox<TaskModel>('tasksBox');
    await Hive.openBox<TransactionModel>('transactionsBox');
    await Hive.openBox<GradeModel>('gradesBox');
    await Hive.openBox('settingsBox');
  }
}
