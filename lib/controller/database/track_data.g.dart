// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackDataAdapter extends TypeAdapter<TrackData> {
  @override
  final int typeId = 1;

  @override
  TrackData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackData(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      date: fields[3] as DateTime,
      id: fields[2] as int?,
      sended: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TrackData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.sended);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
