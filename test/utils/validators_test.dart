import 'package:flutter_test/flutter_test.dart';
import 'package:rpl_keamanan/utils/validators.dart';

void main() {
  group('Validators Unit Test', () {
    // a) Test isValidEmail() dengan berbagai skenario
    group('isValidEmail()', () {
      test('mengembalikan true untuk email dengan format valid', () {
        expect(Validators.isValidEmail('user@example.com'), isTrue);
        expect(Validators.isValidEmail('mahasiswa@amikom.ac.id'), isTrue);
        expect(Validators.isValidEmail('nama.depan+tag@sub.domain.org'), isTrue);
      });

      test('mengembalikan false untuk email dengan format tidak valid', () {
        expect(Validators.isValidEmail(''), isFalse);
        expect(Validators.isValidEmail('userexample.com'), isFalse);
        expect(Validators.isValidEmail('user@'), isFalse);
        expect(Validators.isValidEmail('@example.com'), isFalse);
        expect(Validators.isValidEmail('user@example'), isFalse);
      });
    });

    // b) Test sanitize() dengan input berbahaya
    group('sanitize()', () {
      test('mengganti karakter berbahaya HTML/XSS dengan HTML entities', () {
        const maliciousInput = '<script>alert("XSS")</script>';
        final result = Validators.sanitize(maliciousInput);

        expect(
          result,
          equals('&lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt;'),
        );
        expect(result.contains('<'), isFalse);
        expect(result.contains('>'), isFalse);
      });

      test('mengganti tanda kutip tunggal dan menghapus spasi di awal/akhir', () {
        const input = "  ' OR '1'='1  ";
        final result = Validators.sanitize(input);

        expect(result, equals('&#x27; OR &#x27;1&#x27;=&#x27;1'));
      });
    });

    // c) Test validateText() dengan berbagai panjang
    group('validateText()', () {
      test('mengembalikan pesan error jika teks kosong atau hanya spasi', () {
        expect(
          Validators.validateText(null, fieldName: 'Nama'),
          equals('Nama tidak boleh kosong'),
        );
        expect(
          Validators.validateText('   ', fieldName: 'Nama'),
          equals('Nama tidak boleh kosong'),
        );
      });

      test('mengembalikan pesan error jika panjang teks kurang dari minLength', () {
        expect(
          Validators.validateText('A', fieldName: 'Nama', minLength: 3, maxLength: 10),
          equals('Nama harus antara 3-10 karakter'),
        );
      });

      test('mengembalikan pesan error jika panjang teks melebihi maxLength', () {
        expect(
          Validators.validateText('TeksTerlaluPanjangSekali', fieldName: 'Nama', minLength: 3, maxLength: 10),
          equals('Nama harus antara 3-10 karakter'),
        );
      });

      test('mengembalikan null jika panjang teks berada di antara minLength dan maxLength', () {
        expect(
          Validators.validateText('Budi Santoso', fieldName: 'Nama', minLength: 3, maxLength: 50),
          isNull,
        );
      });
    });

    // Tambahan: Test validasi Latihan 3 (Telepon, URL, Password)
    group('Validasi Tambahan (Telepon, URL, Password)', () {
      test('validatePhone() memvalidasi nomor telepon 10-13 digit angka', () {
        expect(Validators.validatePhone('081234567890'), isNull);
        expect(Validators.validatePhone('08123'), isNotNull);
        expect(Validators.validatePhone('08123456789a'), isNotNull);
      });

      test('validateUrl() memvalidasi URL http/https', () {
        expect(Validators.validateUrl('https://amikom.ac.id'), isNull);
        expect(Validators.validateUrl('http://example.com'), isNull);
        expect(Validators.validateUrl('ftp://example.com'), isNotNull);
        expect(Validators.validateUrl('amikom.ac.id'), isNotNull);
      });

      test('validatePassword() memvalidasi kriteria password kuat', () {
        expect(Validators.validatePassword('Aman@1234'), isNull);
        expect(Validators.validatePassword('pendek'), isNotNull);
        expect(Validators.validatePassword('tanpahurufbesar@123'), isNotNull);
        expect(Validators.validatePassword('TanpaAngka@'), isNotNull);
        expect(Validators.validatePassword('TanpaSimbol123'), isNotNull);
      });
    });
  });
}

