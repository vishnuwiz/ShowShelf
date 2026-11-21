/// Where one user's library lives online.
///
/// The whole library is a single document, `users/{uid}`, so opening the app
/// costs one read and every save costs one write.
abstract class CloudStore {
  /// The saved document, or null when this user has nothing saved yet.
  Future<Map<String, dynamic>?> load();

  /// Replaces the saved document.
  Future<void> save(Map<String, dynamic> data);
}
