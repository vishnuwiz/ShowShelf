import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'firebase_options.dart';
import 'firestore_store.dart';
import 'shell.dart';
import 'state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final state = AppState(cloud: await FirestoreStore.connect());
  runApp(ShowShelfApp(state: state));
  unawaited(state.restore());
}

class ShowShelfApp extends StatelessWidget {
  const ShowShelfApp({super.key, required this.state});
  final AppState state;

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
        home: const Shell(),
      ),
    ),
  );
}
