import 'package:hive/hive.dart';

part 'service.g.dart';

/// ServiceStatus - Enum untuk status service
@HiveType(typeId: 10)
enum ServiceStatus {
  @HiveField(0)
  checkIn,      // Masuk
  
  @HiveField(1)
  inProgress,   // Diproses
  
  @HiveField(2)
  completed,    // Selesai
  
  @HiveField(3)
  cancelled,    // Batal
}

/// WarrantyConfig - Konfigurasi garansi
@HiveType(typeId: 11)
class WarrantyConfig extends HiveObject {
  @HiveField(0)
  bool isEnabled;
  
  @HiveField(1)
  String warrantyType; // 'store', 'manufacturer'
  
  @HiveField(2)
  int durationDays;
  
  @HiveField(3)
  String? internalNotes;
  
  @HiveField(4)
  DateTime? startDate;
  
  WarrantyConfig({
    this.isEnabled = false,
    this.warrantyType = 'store',
    this.durationDays = 7,
    this.internalNotes,
    this.startDate,
  });
  
  /// Get warranty end date
  DateTime? get endDate {
    if (startDate == null) return null;
    return startDate!.add(Duration(days: durationDays));
  }
  
  /// Check if warranty is still active
  bool get isActive {
    if (!isEnabled || startDate == null) return false;
    final end = endDate;
    if (end == null) return false;
    return DateTime.now().isBefore(end);
  }
  
  /// Get remaining days
  int get remainingDays {
    if (!isActive) return 0;
    final end = endDate;
    if (end == null) return 0;
    return end.difference(DateTime.now()).inDays;
  }
  
  WarrantyConfig copyWith({
    bool? isEnabled,
    String? warrantyType,
    int? durationDays,
    String? internalNotes,
    DateTime? startDate,
  }) {
    return WarrantyConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      warrantyType: warrantyType ?? this.warrantyType,
      durationDays: durationDays ?? this.durationDays,
      internalNotes: internalNotes ?? this.internalNotes,
      startDate: startDate ?? this.startDate,
    );
  }
}

/// Service - Model untuk data service/perbaikan
@HiveType(typeId: 0)
class Service extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String customerId;
  
  @HiveField(2)
  String customerName;
  
  @HiveField(3)
  String customerPhone;
  
  @HiveField(4)
  String deviceBrand;
  
  @HiveField(5)
  String deviceModel;
  
  @HiveField(6)
  String? deviceColor;
  
  @HiveField(7)
  String? serialNumber;
  
  @HiveField(8)
  String? imei;
  
  @HiveField(9)
  String problemDescription;
  
  @HiveField(10)
  String? repairAction;
  
  @HiveField(11)
  double estimatedCost;
  
  @HiveField(12)
  double? finalCost;
  
  @HiveField(13)
  ServiceStatus status;
  
  @HiveField(14)
  DateTime createdAt;
  
  @HiveField(15)
  DateTime? updatedAt;
  
  @HiveField(16)
  DateTime? completedAt;
  
  @HiveField(17)
  String? beforePhotoPath;
  
  @HiveField(18)
  String? afterPhotoPath;
  
  @HiveField(19)
  WarrantyConfig? warranty;
  
  @HiveField(20)
  String? notes;
  
  @HiveField(21)
  List<String>? usedParts; // List of inventory item IDs
  
  @HiveField(22)
  int? orderNumber; // Daily order number (001, 002, etc)
  
  Service({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deviceBrand,
    required this.deviceModel,
    this.deviceColor,
    this.serialNumber,
    this.imei,
    required this.problemDescription,
    this.repairAction,
    required this.estimatedCost,
    this.finalCost,
    this.status = ServiceStatus.checkIn,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.beforePhotoPath,
    this.afterPhotoPath,
    this.warranty,
    this.notes,
    this.usedParts,
    this.orderNumber,
  });
  
  /// Get status display text
  String get statusText {
    switch (status) {
      case ServiceStatus.checkIn:
        return 'Masuk';
      case ServiceStatus.inProgress:
        return 'Diproses';
      case ServiceStatus.completed:
        return 'Selesai';
      case ServiceStatus.cancelled:
        return 'Batal';
    }
  }
  
  /// Get full device name
  String get deviceFullName => '$deviceBrand $deviceModel';
  
  /// Check if service has before photo
  bool get hasBeforePhoto => beforePhotoPath != null && beforePhotoPath!.isNotEmpty;
  
  /// Check if service has after photo
  bool get hasAfterPhoto => afterPhotoPath != null && afterPhotoPath!.isNotEmpty;
  
  Service copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deviceBrand,
    String? deviceModel,
    String? deviceColor,
    String? serialNumber,
    String? imei,
    String? problemDescription,
    String? repairAction,
    double? estimatedCost,
    double? finalCost,
    ServiceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? beforePhotoPath,
    String? afterPhotoPath,
    WarrantyConfig? warranty,
    String? notes,
    List<String>? usedParts,
    int? orderNumber,
  }) {
    return Service(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceColor: deviceColor ?? this.deviceColor,
      serialNumber: serialNumber ?? this.serialNumber,
      imei: imei ?? this.imei,
      problemDescription: problemDescription ?? this.problemDescription,
      repairAction: repairAction ?? this.repairAction,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      finalCost: finalCost ?? this.finalCost,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      beforePhotoPath: beforePhotoPath ?? this.beforePhotoPath,
      afterPhotoPath: afterPhotoPath ?? this.afterPhotoPath,
      warranty: warranty ?? this.warranty,
      notes: notes ?? this.notes,
      usedParts: usedParts ?? this.usedParts,
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }
}
