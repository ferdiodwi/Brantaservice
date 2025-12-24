import 'package:hive/hive.dart';

part 'inventory.g.dart';

/// InventoryItem - Model untuk data sparepart/inventory
@HiveType(typeId: 2)
class InventoryItem extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String? sku;
  
  @HiveField(3)
  String? category;
  
  @HiveField(4)
  int quantity;
  
  @HiveField(5)
  double buyPrice;
  
  @HiveField(6)
  double sellPrice;
  
  @HiveField(7)
  int minStock;
  
  @HiveField(8)
  String? description;
  
  @HiveField(9)
  String? imagePath;
  
  @HiveField(10)
  DateTime createdAt;
  
  @HiveField(11)
  DateTime? updatedAt;
  
  @HiveField(12)
  String? supplier;
  
  @HiveField(13)
  String? location; // Storage location
  
  InventoryItem({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    required this.quantity,
    required this.buyPrice,
    required this.sellPrice,
    this.minStock = 5,
    this.description,
    this.imagePath,
    required this.createdAt,
    this.updatedAt,
    this.supplier,
    this.location,
  });
  
  /// Check if stock is low
  bool get isLowStock => quantity <= minStock;
  
  /// Check if out of stock
  bool get isOutOfStock => quantity <= 0;
  
  /// Calculate profit margin
  double get profitMargin {
    if (buyPrice <= 0) return 0;
    return ((sellPrice - buyPrice) / buyPrice) * 100;
  }
  
  /// Calculate profit per item
  double get profitPerItem => sellPrice - buyPrice;
  
  /// Get total stock value (buy price)
  double get totalBuyValue => quantity * buyPrice;
  
  /// Get total stock value (sell price)
  double get totalSellValue => quantity * sellPrice;
  
  /// Get stock status text
  String get stockStatusText {
    if (isOutOfStock) return 'Habis';
    if (isLowStock) return 'Stok Rendah';
    return 'Tersedia';
  }
  
  InventoryItem copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    int? quantity,
    double? buyPrice,
    double? sellPrice,
    int? minStock,
    String? description,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? supplier,
    String? location,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      minStock: minStock ?? this.minStock,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supplier: supplier ?? this.supplier,
      location: location ?? this.location,
    );
  }
}
