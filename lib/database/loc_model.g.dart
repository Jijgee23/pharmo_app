// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loc_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocModelAdapter extends TypeAdapter<LocModel> {
  @override
  final int typeId = 0;

  @override
  LocModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocModel(
      lat: fields[0] as double,
      lng: fields[1] as double,
      success: fields[2] as bool,
      data: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng)
      ..writeByte(2)
      ..write(obj.success)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
