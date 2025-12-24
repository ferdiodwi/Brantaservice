import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/inventory.dart';
import '../core/constants/app_constants.dart';

/// InventoryNotifier - State management untuk Inventory
class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  final Box<InventoryItem> _box;
  
  InventoryNotifier(this._box) : super([]) {
    _loadItems();
  }
  
  void _loadItems() {
    state = _box.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
  
  /// Add new item
  Future<void> addItem(InventoryItem item) async {
    await _box.put(item.id, item);
    _loadItems();
  }
  
  /// Update item
  Future<void> updateItem(InventoryItem item) async {
    item.updatedAt = DateTime.now();
    await _box.put(item.id, item);
    _loadItems();
  }
  
  /// Delete item
  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    _loadItems();
  }
  
  /// Get item by ID
  InventoryItem? getItemById(String id) {
    return _box.get(id);
  }
  
  /// Update stock quantity
  Future<void> updateStock(String id, int newQuantity) async {
    final item = _box.get(id);
    if (item != null) {
      item.quantity = newQuantity;
      item.updatedAt = DateTime.now();
      await item.save();
      _loadItems();
    }
  }
  
  /// Decrease stock (when used in service)
  Future<bool> decreaseStock(String id, int amount) async {
    final item = _box.get(id);
    if (item != null && item.quantity >= amount) {
      item.quantity -= amount;
      item.updatedAt = DateTime.now();
      await item.save();
      _loadItems();
      return true;
    }
    return false;
  }
  
  /// Increase stock (restock)
  Future<void> increaseStock(String id, int amount) async {
    final item = _box.get(id);
    if (item != null) {
      item.quantity += amount;
      item.updatedAt = DateTime.now();
      await item.save();
      _loadItems();
    }
  }
  
  /// Get low stock items
  List<InventoryItem> get lowStockItems {
    return state.where((i) => i.isLowStock).toList();
  }
  
  /// Get out of stock items
  List<InventoryItem> get outOfStockItems {
    return state.where((i) => i.isOutOfStock).toList();
  }
  
  /// Get items by category
  List<InventoryItem> getByCategory(String category) {
    return state.where((i) => i.category == category).toList();
  }
  
  /// Search items
  List<InventoryItem> search(String query) {
    final q = query.toLowerCase();
    return state.where((i) {
      return i.name.toLowerCase().contains(q) ||
          (i.sku?.toLowerCase().contains(q) ?? false) ||
          (i.category?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
  
  /// Get total stock value
  double get totalStockValue {
    return state.fold(0.0, (sum, i) => sum + i.totalBuyValue);
  }
  
  /// Get total potential revenue
  double get totalPotentialRevenue {
    return state.fold(0.0, (sum, i) => sum + i.totalSellValue);
  }
  
  /// Get categories
  List<String> get categories {
    return state
        .where((i) => i.category != null)
        .map((i) => i.category!)
        .toSet()
        .toList();
  }
}

/// Inventory box provider
final inventoryBoxProvider = Provider<Box<InventoryItem>>((ref) {
  return Hive.box<InventoryItem>(AppConstants.inventoryBox);
});

/// Inventory list provider
final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<InventoryItem>>((ref) {
  final box = ref.watch(inventoryBoxProvider);
  return InventoryNotifier(box);
});

/// Single inventory item provider
final singleInventoryProvider = Provider.family<InventoryItem?, String>((ref, id) {
  return ref.watch(inventoryProvider.notifier).getItemById(id);
});

/// Low stock items provider
final lowStockProvider = Provider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryProvider.notifier).lowStockItems;
});

/// Out of stock items provider
final outOfStockProvider = Provider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryProvider.notifier).outOfStockItems;
});
