/// App constants untuk Brantaservice
class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'Brantaservice';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Manajemen Service HP';
  
  // Hive Box Names
  static const String serviceBox = 'services';
  static const String customerBox = 'customers';
  static const String inventoryBox = 'inventory';
  static const String settingsBox = 'settings';
  static const String bangkaiBox = 'inventory_notes';
  
  // Warranty Duration Options (in days)
  static const List<int> warrantyDurations = [7, 14, 30, 60, 90];
  
  // Device Brands
  static const List<String> deviceBrands = [
    'Apple',
    'Samsung',
    'Xiaomi',
    'Oppo',
    'Vivo',
    'Realme',
    'Huawei',
    'Google',
    'OnePlus',
    'Asus',
    'Sony',
    'LG',
    'Nokia',
    'Motorola',
    'Infinix',
    'Tecno',
    'Lainnya',
  ];
  
  // Repair Categories
  static const List<String> repairCategories = [
    'Screen',
    'Battery',
    'Port',
    'Software',
    'Camera',
    'Speaker',
    'Microphone',
    'Button',
    'Water Damage',
    'Motherboard',
    'Lainnya',
  ];
  
  // Service Status
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusReady = 'ready';
  static const String statusDiagnostic = 'diagnostic';
  static const String statusCheckIn = 'check_in';
  
  // Date Formats
  static const String dateFormatShort = 'dd MMM yyyy';
  static const String dateFormatLong = 'dd MMMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Currency
  static const String currencySymbol = 'Rp';
  static const String currencyLocale = 'id_ID';
  
  // Common Component Names for Bangkai
  static const List<String> componentNames = [
    'IC Power',
    'IC Charging',
    'IC Audio',
    'IC WTR (Sinyal)',
    'IC EMMC',
    'IC CPU',
    'IC WiFi/BT',
    'IC Display',
    'IC Touch',
    'Konektor LCD',
    'Konektor Charger',
    'Konektor Battery',
    'Konektor FPC',
    'Kamera Depan',
    'Kamera Belakang',
    'Speaker',
    'Buzzer',
    'Microphone',
    'Motor Getar',
    'Antena Sinyal',
    'Battery',
    'Mesin Utuh',
    'Lainnya',
  ];
  
  // Storage Locations
  static const List<String> storageLocations = [
    'Box 1',
    'Box 2',
    'Box 3',
    'Box 4',
    'Box 5',
    'Rak A',
    'Rak B',
    'Rak C',
    'Laci 1',
    'Laci 2',
    'Lainnya',
  ];
}
