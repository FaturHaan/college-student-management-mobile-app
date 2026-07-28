import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 1)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String kodeMk;

  @HiveField(2)
  String namaMk;

  @HiveField(3)
  String tePr;

  @HiveField(4)
  String kodeDosen;

  @HiveField(5)
  String namaDosen;

  @HiveField(6)
  String ruangan;

  @HiveField(7)
  String kelas;

  @HiveField(8)
  String hari;

  @HiveField(9)
  String jamKe;

  @HiveField(10)
  String waktu;

  ScheduleModel({
    required this.id,
    required this.kodeMk,
    required this.namaMk,
    required this.tePr,
    required this.kodeDosen,
    required this.namaDosen,
    required this.ruangan,
    required this.kelas,
    required this.hari,
    required this.jamKe,
    required this.waktu,
  });
}
