import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/customer.dart';
import '../core/constants/app_constants.dart';

/// CustomerNotifier - State management untuk Customer
class CustomerNotifier extends StateNotifier<List<Customer>> {
  final Box<Customer> _box;
  
  CustomerNotifier(this._box) : super([]) {
    _loadCustomers();
  }
  
  void _loadCustomers() {
    state = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Add new customer
  Future<void> addCustomer(Customer customer) async {
    await _box.put(customer.id, customer);
    _loadCustomers();
  }
  
  /// Update customer
  Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    await _box.put(customer.id, customer);
    _loadCustomers();
  }
  
  /// Delete customer
  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
    _loadCustomers();
  }
  
  /// Get customer by ID
  Customer? getCustomerById(String id) {
    return _box.get(id);
  }
  
  /// Get customer by phone
  Customer? getByPhone(String phone) {
    try {
      return state.firstWhere((c) => c.phoneNumber == phone);
    } catch (_) {
      return null;
    }
  }
  
  /// Toggle loyal status
  Future<void> toggleLoyalStatus(String id) async {
    final customer = _box.get(id);
    if (customer != null) {
      customer.isLoyal = !customer.isLoyal;
      customer.updatedAt = DateTime.now();
      await customer.save();
      _loadCustomers();
    }
  }
  
  /// Get loyal customers
  List<Customer> get loyalCustomers {
    return state.where((c) => c.isLoyal).toList();
  }
  
  /// Search customers
  List<Customer> search(String query) {
    final q = query.toLowerCase();
    return state.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phoneNumber.contains(q) ||
          (c.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
  
  /// Get total customer count
  int get totalCount => state.length;
}

/// Customer box provider
final customerBoxProvider = Provider<Box<Customer>>((ref) {
  return Hive.box<Customer>(AppConstants.customerBox);
});

/// Customer list provider
final customerProvider = StateNotifierProvider<CustomerNotifier, List<Customer>>((ref) {
  final box = ref.watch(customerBoxProvider);
  return CustomerNotifier(box);
});

/// Single customer provider
final singleCustomerProvider = Provider.family<Customer?, String>((ref, id) {
  return ref.watch(customerProvider.notifier).getCustomerById(id);
});

/// Loyal customers provider
final loyalCustomersProvider = Provider<List<Customer>>((ref) {
  return ref.watch(customerProvider.notifier).loyalCustomers;
});
