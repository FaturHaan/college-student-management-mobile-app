import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 0)
class ProfileModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String university;

  @HiveField(2)
  String major;

  @HiveField(3)
  int activeSemester;

  @HiveField(4)
  double targetIpk;

  ProfileModel({
    required this.name,
    required this.university,
    required this.major,
    required this.activeSemester,
    required this.targetIpk,
  });

  ProfileModel copyWith({
    String? name,
    String? university,
    String? major,
    int? activeSemester,
    double? targetIpk,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      university: university ?? this.university,
      major: major ?? this.major,
      activeSemester: activeSemester ?? this.activeSemester,
      targetIpk: targetIpk ?? this.targetIpk,
    );
  }
}
