# ShowShelf

Your stories. Your collection. A movie, TV and anime tracker built in Flutter from the ShowShelf design prototype.

## Run

```sh
flutter pub get
flutter run            # Android, iOS or web
flutter test           # widget tests for the main flows
```

Requires Flutter 3.50+ (Material comes from the `material_ui` package).

## What is in it

Eight screens, all wired to one shared state:

| Screen | Interactions |
|---|---|
| Home | Continue watching card with **Mark as watched** (success state, then advances to the next episode), series progress ring, Up next with reminder toggles, library counters that count up and open the filtered Library, Recently watched. Skeleton on first load. |
| Discover | All / Movies / Series / Anime filters, trending, popular rows, top rated, genre tiles that open Search. |
| Movie details | Parallax backdrop, watchlist toggle with toast, watch status segmented control, 5-star rating, cast, similar titles. |
| Series details | Progress bar, season chips, per-episode watched toggles, **Mark season watched**, "Season N complete" pill with one expanding ring. |
| Library | Status tabs, in-library search, sort cycle (Recent, A to Z, Rating), grid/list view, animated empty shelf. |
| Calendar | Month navigation (Monday start), release dots, today ring, day list with reminder switches, empty day state. |
| Profile | Count-up stats, tappable monthly chart, year and genre bars, actors, recently completed, dark/light switch, new-user preview toggle. |
| Search | Recent searches (remove, clear all), trending searches, suggestions, results grouped Movies / TV shows / People, no-results state. |

Motion stays within 200 to 400 ms with spring easing on presses, toggles and the nav indicator. Every animation collapses to instant when the OS asks for reduced motion.

## Layout

```
lib/
  main.dart        app + theme switching
  theme.dart       colour tokens (dark, light), text helper, motion curves
  data.dart        demo catalogue, releases, episode helpers
  state.dart       AppState (ChangeNotifier) + AppScope
  shell.dart       bottom nav, per-tab navigator, toast and season overlays
  ui/art.dart      generated poster artwork (CustomPainter)
  ui/kit.dart      icons, buttons, chips, switch, segmented control, bars, entrance animations
  screens/         one file per screen (movie and series share details.dart)
```

## Notes

- All titles, people and poster art are fictional. Posters are painted in code (gradient, light source, silhouette, title type) so no real artwork is used.
- Data is in-memory demo data pinned to 20 November 2026; changes reset on restart.
- Fonts (Inter, Bebas Neue, Fraunces ExtraBold) are bundled under `assets/fonts` with their OFL licences.
