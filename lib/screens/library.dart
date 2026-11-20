import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../shell.dart';
import '../state.dart';
import '../theme.dart';
import '../ui/art.dart';
import '../ui/kit.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _q = TextEditingController();

  static const _tabs = [
    ('all', 'All'),
    ('watching', 'Watching'),
    ('completed', 'Completed'),
    ('plan', 'Plan to watch'),
    ('onhold', 'On hold'),
    ('dropped', 'Dropped'),
  ];
  static const _sortLabel = {'recent': 'Recent', 'title': 'A to Z', 'rating': 'Rating'};

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

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final q = _q.text.trim().toLowerCase();

    var items = s.newUser
        ? <Show>[]
        : titles
              .where(
                (t) =>
                    s.status[t.id] != null &&
                    (s.libTab == 'all' || s.status[t.id] == s.libTab) &&
                    (q.isEmpty || t.title.toLowerCase().contains(q) || t.genre.toLowerCase().contains(q)),
              )
              .toList();
    if (s.libSort == 'title') items.sort((a, b) => a.title.compareTo(b.title));
    if (s.libSort == 'rating') {
      items.sort((a, b) {
        final d = (s.ratings[b.id] ?? 0) - (s.ratings[a.id] ?? 0);
        return d != 0 ? d : b.r.compareTo(a.r);
      });
    }

    double progress(Show t) => t.isMovie ? (s.status[t.id] == 'completed' ? 1 : 0) : s.watchedCount(t) / t.totalEps;
    String progText(Show t) => t.isMovie ? (s.status[t.id] == 'completed' ? 'Done' : '–') : '${s.watchedCount(t)}/${t.totalEps}';

    final sort = _sortLabel[s.libSort]!;
    final key = ValueKey('${s.libTab}|${s.libSort}|${s.libGrid}|$q|${s.newUser}');

    return ListView(
      padding: EdgeInsets.only(top: top + 20, bottom: 32),
      children: [
        px(
          Row(
            children: [
              const Expanded(child: H1('Library')),
              Tap(
                label: 'Sort by $sort. Tap to change.',
                onTap: s.cycleSort,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: cardDeco(c, 14),
                  child: Row(
                    children: [
                      Ic(I.sliders, size: 18, color: c.text),
                      const SizedBox(width: 6),
                      Text(sort, style: ts(13, w: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Entrance(
                key: ValueKey(s.libGrid),
                fx: Fx.pop,
                child: IconBtn(s.libGrid ? I.list : I.grid, label: s.libGrid ? 'Switch to list view' : 'Switch to grid view', onTap: s.toggleLibView),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        px(SearchField(controller: _q, hint: 'Search your library')),
        const SizedBox(height: 14),
        PillRow(
          children: [for (final tb in _tabs) Pill(tb.$2, on: s.libTab == tb.$1, padH: 16, onTap: () => s.setLibTab(tb.$1))],
        ),
        if (items.isEmpty)
          _Empty(
            newUser: s.newUser,
            onAction: () {
              if (s.newUser) {
                s.setTab(1);
              } else {
                _q.clear();
                s.setLibTab('all');
              }
            },
          )
        else if (s.libGrid)
          Entrance(
            key: key,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: LayoutBuilder(
                builder: (context, box) {
                  final w = (box.maxWidth - 20) / 3;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 14,
                    children: [
                      for (final t in items)
                        Tap(
                          label: 'Open ${t.title}, ${statusLabel[s.status[t.id]]}',
                          onTap: () => openTitle(context, t.id),
                          child: SizedBox(
                            width: w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Poster(
                                  t,
                                  width: w,
                                  titleBottom: .14,
                                  footer: Bar(value: progress(t), height: 5, radius: 0, color: Ss.dark.accent, track: Colors.white.withValues(alpha: .25)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ts(13, w: FontWeight.w600),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  statusLabel[s.status[t.id]]!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ts(12, color: c.sub),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          )
        else
          Entrance(
            key: key,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  for (final t in items)
                    Tap(
                      onTap: () => openTitle(context, t.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: c.line)),
                        ),
                        child: Row(
                          children: [
                            PosterThumb(t, width: 56),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ts(15, w: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${t.kindLabel} · ${t.genre} · ${statusLabel[s.status[t.id]]}', style: ts(13, color: c.sub)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(child: Bar(value: progress(t), height: 5)),
                                      const SizedBox(width: 8),
                                      Text(progText(t), style: ts(12, color: c.sub)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Rating('${s.ratings[t.id] ?? '–'}'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty shelf: books drop in, staggered.
class _Empty extends StatelessWidget {
  const _Empty({required this.newUser, required this.onAction});
  final bool newUser;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    Widget book(double w, double h, Color fill, int delay, {bool outline = true}) => Entrance(
      fx: Fx.drop,
      delay: delay,
      duration: 600,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(4),
          border: outline ? Border.all(color: c.line, width: 2) : null,
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 78,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Positioned(
                  left: 18,
                  bottom: 6,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      book(22, 58, c.card, 50),
                      const SizedBox(width: 4),
                      book(24, 72, c.accent, 200, outline: false),
                      const SizedBox(width: 4),
                      book(20, 50, c.card, 350),
                      const SizedBox(width: 14),
                      Entrance(
                        fx: Fx.drop,
                        delay: 500,
                        duration: 600,
                        child: Transform.rotate(
                          angle: .19,
                          alignment: Alignment.bottomLeft,
                          child: CustomPaint(size: const Size(21, 58), painter: _DashedRect(c.sub)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 6,
                  decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(newUser ? 'Your shelf is empty' : 'Nothing here yet', style: ts(20, w: FontWeight.w700, ls: -.02)),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              newUser
                  ? 'Add films and series you love, and ShowShelf keeps track of every episode.'
                  : 'No titles match this filter. Try another status or clear the search.',
              textAlign: TextAlign.center,
              style: ts(14, height: 1.5, color: c.sub),
            ),
          ),
          const SizedBox(height: 20),
          Tap(
            onTap: onAction,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.edge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    newUser ? 'Discover something' : 'Clear filters',
                    style: ts(15, w: FontWeight.w600, color: c.onAccent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRect extends CustomPainter {
  _DashedRect(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()..addRect(Offset.zero & size);
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 5), p);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRect o) => o.color != color;
}
