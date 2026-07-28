import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:student_management_app/features/tasks/data/models/task_model.dart';
import 'package:student_management_app/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

const String tasksBoxName = 'tasksBox';

class TaskNotifier extends StateNotifier<List<TaskModel>> {
  TaskNotifier() : super([]) {
    _loadTasks();
  }

  void _loadTasks() {
    final box = Hive.box<TaskModel>(tasksBoxName);
    // Penyortiran Cerdas: Urutkan berdasarkan deadline yang paling dekat dan belum selesai
    final tasks = box.values.toList();
    _sortTasks(tasks);
    state = tasks;
  }

  void _sortTasks(List<TaskModel> tasks) {
    tasks.sort((a, b) {
      if (a.status == 'Selesai' && b.status != 'Selesai') return 1;
      if (a.status != 'Selesai' && b.status == 'Selesai') return -1;
      return a.deadline.compareTo(b.deadline);
    });
  }

  Future<void> addTask(String title, String description, DateTime deadline, String status, int reminderBeforeHours, {String? relatedMk}) async {
    const uuid = Uuid();
    final newTask = TaskModel(
      id: uuid.v4(),
      title: title,
      description: description,
      deadline: deadline,
      status: status, // "Belum Dikerjakan", dsb
      relatedMk: relatedMk,
      reminderBeforeHours: reminderBeforeHours,
    );

    final box = Hive.box<TaskModel>(tasksBoxName);
    await box.put(newTask.id, newTask);
    await NotificationService().scheduleTaskReminder(newTask);
    
    final updatedList = [...state, newTask];
    _sortTasks(updatedList);
    state = updatedList;
  }

  Future<void> updateTaskStatus(String id, String newStatus) async {
    final taskIndex = state.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = state[taskIndex];
      final updatedTask = task.copyWith(status: newStatus);

      final box = Hive.box<TaskModel>(tasksBoxName);
      await box.put(updatedTask.id, updatedTask);

      if (newStatus == 'Selesai') {
        await NotificationService().cancelTaskReminder(id);
      }

      final updatedList = List<TaskModel>.from(state);
      updatedList[taskIndex] = updatedTask;
      _sortTasks(updatedList);
      state = updatedList;
    }
  }

  Future<void> removeTask(String id) async {
    final box = Hive.box<TaskModel>(tasksBoxName);
    await box.delete(id);
    await NotificationService().cancelTaskReminder(id);
    state = state.where((t) => t.id != id).toList();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<TaskModel>>((ref) {
  return TaskNotifier();
});
