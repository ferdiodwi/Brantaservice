import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import '../../data/models/service.dart';
import '../constants/app_constants.dart';

/// Notification Service untuk push notification
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  /// Initialize notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request permission for Android 13+
    await _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to notifications screen
    // This will be handled by the app when it opens
  }
  
  /// Show notification for overdue service
  Future<void> showOverdueNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'overdue_service_channel',
      'Service Tertunda',
      channelDescription: 'Notifikasi untuk service yang tertunda',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, notificationDetails);
  }
  
  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

/// Threshold waktu untuk service dianggap overdue
/// Untuk testing: 2 menit, untuk produksi: 24 jam
const Duration overdueThreshold = Duration(hours: 12); // Produksi: 12 jam

/// Background task name
const String backgroundTaskName = 'checkOverdueServices';

/// Callback untuk workmanager - harus top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Hive untuk background
      await Hive.initFlutter();
      
      // Register adapter jika belum
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ServiceAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ServiceStatusAdapter());
      }
      
      // Open service box
      final serviceBox = await Hive.openBox<Service>(AppConstants.serviceBox);
      
      // Check for overdue services
      final now = DateTime.now();
      final overdueServices = serviceBox.values.where((service) {
        if (service.status != ServiceStatus.checkIn && 
            service.status != ServiceStatus.inProgress) {
          return false;
        }
        final elapsed = now.difference(service.createdAt);
        return elapsed >= overdueThreshold;
      }).toList();
      
      if (overdueServices.isNotEmpty) {
        // Initialize notifications
        final notifications = FlutterLocalNotificationsPlugin();
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const initSettings = InitializationSettings(android: androidSettings);
        await notifications.initialize(initSettings);
        
        // Send notification
        const androidDetails = AndroidNotificationDetails(
          'overdue_service_channel',
          'Service Tertunda',
          channelDescription: 'Notifikasi untuk service yang tertunda',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );
        
        const notificationDetails = NotificationDetails(android: androidDetails);
        
        final count = overdueServices.length;
        await notifications.show(
          0,
          '⚠️ $count Service Tertunda',
          'Ada $count service yang belum selesai lebih dari ${overdueThreshold.inHours} jam',
          notificationDetails,
        );
      }
      
      await serviceBox.close();
      return true;
    } catch (e) {
      return false;
    }
  });
}

/// Initialize background monitoring
Future<void> initBackgroundMonitoring() async {
  // Skip on web platform - Workmanager is not supported
  if (kIsWeb) return;
  
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Set false untuk produksi
  );
  
  // Register periodic task - check every 15 minutes (minimum interval for Android)
  await Workmanager().registerPeriodicTask(
    'overdueServiceCheck',
    backgroundTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );
}

/// Cancel background monitoring
Future<void> cancelBackgroundMonitoring() async {
  // Skip on web platform
  if (kIsWeb) return;
  
  await Workmanager().cancelAll();
}
