import 'package:flutter/material.dart';

/// AppColors - Color palette untuk Brantaservice
/// Berdasarkan desain UI yang diberikan
class AppColors {
  AppColors._();
  
  // Primary Colors
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color primaryDark = Color(0xFF2E6AB3);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF5856D6);
  
  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFCC00);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5AC8FA);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  
  // Status Badge Colors
  static const Color statusCompleted = Color(0xFF34C759);
  static const Color statusInProgress = Color(0xFF4A90E2);
  static const Color statusPending = Color(0xFFFFCC00);
  static const Color statusReady = Color(0xFF5AC8FA);
  static const Color statusDiagnostic = Color(0xFF8B5CF6);
  
  // Card Shadow
  static const Color shadow = Color(0x1A000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
}
