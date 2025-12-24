import 'package:hive_flutter/hive_flutter.dart';

part 'bangkai.g.dart';

/// InventoryNote - Model untuk item inventaris bebas
/// Teknisi bisa menambahkan apa saja dengan judul dan foto opsional
@HiveType(typeId: 20)
class InventoryNote extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  String? imagePath;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime? updatedAt;
  
  InventoryNote({
    required this.id,
    required this.title,
    this.description,
    this.imagePath,
    required this.createdAt,
    this.updatedAt,
  });
  
  InventoryNote copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryNote(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Check if note has image
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  
  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    
    if (diff.inDays == 0) {
      return 'Hari ini';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
