import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:showshelf/ui/splash.dart';

Widget host() => const MaterialApp(home: SplashGate(child: Text('app')));

void main() {
  testWidgets('splash plays first, then reveals the app and removes itself', (tester) async {
    await tester.pumpWidget(host());
    expect(find.text('app'), findsNothing);
    expect(find.byKey(const ValueKey('splash')), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('app'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('splash')), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('tapping the splash skips it', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('app'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('splash')));
    await tester.pumpAndSettle();
    expect(find.text('app'), findsOneWidget);
    expect(find.byKey(const ValueKey('splash')), findsNothing);
  });
}
