import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';

/// Utility class untuk formatting
class Formatters {
  Formatters._();
  
  // Currency Formatter
  static final _currencyFormatter = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );
  
  // Number formatter for input fields (thousand separator)
  static final _thousandFormatter = NumberFormat('#,###', 'id_ID');
  
  /// Format number ke Rupiah
  /// Example: 150000 -> Rp 150.000
  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }
  
  /// Format number ke Rupiah (dari int)
  static String formatCurrencyInt(int amount) {
    return _currencyFormatter.format(amount);
  }
  
  /// Format number with thousand separator (for input display)
  /// Example: 150000 -> 150.000
  static String formatNumber(int number) {
    return _thousandFormatter.format(number);
  }
  
  /// Parse formatted number string back to int
  /// Example: "150.000" -> 150000
  static int parseFormattedNumber(String formatted) {
    return int.tryParse(formatted.replaceAll('.', '')) ?? 0;
  }
  
  /// Format currency short (compact)
  /// Example: 1500000 -> Rp 1.5M
  static String formatCurrencyShort(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return formatCurrency(amount);
  }
  
  /// Format date ke string pendek
  /// Example: 2024-01-15 -> 15 Jan 2024
  static String formatDateShort(DateTime date) {
    return DateFormat(AppConstants.dateFormatShort, 'id_ID').format(date);
  }
  
  /// Format date ke string panjang
  /// Example: 2024-01-15 -> 15 Januari 2024
  static String formatDateLong(DateTime date) {
    return DateFormat(AppConstants.dateFormatLong, 'id_ID').format(date);
  }
  
  /// Format datetime ke string
  /// Example: 2024-01-15 10:30 -> 15 Jan 2024, 10:30
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat, 'id_ID').format(dateTime);
  }
  
  /// Format time only
  /// Example: 2024-01-15 10:30 -> 10:30
  static String formatTime(DateTime dateTime) {
    return DateFormat(AppConstants.timeFormat).format(dateTime);
  }
  
  /// Format relative time (time ago) with localization
  /// Example: 5 menit lalu, 2 jam lalu, Kemarin, dll
  static String formatRelativeTime(DateTime dateTime, {AppLocalizations? l10n}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (l10n != null) {
      if (difference.inMinutes < 1) {
        return l10n.translate('common_just_now');
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${l10n.translate('common_minutes_ago')}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${l10n.translate('common_hours_ago')}';
      } else if (difference.inDays == 1) {
        return l10n.translate('common_yesterday');
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${l10n.translate('common_days_ago')}';
      } else {
        return formatDateShort(dateTime);
      }
    }
    
    // Fallback if l10n is not provided
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return formatDateShort(dateTime);
    }
  }
  
  /// Format phone number
  /// Example: 081234567890 -> 0812-3456-7890
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 10) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    }
    return phone;
  }
  
  /// Format IMEI
  /// Example: 123456789012345 -> 12-345678-901234-5
  static String formatImei(String imei) {
    final cleaned = imei.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 15) {
      return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 8)}-${cleaned.substring(8, 14)}-${cleaned.substring(14)}';
    }
    return imei;
  }
  
  /// Generate receipt/struk text for WhatsApp
  /// Returns a formatted text suitable for sending via WhatsApp
  static String generateReceipt({
    required String shopName,
    required String customerName,
    required String customerPhone,
    required String deviceBrand,
    required String deviceModel,
    required String problem,
    required double estimatedCost,
    double? finalCost,
    required DateTime createdAt,
    DateTime? completedAt,
    String? notes,
    int? warrantyDays, // Optional warranty in days
    String? orderId, // Optional order ID
  }) {
    final cost = finalCost ?? estimatedCost;
    final dateFormatLong = DateFormat('dd MMMM yyyy', 'id_ID');
    final dateFormatShort = DateFormat('dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    
    // Use provided order ID or generate default
    final orderNumber = orderId ?? 'BS-${DateFormat('yyMMdd').format(createdAt)}-001';
    
    final buffer = StringBuffer();
    
    buffer.writeln('════════════════════════════');
    buffer.writeln('        $shopName');
    buffer.writeln('      Service & Repair HP');
    buffer.writeln('════════════════════════════');
    buffer.writeln('No. Order : $orderNumber');
    buffer.writeln('Tanggal   : ${dateFormatLong.format(createdAt)}');
    buffer.writeln('================================');
    buffer.writeln('');
    buffer.writeln('DATA PELANGGAN');
    buffer.writeln('Nama      : $customerName');
    buffer.writeln('No. HP    : ${_formatPhoneDisplay(customerPhone)}');
    buffer.writeln('');
    buffer.writeln('DATA PERANGKAT');
    buffer.writeln('Perangkat : $deviceBrand $deviceModel');
    buffer.writeln('');
    buffer.writeln('DETAIL SERVIS');
    buffer.writeln('Keluhan   :');
    // Split problem by comma and display each on new line
    final problems = problem.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);
    for (final p in problems) {
      buffer.writeln('- $p');
    }
    buffer.writeln('');
    buffer.writeln('Biaya Servis: ${_currencyFormatter.format(cost)}');
    buffer.writeln('--------------------------------');
    buffer.writeln('Masuk     : ${dateFormatShort.format(createdAt)}');
    if (completedAt != null) {
      buffer.writeln('Selesai   : ${dateFormatShort.format(completedAt)} | ${timeFormat.format(completedAt)}');
    }
    buffer.writeln('================================');
    // Only show warranty if provided
    if (warrantyDays != null && warrantyDays > 0) {
      buffer.writeln('Garansi Servis : $warrantyDays Hari');
      buffer.writeln('');
    }
    buffer.writeln('Terima kasih atas kepercayaan Anda');
    buffer.writeln('$shopName 🙏');
    
    return buffer.toString();
  }
  
  /// Format phone for display (0812-3456-7890)
  static String _formatPhoneDisplay(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 10) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    }
    return phone;
  }
  
  /// Format phone number for WhatsApp (remove leading 0, add 62)
  /// Example: 081234567890 -> 6281234567890
  static String formatPhoneForWhatsApp(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('62')) {
      cleaned = '62$cleaned';
    }
    return cleaned;
  }
}

/// TextInputFormatter untuk input angka dengan pemisah ribuan (titik)
/// Example: 5000 -> 5.000, 1500000 -> 1.500.000
class ThousandSeparatorInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat('#,###', 'id_ID');
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    
    // Parse and format
    final number = int.tryParse(digitsOnly) ?? 0;
    final formatted = _formatter.format(number);
    
    // Calculate cursor position
    final cursorOffset = formatted.length;
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
