// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = 1;

  @override
  ScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleModel(
      id: fields[0] as String,
      kodeMk: fields[1] as String,
      namaMk: fields[2] as String,
      tePr: fields[3] as String,
      kodeDosen: fields[4] as String,
      namaDosen: fields[5] as String,
      ruangan: fields[6] as String,
      kelas: fields[7] as String,
      hari: fields[8] as String,
      jamKe: fields[9] as String,
      waktu: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kodeMk)
      ..writeByte(2)
      ..write(obj.namaMk)
      ..writeByte(3)
      ..write(obj.tePr)
      ..writeByte(4)
      ..write(obj.kodeDosen)
      ..writeByte(5)
      ..write(obj.namaDosen)
      ..writeByte(6)
      ..write(obj.ruangan)
      ..writeByte(7)
      ..write(obj.kelas)
      ..writeByte(8)
      ..write(obj.hari)
      ..writeByte(9)
      ..write(obj.jamKe)
      ..writeByte(10)
      ..write(obj.waktu);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
