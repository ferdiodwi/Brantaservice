import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/inventory/bangkai_detail_screen.dart';
import '../../screens/inventory/add_bangkai_screen.dart';
import '../../screens/service/quick_entry_screen.dart';
import '../../screens/service/service_details_screen.dart';
import '../../screens/customer/customer_profile_screen.dart';
import '../../screens/stats/weekly_overview_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../constants/app_constants.dart';

/// AppRouter - Navigation configuration menggunakan go_router
class AppRouter {
  AppRouter._();
  
  // Route paths
  static const String splash = '/splash';
  static const String home = '/';
  static const String service = '/service';
  static const String history = '/history';
  static const String inventory = '/inventory';
  static const String settings = '/settings';
  static const String addService = '/service/add';
  static const String serviceDetails = '/service/:id';
  static const String customerProfile = '/customer/:id';
  static const String weeklyOverview = '/stats/weekly';
  static const String notifications = '/notifications';
  static const String bangkaiDetail = '/bangkai/:id';
  static const String addBangkai = '/bangkai/add';
  
  // Settings keys
  static const String keyFirstLaunch = 'first_launch';
  
  // Check if first launch
  static bool get isFirstLaunch {
    final settingsBox = Hive.box(AppConstants.settingsBox);
    return settingsBox.get(keyFirstLaunch, defaultValue: true) as bool;
  }
  
  // Navigator key
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  // Router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isFirstLaunch ? splash : home,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Main Screen with PageView Navigation
      GoRoute(
        path: home,
        builder: (context, state) => const MainScreen(initialIndex: 0),
      ),
      
      // Direct routes for tabs (redirect to MainScreen with index)
      GoRoute(
        path: service,
        builder: (context, state) => const MainScreen(initialIndex: 1),
      ),
      GoRoute(
        path: history,
        builder: (context, state) => const MainScreen(initialIndex: 2),
      ),
      GoRoute(
        path: inventory,
        builder: (context, state) => const MainScreen(initialIndex: 3),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const MainScreen(initialIndex: 4),
      ),
      
      // Add New Service
      GoRoute(
        path: addService,
        builder: (context, state) => const QuickEntryScreen(),
      ),
      
      // Service Details
      GoRoute(
        path: serviceDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ServiceDetailsScreen(serviceId: id);
        },
      ),
      
      // Customer Profile
      GoRoute(
        path: customerProfile,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomerProfileScreen(customerId: id);
        },
      ),
      
      // Weekly Overview Stats
      GoRoute(
        path: weeklyOverview,
        builder: (context, state) => const WeeklyOverviewScreen(),
      ),
      
      // Notifications
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // Add Bangkai
      GoRoute(
        path: addBangkai,
        builder: (context, state) => const AddBangkaiScreen(),
      ),

      // Bangkai Detail
      GoRoute(
        path: bangkaiDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BangkaiDetailScreen(bangkaiId: id);
        },
      ),
    ],
  );
}
