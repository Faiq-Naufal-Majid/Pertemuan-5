import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/secure_storage_service.dart';
import '../utils/validators.dart';
import 'post_list_screen.dart';
import 'user_list_screen.dart';

/// Halaman utama aplikasi RPL & Keamanan.
///
/// Menampilkan status konfigurasi `.env`, fitur validasi & sanitasi input,
/// penyimpanan token aman ([SecureStorageService]), dan navigasi ke
/// halaman daftar pengguna ([UserListScreen]).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _urlController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  final _storageService = SecureStorageService();

  String? _sanitizedResult;
  String? _savedToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _storageService.getToken();
    if (mounted) {
      setState(() {
        _savedToken = token;
      });
    }
  }

  Future<void> _saveToken() async {
    final error = Validators.validateText(
      _tokenController.text,
      fieldName: 'Token',
      minLength: 5,
      maxLength: 100,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    final cleanToken = Validators.sanitize(_tokenController.text);
    await _storageService.saveToken(cleanToken);
    _tokenController.clear();
    await _loadToken();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token berhasil disimpan dengan aman')),
      );
    }
  }

  Future<void> _deleteToken() async {
    await _storageService.deleteToken();
    await _loadToken();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token berhasil dihapus')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final sanitizedName = Validators.sanitize(_nameController.text);
      final sanitizedEmail = Validators.sanitize(_emailController.text);
      final sanitizedPhone = Validators.sanitize(_phoneController.text);
      final sanitizedUrl = Validators.sanitize(_urlController.text);
      setState(() {
        _sanitizedResult =
            'Nama: $sanitizedName\nEmail: $sanitizedEmail\nTelepon: $sanitizedPhone\nURL: $sanitizedUrl\nPassword: Valid (Terverifikasi)';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _urlController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConfigured = AppConfig.isConfigured();

    return Scaffold(
      appBar: AppBar(
        title: const Text('RPL & Keamanan Kode'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Status Konfigurasi .env
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isConfigured ? Icons.check_circle : Icons.warning,
                          color: isConfigured ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Status Konfigurasi (.env)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${AppConfig.baseUrl}'),
                    Text(
                      'API Key: ${AppConfig.apiKey.isNotEmpty ? "•••••••• (Termuat)" : "Belum diatur"}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Navigasi ke Daftar Pengguna (Repository Pattern)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Lihat Daftar Pengguna (Repository Pattern)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 10),

            // Navigasi ke Daftar Postingan
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PostListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.article),
              label: const Text('Lihat Daftar Postingan (PostRepository)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // Card Validasi & Sanitasi Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Validasi & Sanitasi Input',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama / Pesan (uji XSS misal <script>)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validateText(
                          value,
                          fieldName: 'Nama',
                          minLength: 2,
                          maxLength: 100,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon (10-13 digit angka)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Website (http:// atau https://)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                        validator: Validators.validateUrl,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password (min 8, huruf besar, angka, simbol)',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Validasi & Sanitasi'),
                        ),
                      ),
                      if (_sanitizedResult != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Hasil Sanitasi:\n$_sanitizedResult',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card Secure Storage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Secure Storage (Token)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Token Tersimpan: ${_savedToken ?? "(Belum ada token)"}',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        labelText: 'Masukkan Token Baru',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveToken,
                            child: const Text('Simpan Token'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _deleteToken,
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

