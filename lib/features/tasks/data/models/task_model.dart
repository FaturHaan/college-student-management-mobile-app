import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime deadline;

  @HiveField(4)
  String status; // "Belum Dimulai", "Sedang Dikerjakan", "Selesai"

  @HiveField(5)
  String? relatedMk;

  @HiveField(6)
  int reminderBeforeHours;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    this.relatedMk,
    this.reminderBeforeHours = 24,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    String? status,
    String? relatedMk,
    int? reminderBeforeHours,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      relatedMk: relatedMk ?? this.relatedMk,
      reminderBeforeHours: reminderBeforeHours ?? this.reminderBeforeHours,
    );
  }
}
