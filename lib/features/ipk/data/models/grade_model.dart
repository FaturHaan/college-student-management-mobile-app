import 'package:hive/hive.dart';

part 'grade_model.g.dart';

@HiveType(typeId: 2)
class GradeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String namaMk;

  @HiveField(2)
  final String? kodeMk;

  @HiveField(3)
  final int sks;

  @HiveField(4)
  final String grade;

  @HiveField(5)
  final int semester;

  GradeModel({
    required this.id,
    required this.namaMk,
    this.kodeMk,
    required this.sks,
    required this.grade,
    required this.semester,
  });

  GradeModel copyWith({
    String? id,
    String? namaMk,
    String? kodeMk,
    int? sks,
    String? grade,
    int? semester,
  }) {
    return GradeModel(
      id: id ?? this.id,
      namaMk: namaMk ?? this.namaMk,
      kodeMk: kodeMk ?? this.kodeMk,
      sks: sks ?? this.sks,
      grade: grade ?? this.grade,
      semester: semester ?? this.semester,
    );
  }
}
