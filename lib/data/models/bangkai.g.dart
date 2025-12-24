// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangkai.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryNoteAdapter extends TypeAdapter<InventoryNote> {
  @override
  final int typeId = 20;

  @override
  InventoryNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryNote(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      imagePath: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryNote obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
