import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_management_app/features/ipk/data/models/grade_model.dart';
import 'package:uuid/uuid.dart';

final gradeProvider = StateNotifierProvider<GradeNotifier, List<GradeModel>>((ref) {
  return GradeNotifier();
});

class GradeNotifier extends StateNotifier<List<GradeModel>> {
  GradeNotifier() : super([]) {
    _loadGrades();
  }

  final _uuid = const Uuid();
  late Box<GradeModel> _box;

  Future<void> _loadGrades() async {
    _box = Hive.box<GradeModel>('gradesBox');
    state = _box.values.toList();
  }

  Future<void> addGrade(GradeModel grade) async {
    final newGrade = grade.copyWith(id: _uuid.v4());
    await _box.put(newGrade.id, newGrade);
    state = [...state, newGrade];
  }

  Future<void> updateGrade(GradeModel grade) async {
    await _box.put(grade.id, grade);
    state = [
      for (final g in state)
        if (g.id == grade.id) grade else g
    ];
  }

  Future<void> deleteGrade(String id) async {
    await _box.delete(id);
    state = state.where((g) => g.id != id).toList();
  }

  double getBobot(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return 4.0;
      case 'AB':
        return 3.5;
      case 'B':
        return 3.0;
      case 'BC':
        return 2.5;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      case 'E':
        return 0.0;
      default:
        return 0.0;
    }
  }

  double get currentIpk {
    if (state.isEmpty) return 0.0;
    double totalBobotSks = 0;
    int totalSks = 0;
    for (var grade in state) {
      totalBobotSks += getBobot(grade.grade) * grade.sks;
      totalSks += grade.sks;
    }
    if (totalSks == 0) return 0.0;
    return totalBobotSks / totalSks;
  }

  int get totalSks {
    return state.fold(0, (sum, item) => sum + item.sks);
  }
  
  Map<int, double> get ipkPerSemester {
    Map<int, List<GradeModel>> semesterMap = {};
    for (var grade in state) {
      if (!semesterMap.containsKey(grade.semester)) {
        semesterMap[grade.semester] = [];
      }
      semesterMap[grade.semester]!.add(grade);
    }

    Map<int, double> result = {};
    semesterMap.forEach((semester, grades) {
      double totalBobotSks = 0;
      int totalSks = 0;
      for (var grade in grades) {
        totalBobotSks += getBobot(grade.grade) * grade.sks;
        totalSks += grade.sks;
      }
      result[semester] = totalSks == 0 ? 0.0 : totalBobotSks / totalSks;
    });
    return result;
  }
}
