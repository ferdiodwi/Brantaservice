import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'data/models/service.dart';
import 'data/models/customer.dart';
import 'data/models/inventory.dart';
import 'data/models/bangkai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (only on mobile)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  // Set system UI overlay style (only on mobile)
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);
  
  // Register Hive Adapters
  Hive.registerAdapter(ServiceAdapter());
  Hive.registerAdapter(ServiceStatusAdapter());
  Hive.registerAdapter(WarrantyConfigAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(InventoryNoteAdapter());
  
  // Open Hive Boxes
  await Hive.openBox<Service>(AppConstants.serviceBox);
  await Hive.openBox<Customer>(AppConstants.customerBox);
  await Hive.openBox<InventoryItem>(AppConstants.inventoryBox);
  await Hive.openBox<InventoryNote>(AppConstants.bangkaiBox);
  await Hive.openBox(AppConstants.settingsBox);
  
  // Initialize notification service (only on mobile)
  if (!kIsWeb) {
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Initialize background monitoring for overdue services
    await initBackgroundMonitoring();
  }
  
  // Run app with Riverpod
  runApp(
    const ProviderScope(
      child: BrantaserviceApp(),
    ),
  );
}
