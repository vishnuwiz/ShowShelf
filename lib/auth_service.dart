import 'dart:async';

/// The signed-in person, as the screens need to see them.
class AppUser {
  const AppUser({required this.uid, this.email, this.isGuest = false});

  final String uid;
  final String? email;

  /// Signed in without an account. Their shelf is kept online, but only this
  /// sign-in can reach it until they create an account.
  final bool isGuest;

  @override
  bool operator ==(Object other) => other is AppUser && other.uid == uid && other.email == email && other.isGuest == isGuest;

  @override
  int get hashCode => Object.hash(uid, email, isGuest);
}

/// Which field a failure belongs next to.
enum AuthField { email, password }

/// A sign-in problem with a message that can be shown as written.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.field});

  final String message;
  final AuthField? field;

  @override
  String toString() => 'AuthFailure($message)';
}

/// What the app needs from sign-in. [FirebaseAuthService] is the real one;
/// tests use a fake.
abstract class AuthService {
  /// Who is signed in right now, or null.
  AppUser? get current;

  /// Emits whenever the person signs in, signs out or their account changes.
  Stream<AppUser?> changes();

  /// Throws [AuthFailure].
  Future<void> signIn(String email, String password);

  /// Creates an account. A guest keeps their shelf: the account is attached
  /// to the guest sign-in instead of starting a new one. Throws [AuthFailure].
  Future<void> register(String email, String password);

  /// Emails a reset link. Throws [AuthFailure].
  Future<void> sendReset(String email);

  /// Throws [AuthFailure].
  Future<void> continueAsGuest();

  Future<void> signOut();
}
