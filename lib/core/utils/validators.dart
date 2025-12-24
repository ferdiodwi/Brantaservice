/// Utility class untuk validasi form
class Validators {
  Validators._();
  
  /// Validasi field tidak boleh kosong
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field ini'} wajib diisi';
    }
    return null;
  }
  
  /// Validasi nomor telepon
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Nomor telepon tidak valid';
    }
    
    if (!cleaned.startsWith('0') && !cleaned.startsWith('62')) {
      return 'Nomor telepon harus diawali 0 atau 62';
    }
    
    return null;
  }
  
  /// Validasi email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }
  
  /// Validasi IMEI (15 digit)
  static String? imei(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length != 15) {
      return 'IMEI harus 15 digit';
    }
    
    return null;
  }
  
  /// Validasi serial number
  static String? serialNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    if (value.length < 5) {
      return 'Serial number terlalu pendek';
    }
    
    return null;
  }
  
  /// Validasi harga/nominal
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga wajib diisi';
    }
    
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.isEmpty) {
      return 'Harga tidak valid';
    }
    
    final amount = int.tryParse(cleaned);
    if (amount == null || amount < 0) {
      return 'Harga tidak valid';
    }
    
    return null;
  }
  
  /// Validasi quantity/stock
  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah wajib diisi';
    }
    
    final amount = int.tryParse(value);
    if (amount == null || amount < 0) {
      return 'Jumlah tidak valid';
    }
    
    return null;
  }
  
  /// Validasi minimal karakter
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field ini'} wajib diisi';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Field ini'} minimal $minLength karakter';
    }
    
    return null;
  }
}
