import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:showshelf/account.dart';
import 'package:showshelf/auth_service.dart';
import 'package:showshelf/cloud_store.dart';
import 'package:showshelf/main.dart';
import 'package:showshelf/screens/account.dart';
import 'package:showshelf/screens/login.dart';
import 'package:showshelf/shell.dart';
import 'package:showshelf/theme.dart';
import 'package:showshelf/ui/kit.dart';

class FakeAuth implements AuthService {
  FakeAuth([this._user]);

  AppUser? _user;
  final _changes = StreamController<AppUser?>.broadcast();
  final calls = <String>[];
  AuthFailure? failNext;

  void _set(AppUser? u) {
    _user = u;
    _changes.add(u);
  }

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  @override
  AppUser? get current => _user;

  @override
  Stream<AppUser?> changes() => _changes.stream;

  @override
  Future<void> signIn(String email, String password) async {
    calls.add('signIn $email');
    _maybeFail();
    _set(AppUser(uid: 'u1', email: email));
  }

  @override
  Future<void> register(String email, String password) async {
    calls.add('register $email');
    _maybeFail();
    _set(AppUser(uid: _user?.isGuest == true ? _user!.uid : 'u2', email: email));
  }

  @override
  Future<void> sendReset(String email) async => calls.add('reset $email');

  @override
  Future<void> continueAsGuest() async {
    calls.add('guest');
    _set(const AppUser(uid: 'g1', isGuest: true));
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _set(null);
  }
}

class NullCloud implements CloudStore {
  @override
  Future<Map<String, dynamic>?> load() async => null;

  @override
  Future<void> save(Map<String, dynamic> data) async {}
}

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Ends a test by removing the app, so the library's save timer is cancelled.
Future<void> close(WidgetTester tester) => tester.pumpWidget(const SizedBox());

Future<void> login(WidgetTester tester, FakeAuth auth) async {
  phone(tester);
  await tester.pumpWidget(ShowShelfRoot(auth: auth, loadHome: false, storeFor: (_) => NullCloud()));
  await tester.pumpAndSettle();
}

Finder button(String label) => find.widgetWithText(SsButton, label);

void main() {
  testWidgets('signed out shows the login screen', (tester) async {
    await login(tester, FakeAuth());
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(Shell), findsNothing);
    await close(tester);
  });

  testWidgets('empty and badly formed emails are caught before sign-in', (tester) async {
    final auth = FakeAuth();
    await login(tester, auth);
    await tester.tap(button('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email address.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'nope');
    await tester.tap(button('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('That email address does not look right.'), findsOneWidget);
    expect(auth.calls, isEmpty);
    await close(tester);
  });

  testWidgets('signing in opens the app', (tester) async {
    final auth = FakeAuth();
    await login(tester, auth);
    await tester.enterText(find.byType(TextField).at(0), 'maya@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret12');
    await tester.tap(button('Sign in'));
    await tester.pumpAndSettle();
    expect(auth.calls, ['signIn maya@example.com']);
    expect(find.byType(Shell), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    await close(tester);
  });

  testWidgets('a failed sign-in shows its message next to the field', (tester) async {
    final auth = FakeAuth()..failNext = const AuthFailure('Email or password is wrong. Check both, or reset your password.', field: AuthField.password);
    await login(tester, auth);
    await tester.enterText(find.byType(TextField).at(0), 'maya@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'badpass');
    await tester.tap(button('Sign in'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Email or password is wrong'), findsOneWidget);
    expect(find.byType(Shell), findsNothing);
    await close(tester);
  });

  testWidgets('create account asks for six characters', (tester) async {
    final auth = FakeAuth();
    await login(tester, auth);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'maya@example.com');
    await tester.enterText(find.byType(TextField).at(1), '123');
    await tester.tap(button('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    expect(auth.calls, isEmpty);

    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(button('Create account'));
    await tester.pumpAndSettle();
    expect(auth.calls, ['register maya@example.com']);
    expect(find.byType(Shell), findsOneWidget);
    await close(tester);
  });

  testWidgets('forgot password sends a reset link', (tester) async {
    final auth = FakeAuth();
    await login(tester, auth);
    await tester.enterText(find.byType(TextField).first, 'maya@example.com');
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(auth.calls, ['reset maya@example.com']);
    expect(find.textContaining('Reset link sent to maya@example.com'), findsOneWidget);
    await close(tester);
  });

  testWidgets('guest goes straight in', (tester) async {
    final auth = FakeAuth();
    await login(tester, auth);
    await tester.tap(button('Continue as guest'));
    await tester.pumpAndSettle();
    expect(auth.calls, ['guest']);
    expect(find.byType(Shell), findsOneWidget);
    await close(tester);
  });

  testWidgets('each person gets their own library, and signing out returns to login', (tester) async {
    final auth = FakeAuth(const AppUser(uid: 'u1', email: 'a@b.co'));
    final uids = <String>[];
    phone(tester);
    await tester.pumpWidget(
      ShowShelfRoot(
        auth: auth,
        loadHome: false,
        storeFor: (uid) {
          uids.add(uid);
          return NullCloud();
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Shell), findsOneWidget);
    expect(uids, ['u1']);

    await auth.signOut();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await auth.continueAsGuest();
    await tester.pumpAndSettle();
    expect(uids, ['u1', 'g1']);
    await close(tester);
  });

  group('account section', () {
    Future<FakeAuth> section(WidgetTester tester, AppUser user) async {
      phone(tester);
      final auth = FakeAuth(user);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(Ss.dark),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AccountScope(user: user, auth: auth, signOut: auth.signOut, child: const AccountSection()),
            ),
          ),
        ),
      );
      return auth;
    }

    testWidgets('an account shows its email and signs out at once', (tester) async {
      final auth = await section(tester, const AppUser(uid: 'u1', email: 'maya@example.com'));
      expect(find.text('maya@example.com'), findsOneWidget);
      expect(find.text('Create account'), findsNothing);
      await tester.tap(button('Sign out'));
      await tester.pumpAndSettle();
      expect(auth.calls, ['signOut']);
    });

    testWidgets('a guest is warned before signing out', (tester) async {
      final auth = await section(tester, const AppUser(uid: 'g1', isGuest: true));
      expect(button('Create account'), findsOneWidget);
      await tester.tap(button('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out of guest?'), findsOneWidget);
      expect(auth.calls, isEmpty);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(auth.calls, isEmpty);

      await tester.tap(button('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out anyway'));
      await tester.pumpAndSettle();
      expect(auth.calls, ['signOut']);
    });

    testWidgets('without sign-in the section is empty', (tester) async {
      phone(tester);
      await tester.pumpWidget(MaterialApp(theme: buildTheme(Ss.dark), home: const Scaffold(body: AccountSection())));
      expect(find.text('Account'), findsNothing);
    });
  });
}
