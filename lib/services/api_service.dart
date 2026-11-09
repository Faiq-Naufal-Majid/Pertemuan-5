import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../utils/logger.dart';

/// Service untuk komunikasi HTTP dengan REST API.
///
/// Class ini menangani semua request HTTP ke API, termasuk
/// penanganan error dan timeout.
class ApiService {
  final http.Client _client;
  final String _baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.baseUrl;

  /// Mengambil daftar pengguna dari API.
  ///
  /// Mengembalikan [List<User>] jika berhasil.
  /// Melempar [Exception] dengan pesan yang ramah pengguna jika gagal.
  Future<List<User>> getUsers() async {
    try {
      _logRequest('GET', '/users');

      final response = await _client
          .get(
            Uri.parse('$_baseUrl/users'),
            headers: _buildHeaders(),
          )
          .timeout(Duration(seconds: AppConfig.timeoutSeconds));

      _logResponse(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal memuat data. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on FormatException {
      throw Exception('Format data tidak valid.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Mengambil pengguna berdasarkan [id].
  Future<User> getUserById(int id) async {
    try {
      _logRequest('GET', '/users/$id');

      final response = await _client
          .get(
            Uri.parse('$_baseUrl/users/$id'),
            headers: _buildHeaders(),
          )
          .timeout(Duration(seconds: AppConfig.timeoutSeconds));

      _logResponse(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception(
          'Gagal memuat data. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Mengambil daftar postingan (Post) dari API.
  ///
  /// Mengembalikan [List<Post>] jika berhasil.
  /// Melempar [Exception] dengan pesan yang ramah pengguna jika gagal.
  Future<List<Post>> getPosts() async {
    try {
      _logRequest('GET', '/posts');

      final response = await _client
          .get(   
            Uri.parse('$_baseUrl/posts'),
            headers: _buildHeaders(),
          )
          .timeout(Duration(seconds: AppConfig.timeoutSeconds));

      _logResponse(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal memuat data post. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on FormatException {
      throw Exception('Format data tidak valid.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Mengambil postingan berdasarkan [id].
  Future<Post> getPostById(int id) async {
    try {
      _logRequest('GET', '/posts/$id');

      final response = await _client
          .get(
            Uri.parse('$_baseUrl/posts/$id'),
            headers: _buildHeaders(),
          )
          .timeout(Duration(seconds: AppConfig.timeoutSeconds));

      _logResponse(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Post.fromJson(data);
      } else {
        throw Exception(
          'Gagal memuat data post. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Membangun header untuk request HTTP.
  ///
  /// Menyertakan API key dari konfigurasi (tidak di-hardcode).
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-API-Key': AppConfig.apiKey,
    };
  }

  /// Logging request yang aman (tidak mencetak token/API key).
  void _logRequest(String method, String endpoint) {
    Logger.info('HTTP Request: [$method] $endpoint');
  }

  /// Logging response yang aman (hanya status code).
  void _logResponse(int statusCode) {
    Logger.debug('HTTP Response status: $statusCode');
  }

  /// Menutup client.
  void dispose() {
    _client.close();
  }
}

