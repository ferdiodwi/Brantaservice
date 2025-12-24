// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WarrantyConfigAdapter extends TypeAdapter<WarrantyConfig> {
  @override
  final int typeId = 11;

  @override
  WarrantyConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WarrantyConfig(
      isEnabled: fields[0] as bool,
      warrantyType: fields[1] as String,
      durationDays: fields[2] as int,
      internalNotes: fields[3] as String?,
      startDate: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WarrantyConfig obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.warrantyType)
      ..writeByte(2)
      ..write(obj.durationDays)
      ..writeByte(3)
      ..write(obj.internalNotes)
      ..writeByte(4)
      ..write(obj.startDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarrantyConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServiceAdapter extends TypeAdapter<Service> {
  @override
  final int typeId = 0;

  @override
  Service read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Service(
      id: fields[0] as String,
      customerId: fields[1] as String,
      customerName: fields[2] as String,
      customerPhone: fields[3] as String,
      deviceBrand: fields[4] as String,
      deviceModel: fields[5] as String,
      deviceColor: fields[6] as String?,
      serialNumber: fields[7] as String?,
      imei: fields[8] as String?,
      problemDescription: fields[9] as String,
      repairAction: fields[10] as String?,
      estimatedCost: fields[11] as double,
      finalCost: fields[12] as double?,
      status: fields[13] as ServiceStatus,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime?,
      completedAt: fields[16] as DateTime?,
      beforePhotoPath: fields[17] as String?,
      afterPhotoPath: fields[18] as String?,
      warranty: fields[19] as WarrantyConfig?,
      notes: fields[20] as String?,
      usedParts: (fields[21] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Service obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.customerPhone)
      ..writeByte(4)
      ..write(obj.deviceBrand)
      ..writeByte(5)
      ..write(obj.deviceModel)
      ..writeByte(6)
      ..write(obj.deviceColor)
      ..writeByte(7)
      ..write(obj.serialNumber)
      ..writeByte(8)
      ..write(obj.imei)
      ..writeByte(9)
      ..write(obj.problemDescription)
      ..writeByte(10)
      ..write(obj.repairAction)
      ..writeByte(11)
      ..write(obj.estimatedCost)
      ..writeByte(12)
      ..write(obj.finalCost)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.completedAt)
      ..writeByte(17)
      ..write(obj.beforePhotoPath)
      ..writeByte(18)
      ..write(obj.afterPhotoPath)
      ..writeByte(19)
      ..write(obj.warranty)
      ..writeByte(20)
      ..write(obj.notes)
      ..writeByte(21)
      ..write(obj.usedParts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServiceStatusAdapter extends TypeAdapter<ServiceStatus> {
  @override
  final int typeId = 10;

  @override
  ServiceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ServiceStatus.checkIn;
      case 1:
        return ServiceStatus.inProgress;
      case 2:
        return ServiceStatus.completed;
      case 3:
        return ServiceStatus.cancelled;
      default:
        return ServiceStatus.checkIn;
    }
  }

  @override
  void write(BinaryWriter writer, ServiceStatus obj) {
    switch (obj) {
      case ServiceStatus.checkIn:
        writer.writeByte(0);
        break;
      case ServiceStatus.inProgress:
        writer.writeByte(1);
        break;
      case ServiceStatus.completed:
        writer.writeByte(2);
        break;
      case ServiceStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
