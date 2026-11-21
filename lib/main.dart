import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'account.dart';
import 'auth_service.dart';
import 'cloud_store.dart';
import 'firebase_auth_service.dart';
import 'firebase_options.dart';
import 'firestore_store.dart';
import 'screens/login.dart';
import 'shell.dart';
import 'state.dart';
import 'theme.dart';
import 'ui/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ShowShelfRoot(auth: FirebaseAuthService(), storeFor: FirestoreStore.new, splash: true));
}

/// Where a person's library is kept online.
typedef StoreFactory = CloudStore Function(String uid);

/// Owns sign-in. Signed out it shows the login screen; signed in it builds
/// the library for that person and keeps it saved to their own document.
class ShowShelfRoot extends StatefulWidget {
  const ShowShelfRoot({super.key, required this.auth, required this.storeFor, this.splash = false, this.loadHome = true});
  final AuthService auth;
  final StoreFactory storeFor;
  final bool splash;

  /// Show the Home skeleton while it loads (off in tests, where it never settles).
  final bool loadHome;

  @override
  State<ShowShelfRoot> createState() => _ShowShelfRootState();
}

class _ShowShelfRootState extends State<ShowShelfRoot> {
  // Stands in for the library while nobody is signed in (theme, scope).
  final _idle = AppState(loadHome: false);
  AppState? _app;
  AppUser? _user;
  StreamSubscription<AppUser?>? _sub;

  @override
  void initState() {
    super.initState();
    _apply(widget.auth.current);
    _sub = widget.auth.changes().listen((u) => setState(() => _apply(u)));
  }

  /// A different person gets a different library. The same person (a guest
  /// who just made an account) keeps theirs.
  void _apply(AppUser? user) {
    final changed = user?.uid != _user?.uid;
    _user = user;
    if (!changed) return;
    final old = _app;
    if (user == null) {
      _app = null;
    } else {
      _app = AppState(loadHome: widget.loadHome, cloud: widget.storeFor(user.uid));
      unawaited(_app!.restore());
    }
    // After this frame, so nothing is still listening to it.
    if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  Future<void> _signOut() async {
    await _app?.flush();
    await widget.auth.signOut();
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _app?.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShowShelfApp(
    state: _app ?? _idle,
    splash: widget.splash,
    auth: widget.auth,
    user: _user,
    signOut: _signOut,
  );
}

class ShowShelfApp extends StatelessWidget {
  const ShowShelfApp({super.key, required this.state, this.splash = false, this.auth, this.user, this.signOut});
  final AppState state;

  /// Play the animated splash before the app (off in tests).
  final bool splash;

  /// Sign-in. Null runs the app without it, as widget tests do.
  final AuthService? auth;
  final AppUser? user;
  final Future<void> Function()? signOut;

  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: AccountScope(
      user: user,
      auth: auth,
      signOut: signOut,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'ShowShelf',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(state.dark ? Ss.dark : Ss.light),
          themeAnimationDuration: const Duration(milliseconds: 300),
          home: _Gate(auth: auth, user: user, splash: splash),
        ),
      ),
    ),
  );
}

/// Login when signed out, the app when signed in, with a short fade between.
class _Gate extends StatelessWidget {
  const _Gate({required this.auth, required this.user, required this.splash});
  final AuthService? auth;
  final AppUser? user;
  final bool splash;

  @override
  Widget build(BuildContext context) {
    final a = auth;
    final u = user;
    Widget page = a == null
        ? const Shell()
        : u == null
        ? LoginScreen(key: const ValueKey('login'), auth: a)
        : Shell(key: ValueKey(u.uid));
    if (a != null) page = AnimatedSwitcher(duration: ms(context, 350), child: page);
    return splash ? SplashGate(child: page) : page;
  }
}
