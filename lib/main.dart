import 'package:material_ui/material_ui.dart';

import 'shell.dart';
import 'state.dart';
import 'theme.dart';

void main() => runApp(ShowShelfApp(state: AppState()));

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
