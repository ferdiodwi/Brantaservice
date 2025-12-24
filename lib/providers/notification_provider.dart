import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/service.dart';
import 'service_provider.dart';

/// Threshold waktu untuk service dianggap overdue
/// Untuk testing: 2 menit, untuk produksi: 24 jam
// const Duration overdueThreshold = Duration(minutes: 2); // Testing: 2 menit
const Duration overdueThreshold = Duration(hours: 2); // Produksi: 24 jam

/// Provider untuk mendapatkan service yang overdue
final overdueServicesProvider = Provider<List<Service>>((ref) {
  final services = ref.watch(serviceProvider);
  final now = DateTime.now();
  
  return services.where((service) {
    // Hanya cek service yang masih aktif (checkIn atau inProgress)
    if (service.status != ServiceStatus.checkIn && 
        service.status != ServiceStatus.inProgress) {
      return false;
    }
    
    // Cek apakah sudah melewati threshold
    final elapsed = now.difference(service.createdAt);
    return elapsed >= overdueThreshold;
  }).toList()
    // Urutkan dari yang paling lama
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
});

/// Provider untuk jumlah service overdue (untuk badge)
final overdueCountProvider = Provider<int>((ref) {
  return ref.watch(overdueServicesProvider).length;
});

/// Helper untuk mendapatkan durasi overdue dalam format readable
String getOverdueDuration(DateTime createdAt) {
  final now = DateTime.now();
  final elapsed = now.difference(createdAt);
  
  if (elapsed.inDays > 0) {
    return '${elapsed.inDays} hari';
  } else if (elapsed.inHours > 0) {
    return '${elapsed.inHours} jam';
  } else {
    return '${elapsed.inMinutes} menit';
  }
}
