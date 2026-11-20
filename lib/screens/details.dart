import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../shell.dart';
import '../state.dart';
import '../theme.dart';
import '../ui/art.dart';
import '../ui/kit.dart';

/// Scroll page with a parallax backdrop, back button and overlapping poster.
class _DetailScaffold extends StatefulWidget {
  const _DetailScaffold({required this.show, required this.meta, required this.backdrop, required this.overlap, required this.posterW, required this.children});
  final Show show;
  final String meta;
  final double backdrop, overlap, posterW;
  final List<Widget> children;

  @override
  State<_DetailScaffold> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState extends State<_DetailScaffold> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final t = widget.show;
    final top = MediaQuery.paddingOf(context).top;
    final still = MediaQuery.of(context).disableAnimations;
    final bh = widget.backdrop + top;
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.only(bottom: 28),
          child: Stack(
            children: [
              SizedBox(
                height: bh,
                width: double.infinity,
                child: ClipRect(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: bh + 30,
                        child: AnimatedBuilder(
                          animation: _scroll,
                          builder: (_, child) {
                            final y = _scroll.hasClients && !still ? math.min(_scroll.offset, 300) * .4 : 0.0;
                            return Transform.translate(offset: Offset(0, y), child: child);
                          },
                          child: ArtBox(Art.of(t)),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [const Color(0x66101114), const Color(0x00101114), c.bg],
                              stops: const [0, .28, 1],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: bh - widget.overlap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    px(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Entrance(
                            fx: Fx.pop,
                            duration: 500,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 28, offset: Offset(0, 10))],
                              ),
                              child: Poster(t, width: widget.posterW, radius: 14),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  H1(t.title, size: 26),
                                  const SizedBox(height: 6),
                                  Text(widget.meta, style: ts(14, color: c.sub)),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 28,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: cardDeco(c, 14),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Ic(I.star, size: 13, fill: true, stroke: 0, color: c.accentInk),
                                        const SizedBox(width: 6),
                                        Text(t.r.toStringAsFixed(1), style: ts(13, w: FontWeight.w700)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'TMDB',
                                          style: ts(13, w: FontWeight.w500, color: c.sub),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...widget.children,
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: top + 14,
          left: 16,
          child: Tap(
            label: 'Back',
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0x8C101114), borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: const Ic(I.back, color: Colors.white, stroke: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class MovieScreen extends StatelessWidget {
  const MovieScreen({super.key, required this.show});
  final Show show;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final t = show;
    final inList = s.status[t.id] == 'plan';
    const seg = [('plan', 'Plan to watch'), ('watching', 'Watching'), ('completed', 'Watched')];
    final segIdx = seg.indexWhere((x) => x.$1 == s.status[t.id]);
    final mine = s.ratings[t.id] ?? 0;
    final crew = [
      for (final (i, id) in t.cast.indexed) (people[id]!, const ['Lead', 'Supporting', 'Featured'][i], hsl(t.h + i * 70, 35, 32)),
      (t.dir, 'Director', hsl(t.h + 200, 30, 30)),
    ];

    return _DetailScaffold(
      show: t,
      meta: '${t.year} · ${t.run ~/ 60}h ${t.run % 60}m · ${t.genre}',
      backdrop: 330,
      overlap: 132,
      posterW: 116,
      children: [
        const SizedBox(height: 20),
        px(
          Tap(
            onTap: () => s.toggleWatchlist(t.id),
            toggled: inList,
            label: inList ? 'In your watchlist' : 'Add to watchlist',
            child: AnimatedContainer(
              duration: ms(context, 250),
              height: 52,
              decoration: BoxDecoration(
                color: inList ? c.card : c.accent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: inList ? c.accentInk : c.edge),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  inList
                      ? Entrance(
                          key: const ValueKey('in'),
                          fx: Fx.pop,
                          duration: 500,
                          child: Ic(I.bookmark, size: 20, fill: true, color: c.accentInk),
                        )
                      : Ic(I.bookmark, size: 20, color: c.onAccent),
                  const SizedBox(width: 8),
                  Text(
                    inList ? 'In your watchlist' : 'Add to watchlist',
                    style: ts(15, w: FontWeight.w600, color: inList ? c.accentInk : c.onAccent),
                  ),
                ],
              ),
            ),
          ),
        ),
        const H2('Watch status', top: 24, bottom: 10),
        px(Segmented(labels: [for (final x in seg) x.$2], index: segIdx < 0 ? null : segIdx, onTap: (i) => s.setStatus(t.id, seg[i].$1))),
        const H2('Your rating', top: 24, bottom: 6),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              for (var n = 1; n <= 5; n++)
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Tap(
                    label: n == 1 ? '1 star' : '$n stars',
                    selected: n <= mine,
                    onTap: () => s.setRating(t.id, n),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Ic(I.star, size: 28, stroke: 1.6, fill: n <= mine, color: n <= mine ? c.accentInk : c.sub),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const H2('Synopsis', top: 22, bottom: 8),
        px(Text(t.syn, style: ts(15, height: 1.55, color: c.sub))),
        const H2('Cast and crew', top: 24),
        HRow(
          children: [
            for (final p in crew)
              SizedBox(
                width: 84,
                child: Column(
                  children: [
                    Avatar(p.$1, color: p.$3),
                    const SizedBox(height: 8),
                    Text(
                      p.$1,
                      textAlign: TextAlign.center,
                      style: ts(13, w: FontWeight.w600, height: 1.25),
                    ),
                    const SizedBox(height: 2),
                    Text(p.$2, style: ts(12, color: c.sub)),
                  ],
                ),
              ),
          ],
        ),
        const H2('Similar'),
        HRow(
          children: [
            for (final m in titles.where((x) => x.isMovie && x.id != t.id).take(5))
              PosterCard(m, width: 112, onTap: () => openTitle(context, m.id), caption: '${m.r.toStringAsFixed(1)} · ${m.year}'),
          ],
        ),
      ],
    );
  }
}

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key, required this.show});
  final Show show;
  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  late int season = AppScope.of(context).nextEp(widget.show)?.s ?? 1;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final t = widget.show;
    final total = t.totalEps;
    final done = s.watchedCount(t);
    final nx = s.nextEp(t);
    final n = t.seasons.length;

    return _DetailScaffold(
      show: t,
      meta: '${t.year} · $n ${n == 1 ? 'season' : 'seasons'} · ${t.genre}',
      backdrop: 300,
      overlap: 118,
      posterW: 104,
      children: [
        const SizedBox(height: 18),
        px(Text(t.syn, style: ts(15, height: 1.55, color: c.sub))),
        const SizedBox(height: 20),
        px(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDeco(c, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Your progress', style: ts(15, w: FontWeight.w600)),
                    ),
                    Text('${(done / total * 100).round()}%', style: ts(15, w: FontWeight.w700, tab: true)),
                  ],
                ),
                const SizedBox(height: 10),
                Bar(value: done / total),
                const SizedBox(height: 8),
                Text('$done of $total episodes watched${nx != null ? ' · next is S${nx.s} E${nx.e}' : ' · all caught up'}', style: ts(13, color: c.sub)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text('Episodes', style: ts(17, w: FontWeight.w600)),
                ),
              ),
              Tap(
                onTap: () => s.markSeason(t.id, season),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.line),
                  ),
                  child: Row(
                    children: [
                      Ic(I.check, size: 18, stroke: 2.2, color: c.accentInk),
                      const SizedBox(width: 6),
                      Text(
                        'Mark season watched',
                        style: ts(14, w: FontWeight.w600, color: c.accentInk),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        PillRow(
          children: [for (var i = 1; i <= n; i++) Pill('Season $i', on: i == season, onTap: () => setState(() => season = i))],
        ),
        const SizedBox(height: 8),
        Entrance(
          key: ValueKey(season),
          fx: Fx.slideL,
          duration: 340,
          child: px(
            Column(
              children: [for (var e = 1; e <= t.seasons[season - 1]; e++) _EpisodeRow(show: t, season: season, ep: e)],
            ),
          ),
        ),
      ],
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({required this.show, required this.season, required this.ep});
  final Show show;
  final int season, ep;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final w = s.isWatched(show.id, season, ep);
    final title = epTitle(show, season, ep);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        children: [
          ArtBox(
            Art(show.h + ep * 23 + season * 40, (ep + season) % 4),
            radius: 10,
            width: 104,
            height: 58,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 0, 5),
                child: Text(
                  'E$ep',
                  style: ts(12, w: FontWeight.w700, color: Colors.white).copyWith(
                    shadows: const [Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1))],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(15, w: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text('S$season · E$ep · ${epMin(show, season, ep)} min', style: ts(13, color: c.sub)),
              ],
            ),
          ),
          Tap(
            label: '${w ? 'Mark as unwatched' : 'Mark as watched'}: $title',
            toggled: w,
            onTap: () => s.toggleEp(show.id, season, ep),
            child: AnimatedContainer(
              duration: ms(context, 250),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: w ? c.accent : Colors.transparent,
                border: Border.all(color: w ? Colors.transparent : c.line, width: 1.5),
              ),
              alignment: Alignment.center,
              child: w ? DrawCheck(color: c.onAccent) : Ic(I.plus, size: 20, color: c.sub),
            ),
          ),
        ],
      ),
    );
  }
}
