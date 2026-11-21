import 'package:material_ui/material_ui.dart';

import 'auth_service.dart';

/// Who is signed in and how to sign out, for screens below the app root.
/// Empty (all null) when the app runs without sign-in, as in widget tests.
class AccountScope extends InheritedWidget {
  const AccountScope({super.key, this.user, this.auth, this.signOut, required super.child});

  final AppUser? user;
  final AuthService? auth;

  /// Saves the library, then signs out.
  final Future<void> Function()? signOut;

  static AccountScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AccountScope>();

  @override
  bool updateShouldNotify(AccountScope old) => user != old.user || auth != old.auth;
}
