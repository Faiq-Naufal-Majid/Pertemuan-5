import '../models/post.dart';

/// Abstraksi repository untuk mengelola data postingan (Post).
///
/// Interface ini mendefinisikan kontrak untuk operasi data Post.
/// Implementasi konkretnya ada di [PostRepositoryImpl].
abstract class PostRepository {
  /// Mengambil daftar semua postingan dari API.
  ///
  /// Mengembalikan [List<Post>] jika berhasil.
  /// Melempar [Exception] jika terjadi error.
  Future<List<Post>> getPosts();

  /// Mengambil postingan berdasarkan [id].
  ///
  /// Parameter [id] harus berupa integer positif.
  /// Mengembalikan [Post] jika ditemukan.
  Future<Post> getPostById(int id);
}

