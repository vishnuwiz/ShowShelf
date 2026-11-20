import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'data.dart';
import 'screens/calendar.dart';
import 'screens/details.dart';
import 'screens/discover.dart';
import 'screens/home.dart';
import 'screens/library.dart';
import 'screens/profile.dart';
import 'screens/search.dart';
import 'state.dart';
import 'theme.dart';
import 'ui/kit.dart';

/// Screen transition: fade plus a short rise (340ms).
Route<void> _route(Widget page) => PageRouteBuilder(
  pageBuilder: (_, _, _) => page,
  transitionDuration: const Duration(milliseconds: 340),
  reverseTransitionDuration: const Duration(milliseconds: 240),
  transitionsBuilder: (context, a, _, child) {
    if (MediaQuery.of(context).disableAnimations) return child;
    final t = CurvedAnimation(parent: a, curve: kEase);
    return FadeTransition(
      opacity: t,
      child: AnimatedBuilder(
        animation: t,
        builder: (_, c) => Transform.translate(offset: Offset(0, 14 * (1 - t.value)), child: c),
        child: child,
      ),
    );
  },
);

void openTitle(BuildContext context, String id) {
  final t = byId(id);
  Navigator.of(context).push(_route(t.isMovie ? MovieScreen(show: t) : SeriesScreen(show: t)));
}

void openSearch(BuildContext context, [String query = '']) => Navigator.of(context).push(_route(SearchScreen(initial: query)));

const _tabs = [(I.home, 'Home'), (I.compass, 'Discover'), (I.library, 'Library'), (I.calendar, 'Calendar'), (I.user, 'Profile')];

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  // A fresh navigator (and key) per tab tap: switching tabs resets the stack.
  int _epoch = -1;
  var _nav = GlobalKey<NavigatorState>();

  Widget _root(int tab) => switch (tab) {
    0 => const HomeScreen(),
    1 => const DiscoverScreen(),
    2 => const LibraryScreen(),
    3 => const CalendarScreen(),
    _ => const ProfileScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    if (s.tabEpoch != _epoch) {
      _epoch = s.tabEpoch;
      _nav = GlobalKey<NavigatorState>();
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: c.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_nav.currentState?.canPop() ?? false) {
            _nav.currentState!.pop();
          } else if (s.tab != 0) {
            s.setTab(0);
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          body: DefaultTextStyle(
            style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: c.text),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: ms(context, 340),
                        transitionBuilder: (child, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween(begin: const Offset(0, .017), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: kEase)),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_epoch),
                          child: Navigator(
                            key: _nav,
                            onGenerateRoute: (_) => PageRouteBuilder(pageBuilder: (_, _, _) => _root(s.tab)),
                          ),
                        ),
                      ),
                      const _Overlays(),
                    ],
                  ),
                ),
                _NavBar(index: s.tab, onTap: s.setTab),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Semantics(
      container: true,
      label: 'Main',
      child: Container(
        height: 62 + (bottom > 0 ? bottom : 12),
        padding: EdgeInsets.only(bottom: bottom > 0 ? bottom : 12),
        decoration: BoxDecoration(
          color: c.bg2,
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth / 5;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedPositioned(
                  duration: ms(context, 450),
                  curve: kSpringSoft,
                  left: index * w + (w - 30) / 2,
                  top: -1,
                  child: Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: c.accentInk,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < 5; i++)
                      Expanded(
                        child: Tap(
                          label: _tabs[i].$2,
                          selected: i == index,
                          press: false,
                          onTap: () => onTap(i),
                          child: TweenAnimationBuilder<Color?>(
                            tween: ColorTween(end: i == index ? c.accentInk : c.sub),
                            duration: ms(context, 250),
                            builder: (_, col, _) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Ic(_tabs[i].$1, size: 24, color: col),
                                const SizedBox(height: 4),
                                Text(
                                  _tabs[i].$2,
                                  style: ts(11, w: FontWeight.w600, color: col),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Toast and "season complete" pill, 20px above the nav bar.
class _Overlays extends StatelessWidget {
  const _Overlays();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: IgnorePointer(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (s.celebrate.isNotEmpty) ...[
                _Ring(key: ValueKey('ring${s.celebrate}'), color: c.accent),
                Entrance(
                  key: ValueKey(s.celebrate),
                  fx: Fx.pop,
                  duration: 500,
                  child: Semantics(
                    liveRegion: true,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.fromLTRB(14, 0, 20, 0),
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 8))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DrawCheck(color: c.onAccent),
                          const SizedBox(width: 10),
                          Text(
                            s.celebrate,
                            style: ts(15, w: FontWeight.w700, color: c.onAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (s.toast.isNotEmpty)
                Entrance(
                  key: ValueKey(s.toast),
                  fx: Fx.pop,
                  duration: 500,
                  child: Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: c.text,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 24, offset: Offset(0, 8))],
                      ),
                      child: Text(
                        s.toast,
                        style: ts(14, w: FontWeight.w600, color: c.bg),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One expanding ring (no confetti).
class _Ring extends StatelessWidget {
  const _Ring({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: ms(context, 900),
    curve: kEase,
    builder: (_, t, _) => Opacity(
      opacity: (.9 * (1 - t)).clamp(0, 1),
      child: Transform.scale(
        scale: .3 + 2.3 * t,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
      ),
    ),
  );
}
