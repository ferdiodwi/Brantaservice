import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/service.dart';
import '../core/constants/app_constants.dart';

/// ServiceNotifier - State management untuk Service
class ServiceNotifier extends StateNotifier<List<Service>> {
  final Box<Service> _box;
  
  ServiceNotifier(this._box) : super([]) {
    _loadServices();
  }
  
  void _loadServices() {
    // Create a new list to ensure state change is detected
    final services = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = List<Service>.from(services);
  }
  
  /// Add new service with auto-generated order number
  Future<void> addService(Service service) async {
    // Generate daily order number
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    // Count services created today to get next order number
    final todayServices = _box.values.where((s) => 
      s.createdAt.isAfter(todayStart.subtract(const Duration(seconds: 1))) && 
      s.createdAt.isBefore(todayEnd)
    ).toList();
    
    final nextOrderNumber = todayServices.length + 1;
    
    // Create service with order number
    final serviceWithOrder = service.copyWith(orderNumber: nextOrderNumber);
    
    await _box.put(serviceWithOrder.id, serviceWithOrder);
    _loadServices();
  }
  
  /// Update service
  Future<void> updateService(Service service) async {
    service.updatedAt = DateTime.now();
    await _box.put(service.id, service);
    _loadServices();
  }
  
  /// Delete service
  Future<void> deleteService(String id) async {
    await _box.delete(id);
    _loadServices();
  }
  
  /// Get service by ID
  Service? getServiceById(String id) {
    return _box.get(id);
  }
  
  /// Update service status
  Future<void> updateStatus(String id, ServiceStatus status) async {
    final service = _box.get(id);
    if (service != null) {
      // Create updated service with new status
      final updatedService = service.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        completedAt: status == ServiceStatus.completed ? DateTime.now() : service.completedAt,
      );
      await _box.put(id, updatedService);
      _loadServices();
    }
  }
  
  /// Get services by status
  List<Service> getByStatus(ServiceStatus status) {
    return state.where((s) => s.status == status).toList();
  }
  
  /// Get services by customer
  List<Service> getByCustomer(String customerId) {
    return state.where((s) => s.customerId == customerId).toList();
  }
  
  /// Get today's services
  List<Service> get todayServices {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.where((s) {
      final serviceDate = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
      return serviceDate == today;
    }).toList();
  }
  
  /// Get check-in services count
  int get checkInCount => state.where((s) => s.status == ServiceStatus.checkIn).length;
  
  /// Get in progress count
  int get inProgressCount => state.where((s) => s.status == ServiceStatus.inProgress).length;
  
  /// Get total revenue (completed services)
  double get totalRevenue {
    return state
        .where((s) => s.status == ServiceStatus.completed)
        .fold(0.0, (sum, s) => sum + (s.finalCost ?? s.estimatedCost));
  }
  
  /// Search services
  List<Service> search(String query) {
    final q = query.toLowerCase();
    return state.where((s) {
      return s.customerName.toLowerCase().contains(q) ||
          s.customerPhone.contains(q) ||
          s.deviceBrand.toLowerCase().contains(q) ||
          s.deviceModel.toLowerCase().contains(q) ||
          (s.imei?.contains(q) ?? false);
    }).toList();
  }
}

/// Service box provider
final serviceBoxProvider = Provider<Box<Service>>((ref) {
  return Hive.box<Service>(AppConstants.serviceBox);
});

/// Service list provider
final serviceProvider = StateNotifierProvider<ServiceNotifier, List<Service>>((ref) {
  final box = ref.watch(serviceBoxProvider);
  return ServiceNotifier(box);
});

/// Single service provider
final singleServiceProvider = Provider.family<Service?, String>((ref, id) {
  final services = ref.watch(serviceProvider);
  return services.where((s) => s.id == id).firstOrNull;
});

/// Today's services provider
final todayServicesProvider = Provider<List<Service>>((ref) {
  final services = ref.watch(serviceProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return services.where((s) {
    final serviceDate = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
    return serviceDate == today;
  }).toList();
});

/// Active services count provider (checkIn + inProgress)
final activeCountProvider = Provider<int>((ref) {
  final services = ref.watch(serviceProvider);
  return services.where((s) => 
    s.status == ServiceStatus.checkIn || 
    s.status == ServiceStatus.inProgress
  ).length;
});
