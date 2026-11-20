import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:showshelf/data.dart';
import 'package:showshelf/main.dart';
import 'package:showshelf/state.dart';

Future<AppState> boot(WidgetTester tester, {bool loadHome = false}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final s = AppState(loadHome: loadHome);
  addTearDown(s.dispose);
  await tester.pumpWidget(ShowShelfApp(state: s));
  if (!loadHome) await tester.pumpAndSettle();
  return s;
}

/// The vertical scroller of the screen on top.
Finder mainScroll() => find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).last;

Future<void> tapTab(WidgetTester tester, String name) async {
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows skeleton, then the continue card', (tester) async {
    await boot(tester, loadHome: true);
    expect(find.text('Mark as watched'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Mark as watched'), findsOneWidget);
    expect(find.text('Season 2 · Episode 4'), findsOneWidget);
  });

  testWidgets('mark as watched shows success, then advances the episode', (tester) async {
    final s = await boot(tester);
    await tester.tap(find.text('Mark as watched'));
    await tester.pump();
    expect(find.text('Watched'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('Season 2 · Episode 5'), findsOneWidget);
    expect(find.text('The Long Haul'), findsOneWidget);
    expect(s.isWatched('harbor', 2, 4), isTrue);
  });

  testWidgets('discover filter hides other kinds', (tester) async {
    await boot(tester);
    await tapTab(tester, 'Discover');
    expect(find.text('Popular TV series'), findsOneWidget);
    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();
    expect(find.text('Popular TV series'), findsNothing);
    expect(find.text('Popular movies'), findsOneWidget);
  });

  testWidgets('library filters by status and shows the empty state', (tester) async {
    await boot(tester);
    await tapTab(tester, 'Library');
    await tester.ensureVisible(find.text('Dropped').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dropped').first);
    await tester.pumpAndSettle();
    expect(find.text('Tidewater'), findsWidgets); // poster art + caption
    expect(find.text('Harbor Lights'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nothing here yet'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Harbor Lights'), findsOneWidget);
  });

  testWidgets('library tile on home opens the filtered library', (tester) async {
    final s = await boot(tester);
    await tester.scrollUntilVisible(find.text('Watchlist'), 200, scrollable: mainScroll());
    await tester.drag(mainScroll(), const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watchlist'));
    await tester.pumpAndSettle();
    expect(s.tab, 2);
    expect(s.libTab, 'plan');
    expect(find.text('Neon Meridian'), findsNothing);
  });

  testWidgets('calendar moves between months and lists releases', (tester) async {
    await boot(tester);
    await tapTab(tester, 'Calendar');
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Static Bloom'), findsOneWidget); // 23 Nov preselected
    await tester.tap(find.text('22'));
    await tester.pumpAndSettle();
    expect(find.text('The Ninth Floor'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('December 2026'), findsOneWidget);
    expect(find.text('Nothing releases on this day'), findsOneWidget);
  });

  testWidgets('finishing a season shows the completion pill', (tester) async {
    final s = await boot(tester);
    await tester.tap(find.text('Harbor Lights').first);
    await tester.pumpAndSettle();
    expect(find.text('Return Tide'), findsOneWidget); // opens on season 2
    await tester.scrollUntilVisible(find.text('Mark season watched'), 200, scrollable: mainScroll());
    await tester.tap(find.text('Mark season watched'));
    await tester.pump();
    expect(find.text('Season 2 complete'), findsOneWidget);
    expect(s.watchedCount(byId('harbor')), 14);
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();
    expect(find.text('Season 2 complete'), findsNothing);
  });

  testWidgets('watchlist button and rating on a movie', (tester) async {
    final s = await boot(tester);
    await tapTab(tester, 'Discover');
    await tester.tap(find.text('The Last Lighthouse').at(1)); // Popular movies row
    await tester.pumpAndSettle();
    expect(find.text('In your watchlist'), findsWidgets);
    await tester.tap(find.text('In your watchlist').first);
    await tester.pump();
    expect(s.status['lighthouse'], isNull);
    expect(find.text('Removed from watchlist'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.bySemanticsLabel('3 stars'));
    await tester.pumpAndSettle();
    expect(s.ratings['lighthouse'], 3);
  });

  testWidgets('search finds titles and people, and shows no results', (tester) async {
    await boot(tester);
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Recent searches'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'mira');
    await tester.pumpAndSettle();
    expect(find.text('Mira Adeyemi'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'qwerty');
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);
  });

  testWidgets('profile switches to the light theme', (tester) async {
    final s = await boot(tester);
    await tapTab(tester, 'Profile');
    await tester.scrollUntilVisible(find.text('Light'), 300, scrollable: mainScroll());
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(s.dark, isFalse);
  });
}
