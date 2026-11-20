import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../shell.dart';
import '../state.dart';
import '../theme.dart';
import '../ui/kit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initial = ''});
  final String initial;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _q = TextEditingController(text: widget.initial);

  static const _trending = ['Kiln', 'Harbor Lights', 'Sci-Fi', 'Quiet Orbit', 'Thriller'];

  @override
  void initState() {
    super.initState();
    _q.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _use(String v) => _q.value = TextEditingValue(
    text: v,
    selection: TextSelection.collapsed(offset: v.length),
  );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final q = _q.text.trim().toLowerCase();

    bool hit(Show t) => t.title.toLowerCase().contains(q) || t.genre.toLowerCase().contains(q);
    final movies = q.isEmpty ? <Show>[] : titles.where((t) => t.isMovie && hit(t)).toList();
    final tv = q.isEmpty ? <Show>[] : titles.where((t) => !t.isMovie && hit(t)).toList();
    final ppl = q.isEmpty ? <String>[] : people.keys.where((id) => people[id]!.toLowerCase().contains(q)).toList();
    final sugg = q.isEmpty ? <Show>[] : titles.where((t) => t.title.toLowerCase().startsWith(q)).take(3).toList();

    Widget results(List<Show> list, bool showKind) => Entrance(
      key: ValueKey('$q$showKind'),
      child: Column(
        children: [
          for (final t in list)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TitleRow(
                t,
                line2: showKind ? '${t.kindLabel} · ${t.genre} · ${t.year}' : '${t.genre} · ${t.year}',
                onTap: () => openTitle(context, t.id),
                trailing: Rating(t.r.toStringAsFixed(1)),
              ),
            ),
        ],
      ),
    );

    return ListView(
      padding: EdgeInsets.only(top: top + 16, bottom: 32),
      children: [
        px(
          Row(
            children: [
              IconBtn(I.back, label: 'Back', plain: true, onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(width: 8),
              Expanded(
                child: Entrance(
                  fx: Fx.expand,
                  duration: 360,
                  child: SearchField(
                    controller: _q,
                    hint: 'Search movies, series, people',
                    height: 52,
                    radius: 18,
                    fontSize: 17,
                    autofocus: widget.initial.isEmpty,
                    trailing: q.isEmpty
                        ? null
                        : Entrance(
                            fx: Fx.pop,
                            child: IconBtn(I.x, label: 'Clear search', plain: true, size: 20, onTap: _q.clear),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (q.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text('Recent searches', style: ts(17, w: FontWeight.w600)),
                  ),
                ),
                Tap(
                  press: false,
                  onTap: s.clearRecents,
                  child: SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        'Clear all',
                        style: ts(14, w: FontWeight.w600, color: c.accentInk),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          px(
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in s.recents)
                  Container(
                    height: 44,
                    decoration: cardDeco(c, 22),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tap(
                          press: false,
                          onTap: () => _use(r),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
                            child: Center(
                              child: Text(r, style: ts(14, w: FontWeight.w500)),
                            ),
                          ),
                        ),
                        Tap(
                          label: 'Remove $r',
                          onTap: () => s.removeRecent(r),
                          child: SizedBox(
                            width: 40,
                            height: 44,
                            child: Center(child: Ic(I.x, size: 16, stroke: 2, color: c.sub)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const H2('Trending searches', top: 24, bottom: 8),
          for (final (i, r) in _trending.indexed)
            px(
              Tap(
                press: false,
                onTap: () => _use(r),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: c.line)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '${i + 1}',
                          style: ts(15, w: FontWeight.w700, color: c.accentInk),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(r, style: ts(15, w: FontWeight.w500)),
                      ),
                      Ic(I.trend, size: 18, color: c.sub),
                    ],
                  ),
                ),
              ),
            ),
        ] else ...[
          if (sugg.isNotEmpty) ...[
            const SizedBox(height: 18),
            PillRow(children: [for (final t in sugg) Pill(t.title, on: false, padH: 16, onTap: () => _use(t.title))]),
          ],
          if (movies.isNotEmpty) ...[const H2('Movies', top: 22, bottom: 8), results(movies, false)],
          if (tv.isNotEmpty) ...[const H2('TV shows', top: 22, bottom: 8), results(tv, true)],
          if (ppl.isNotEmpty) ...[
            const H2('People', top: 22, bottom: 8),
            for (final (i, id) in ppl.indexed)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: cardDeco(c, 18),
                  child: Row(
                    children: [
                      Avatar(people[id]!, color: hsl(i * 60 + 210, 35, 32), size: 48),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(people[id]!, style: ts(15, w: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('Actor · ${titles.where((t) => t.cast.contains(id)).length} titles', style: ts(13, color: c.sub)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (movies.isEmpty && tv.isEmpty && ppl.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 56),
              child: Column(
                children: [
                  Entrance(
                    fx: Fx.drop,
                    duration: 600,
                    child: CustomPaint(size: const Size.square(120), painter: _NoResults(c.sub, c.accentInk)),
                  ),
                  const SizedBox(height: 16),
                  Text('No matches', style: ts(20, w: FontWeight.w700, ls: -.02)),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Text(
                      'Nothing matched that search. Check the spelling or try a genre.',
                      textAlign: TextAlign.center,
                      style: ts(14, height: 1.5, color: c.sub),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// Magnifier with a small frown.
class _NoResults extends CustomPainter {
  _NoResults(this.line, this.accent);
  final Color line, accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    Paint p(Color col, double w) => Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * s
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(54 * s, 54 * s), 26 * s, p(line, 4));
    canvas.drawLine(Offset(74 * s, 74 * s), Offset(96 * s, 96 * s), p(line, 6));
    canvas.drawPath(
      Path()
        ..moveTo(44 * s, 60 * s)
        ..quadraticBezierTo(54 * s, 51 * s, 64 * s, 60 * s),
      p(accent, 4),
    );
  }

  @override
  bool shouldRepaint(_NoResults o) => o.line != line || o.accent != accent;
}
