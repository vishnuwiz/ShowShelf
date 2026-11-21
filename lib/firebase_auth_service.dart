import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

/// Firebase Authentication with email and password, plus guest (anonymous) sign-in.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static AppUser? _map(User? u) => u == null ? null : AppUser(uid: u.uid, email: u.email, isGuest: u.isAnonymous);

  @override
  AppUser? get current => _map(_auth.currentUser);

  // userChanges (not authStateChanges) so linking a guest to an account is seen.
  @override
  Stream<AppUser?> changes() => _auth.userChanges().map(_map);

  @override
  Future<void> signIn(String email, String password) => _run(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: password));

  @override
  Future<void> register(String email, String password) => _run(() {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      return user.linkWithCredential(EmailAuthProvider.credential(email: email.trim(), password: password));
    }
    return _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
  });

  @override
  Future<void> sendReset(String email) => _run(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> continueAsGuest() => _run(_auth.signInAnonymously);

  @override
  Future<void> signOut() => _auth.signOut();

  Future<void> _run(Future<Object?> Function() job) async {
    try {
      await job();
    } on FirebaseAuthException catch (e) {
      throw _failure(e);
    }
  }

  static AuthFailure _failure(FirebaseAuthException e) => switch (e.code) {
    'invalid-email' => const AuthFailure('That email address does not look right. Check it and try again.', field: AuthField.email),
    'user-disabled' => const AuthFailure('This account has been disabled.', field: AuthField.email),
    'user-not-found' || 'wrong-password' || 'invalid-credential' => const AuthFailure(
      'Email or password is wrong. Check both, or reset your password.',
      field: AuthField.password,
    ),
    'email-already-in-use' || 'credential-already-in-use' => const AuthFailure(
      'An account with this email already exists. Sign in instead.',
      field: AuthField.email,
    ),
    'weak-password' => const AuthFailure('Use at least 6 characters.', field: AuthField.password),
    'network-request-failed' => const AuthFailure('No connection. Check your internet and try again.'),
    'too-many-requests' => const AuthFailure('Too many attempts. Wait a few minutes, then try again.'),
    'operation-not-allowed' => const AuthFailure('This sign-in method is switched off. Turn on Email/Password in Firebase Authentication.'),
    _ => AuthFailure('Something went wrong (${e.code}). Try again.'),
  };
}
