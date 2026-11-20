import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../shell.dart';
import '../theme.dart';
import '../ui/art.dart';
import '../ui/kit.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String filter = 'all';

  static const _chips = [('all', 'All'), ('movies', 'Movies'), ('series', 'Series'), ('anime', 'Anime')];
  static const _genres = [('Drama', 205, 2), ('Sci-Fi', 255, 1), ('Thriller', 345, 1), ('Mystery', 268, 0), ('Fantasy', 25, 3), ('Crime', 170, 2)];

  bool _ok(Show t) => switch (filter) {
    'movies' => t.kind == Kind.movie,
    'series' => t.kind == Kind.series,
    'anime' => t.kind == Kind.anime,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final shown = titles.where(_ok).toList();
    final byRating = [...shown]..sort((a, b) => b.r.compareTo(a.r));
    final movies = shown.where((t) => t.isMovie).toList();
    final series = shown.where((t) => !t.isMovie).toList();

    Widget row(List<Show> list) => HRow(
      children: [
        for (final t in list) PosterCard(t, width: 112, onTap: () => openTitle(context, t.id), caption: '${t.r.toStringAsFixed(1)} · ${t.year}', star: c.sub),
      ],
    );

    return ListView(
      padding: EdgeInsets.only(top: top + 20, bottom: 32),
      children: [
        px(const H1('Discover')),
        const SizedBox(height: 14),
        px(
          Tap(
            label: 'Search movies, series and people',
            onTap: () => openSearch(context),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: cardDeco(c, 16),
              child: Row(
                children: [
                  Ic(I.search, size: 20, color: c.sub),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search movies, series, people',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(15, color: c.sub),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        PillRow(
          children: [for (final ch in _chips) Pill(ch.$2, on: filter == ch.$1, onTap: () => setState(() => filter = ch.$1))],
        ),
        // Re-key on filter so the sections replay their entrance.
        Entrance(
          key: ValueKey(filter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (byRating.isNotEmpty) ...[
                const H2('Trending this week'),
                HRow(
                  children: [
                    for (final t in byRating.take(6))
                      PosterCard(
                        t,
                        width: 152,
                        radius: 14,
                        pop: true,
                        onTap: () => openTitle(context, t.id),
                        caption: '${t.r.toStringAsFixed(1)} · ${t.year}',
                        star: c.sub,
                      ),
                  ],
                ),
              ],
              if (movies.isNotEmpty) ...[const H2('Popular movies'), row(movies)],
              if (series.isNotEmpty) ...[const H2('Popular TV series'), row(series)],
              const H2('Top rated'),
              for (final (i, t) in byRating.take(4).indexed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: TitleRow(
                    t,
                    line2: '${t.kindLabel} · ${t.genre} · ${t.year}',
                    onTap: () => openTitle(context, t.id),
                    leading: SizedBox(
                      width: 22,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.center,
                        style: ts(15, w: FontWeight.w700, color: c.sub),
                      ),
                    ),
                    trailing: Rating(t.r.toStringAsFixed(1)),
                  ),
                ),
            ],
          ),
        ),
        const H2('Browse by genre', top: 16),
        px(
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 165 / 72,
            children: [
              for (final g in _genres)
                Tap(
                  label: 'Browse ${g.$1}',
                  onTap: () => openSearch(context, g.$1),
                  child: ArtBox(
                    Art(g.$2, g.$3),
                    radius: 16,
                    ridge: false,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Text(
                          g.$1,
                          style: ts(15, w: FontWeight.w700, color: Colors.white).copyWith(
                            shadows: const [Shadow(color: Color(0x80000000), blurRadius: 6, offset: Offset(0, 1))],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
