import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk menyimpan dan mengelola data sensitif secara aman.
///
/// Menggunakan [FlutterSecureStorage] untuk mengenkripsi data seperti
/// token autentikasi pada penyimpanan lokal perangkat.
class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Menyimpan [token] ke dalam secure storage.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Mengambil token yang tersimpan di secure storage.
  ///
  /// Mengembalikan `null` jika belum ada token yang disimpan.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Menghapus token dari secure storage.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Menghapus semua data dari secure storage.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

