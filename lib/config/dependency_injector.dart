import 'package:flutter/widgets.dart';
import '../repositories/post_repository.dart';
import '../repositories/post_repository_impl.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_repository_impl.dart';
import '../services/api_service.dart';

/// Menyediakan instance service dan repository ke seluruh widget tree
/// menggunakan [InheritedWidget] (Dependency Injection sederhana).
class DependencyInjector extends InheritedWidget {
  /// Singleton instance untuk [ApiService].
  static final ApiService _apiServiceInstance = ApiService();

  /// Instance [ApiService] yang digunakan bersama.
  final ApiService apiService;

  /// Instance [UserRepository] untuk mengelola data pengguna.
  final UserRepository userRepository;

  /// Instance [PostRepository] untuk mengelola data postingan.
  final PostRepository postRepository;

  /// Membuat [DependencyInjector] dengan singleton [ApiService] sebagai default.
  DependencyInjector({
    super.key,
    required super.child,
    ApiService? apiService,
    UserRepository? userRepository,
    PostRepository? postRepository,
  })  : apiService = apiService ?? _apiServiceInstance,
        userRepository = userRepository ??
            UserRepositoryImpl(apiService: apiService ?? _apiServiceInstance),
        postRepository = postRepository ??
            PostRepositoryImpl(apiService: apiService ?? _apiServiceInstance);

  /// Mengambil instance [DependencyInjector] terdekat dari [context].
  static DependencyInjector of(BuildContext context) {
    final injector = maybeOf(context);
    assert(injector != null, 'DependencyInjector tidak ditemukan di context');
    return injector!;
  }

  /// Mengambil instance [DependencyInjector] terdekat jika ada.
  static DependencyInjector? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DependencyInjector>();
  }

  @override
  bool updateShouldNotify(DependencyInjector oldWidget) {
    return apiService != oldWidget.apiService ||
        userRepository != oldWidget.userRepository ||
        postRepository != oldWidget.postRepository;
  }
}

