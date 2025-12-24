import 'package:hive/hive.dart';

part 'customer.g.dart';

/// Customer - Model untuk data pelanggan
@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String phoneNumber;
  
  @HiveField(3)
  String? email;
  
  @HiveField(4)
  String? address;
  
  @HiveField(5)
  bool isLoyal;
  
  @HiveField(6)
  DateTime createdAt;
  
  @HiveField(7)
  DateTime? updatedAt;
  
  @HiveField(8)
  String? notes;
  
  @HiveField(9)
  String? avatarPath;
  
  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    this.isLoyal = false,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.avatarPath,
  });
  
  /// Get display name (first name only)
  String get firstName {
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }
  
  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty 
        ? parts[0][0].toUpperCase() 
        : '?';
  }
  
  /// Check if has email
  bool get hasEmail => email != null && email!.isNotEmpty;
  
  /// Check if has address
  bool get hasAddress => address != null && address!.isNotEmpty;
  
  Customer copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    bool? isLoyal,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? avatarPath,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      isLoyal: isLoyal ?? this.isLoyal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
