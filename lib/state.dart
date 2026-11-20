import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'data.dart';

/// Whole-app state. One ChangeNotifier is enough for a demo of this size.
class AppState extends ChangeNotifier {
  AppState({bool loadHome = true}) {
    if (loadHome) {
      _later(const Duration(milliseconds: 1100), () => homeLoading = false);
    } else {
      homeLoading = false;
    }
  }

  bool dark = true;
  int tab = 0; // 0 home, 1 discover, 2 library, 3 calendar, 4 profile
  int tabEpoch = 0; // bumps on every tab tap so the tab's stack resets

  // Library
  String libTab = 'all';
  bool libGrid = true;
  String libSort = 'recent';
  bool newUser = false;

  final Set<String> watched = seedWatched();
  final Map<String, String> status = Map.of(seedStatus);
  final Map<String, int> ratings = {'neon': 4, 'quiet': 5, 'fieldwork': 4, 'harbor': 4, 'ninth': 4, 'kiln': 5};
  final Set<String> reminders = {'2026-11-22ninth'};
  List<String> recents = ['Kiln', 'Quiet Orbit', 'Fieldwork'];

  // Home "continue watching"
  bool homeLoading = true;
  bool marking = false;
  double pos = .55; // playback position of the current episode, 0..1

  // Overlays
  String toast = '';
  String celebrate = '';

  final List<Timer> _timers = [];
  Timer? _toastTimer, _celebrateTimer;

  void _later(Duration d, VoidCallback fn) {
    _timers.add(
      Timer(d, () {
        fn();
        notifyListeners();
      }),
    );
  }

  void _set(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final t in [..._timers, _toastTimer, _celebrateTimer]) {
      t?.cancel();
    }
    super.dispose();
  }

  // ---- derived ----
  bool isWatched(String id, int s, int e) => watched.contains(epKey(id, s, e));

  int watchedCount(Show t) {
    var n = 0;
    for (var s = 1; s <= t.seasons.length; s++) {
      for (var e = 1; e <= t.seasons[s - 1]; e++) {
        if (isWatched(t.id, s, e)) n++;
      }
    }
    return n;
  }

  ({int s, int e})? nextEp(Show t) {
    for (var s = 1; s <= t.seasons.length; s++) {
      for (var e = 1; e <= t.seasons[s - 1]; e++) {
        if (!isWatched(t.id, s, e)) return (s: s, e: e);
      }
    }
    return null;
  }

  // ---- actions ----
  void setDark(bool v) => _set(() => dark = v);

  void setTab(int i) => _set(() {
    tab = i;
    tabEpoch++;
  });

  void openLibrary(String filter) => _set(() {
    libTab = filter;
    tab = 2;
    tabEpoch++;
  });

  void setLibTab(String v) => _set(() => libTab = v);
  void toggleLibView() => _set(() => libGrid = !libGrid);
  void cycleSort() => _set(() => libSort = const {'recent': 'title', 'title': 'rating', 'rating': 'recent'}[libSort]!);
  void toggleNewUser() => _set(() => newUser = !newUser);

  void showToast(String msg) {
    _toastTimer?.cancel();
    _set(() => toast = msg);
    _toastTimer = Timer(const Duration(milliseconds: 1800), () => _set(() => toast = ''));
  }

  void _checkSeasonDone(String id, int s) {
    final t = byId(id);
    for (var e = 1; e <= t.seasons[s - 1]; e++) {
      if (!isWatched(id, s, e)) return;
    }
    _celebrateTimer?.cancel();
    celebrate = 'Season $s complete';
    _celebrateTimer = Timer(const Duration(milliseconds: 2300), () => _set(() => celebrate = ''));
  }

  /// Home card: show the success state, then advance to the next episode.
  void markHome() {
    final t = byId('harbor');
    final nx = nextEp(t);
    if (nx == null || marking) return;
    _set(() => marking = true);
    _later(const Duration(milliseconds: 1200), () {
      watched.add(epKey('harbor', nx.s, nx.e));
      marking = false;
      pos = 0;
      _checkSeasonDone('harbor', nx.s);
    });
  }

  void toggleEp(String id, int s, int e) => _set(() {
    final k = epKey(id, s, e);
    if (!watched.remove(k)) {
      watched.add(k);
      _checkSeasonDone(id, s);
    }
    if (id == 'harbor') pos = 0;
  });

  void markSeason(String id, int s) => _set(() {
    for (var e = 1; e <= byId(id).seasons[s - 1]; e++) {
      watched.add(epKey(id, s, e));
    }
    status.putIfAbsent(id, () => 'watching');
    if (id == 'harbor') pos = 0;
    _checkSeasonDone(id, s);
  });

  void setStatus(String id, String v) => _set(() {
    if (status[id] == v) {
      status.remove(id);
    } else {
      status[id] = v;
    }
  });

  void toggleWatchlist(String id) {
    final adding = status[id] != 'plan';
    _set(() => adding ? status[id] = 'plan' : status.remove(id));
    showToast(adding ? 'Added to watchlist' : 'Removed from watchlist');
  }

  void setRating(String id, int n) => _set(() => ratings[id] == n ? ratings.remove(id) : ratings[id] = n);

  void toggleReminder(String key) {
    final on = !reminders.contains(key);
    _set(() => on ? reminders.add(key) : reminders.remove(key));
    showToast(on ? 'Reminder on' : 'Reminder off');
  }

  void removeRecent(String r) => _set(() => recents = recents.where((x) => x != r).toList());
  void clearRecents() => _set(() => recents = []);
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
