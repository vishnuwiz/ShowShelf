import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'firebase_options.dart';
import 'firestore_store.dart';
import 'shell.dart';
import 'state.dart';
import 'theme.dart';
import 'ui/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final state = AppState(cloud: await FirestoreStore.connect());
  runApp(ShowShelfApp(state: state, splash: true));
  unawaited(state.restore());
}

class ShowShelfApp extends StatelessWidget {
  const ShowShelfApp({super.key, required this.state, this.splash = false});
  final AppState state;

  /// Play the animated splash before the app (off in tests).
  final bool splash;

  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'ShowShelf',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(state.dark ? Ss.dark : Ss.light),
        themeAnimationDuration: const Duration(milliseconds: 300),
        home: splash ? const SplashGate(child: Shell()) : const Shell(),
      ),
    ),
  );
}
