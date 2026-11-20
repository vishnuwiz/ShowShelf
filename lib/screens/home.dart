import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../shell.dart';
import '../state.dart';
import '../theme.dart';
import '../ui/art.dart';
import '../ui/kit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good morning' : (h < 18 ? 'Good afternoon' : 'Good evening');
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final top = MediaQuery.paddingOf(context).top;

    final upNext = releases.where((r) => !r.d.isBefore(today) && r.type != RelType.movie).take(3);

    // Library totals: demo base counts plus whatever changed this session.
    int delta(String st) => s.status.values.where((v) => v == st).length - seedStatus.values.where((v) => v == st).length;
    final libStats = [
      ('Watching', 7 + delta('watching'), 'watching'),
      ('Completed', 142 + delta('completed'), 'completed'),
      ('Watchlist', 23 + delta('plan'), 'plan'),
    ];

    return ListView(
      padding: EdgeInsets.only(top: top + 16, bottom: 32),
      children: [
        px(
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.edge),
                ),
                alignment: Alignment.center,
                child: CustomPaint(size: const Size.square(22), painter: _LogoPainter()),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text('ShowShelf', style: ts(17, w: FontWeight.w700, ls: -.02)),
              ),
              IconBtn(I.search, label: 'Search', onTap: () => openSearch(context)),
              const SizedBox(width: 8),
              IconBtn(I.bell, label: 'Notifications, 2 new', badge: true, onTap: () => s.showToast('2 episodes aired today')),
              const SizedBox(width: 8),
              Tap(
                label: 'Open profile',
                onTap: () => s.setTab(4),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: hsl(262, 40, 38)),
                  child: Text(
                    'M',
                    style: ts(16, w: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        px(Text(_greeting, style: ts(14, color: c.sub))),
        const SizedBox(height: 2),
        px(const H1('Welcome back, Maya', size: 28)),
        const H2('Continue watching', bottom: 12),
        px(s.homeLoading ? const Shimmer(width: null, height: 280, radius: 24) : const _ContinueCard()),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text('Up next', style: ts(17, w: FontWeight.w600, ls: -.01)),
                ),
              ),
              Tap(
                press: false,
                onTap: () => s.setTab(3),
                child: SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      'Calendar',
                      style: ts(14, w: FontWeight.w600, color: c.accentInk),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final r in upNext) Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: _UpNextRow(r)),
        const H2('Your library', top: 18),
        px(
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: ms(context, 900),
            curve: Curves.easeOutCubic,
            builder: (_, k, _) => Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Tap(
                      onTap: () => s.openLibrary(libStats[i].$3),
                      label: '${libStats[i].$2} ${libStats[i].$1}. Open in library',
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: cardDeco(c, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${(libStats[i].$2 * k).round()}', style: ts(28, w: FontWeight.w700, ls: -.03, height: 1, tab: true)),
                            const SizedBox(height: 6),
                            Text(
                              libStats[i].$1,
                              style: ts(13, w: FontWeight.w500, color: c.sub),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const H2('Recently watched', top: 28),
        HRow(
          children: [
            for (final id in ['neon', 'quiet', 'fieldwork', 'ninth'])
              s.homeLoading
                  ? const Shimmer(width: 112, height: 168)
                  : PosterCard(
                      byId(id),
                      width: 112,
                      pop: true,
                      onTap: () => openTitle(context, id),
                      caption: '${s.ratings[id] ?? '–'} · ${byId(id).year}',
                      star: c.sub,
                    ),
          ],
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = Paint()..color = const Color(0xFF101114);
    RRect r(double x, double y, double w, double h, double rad) => RRect.fromLTRBR(x * s, y * s, (x + w) * s, (y + h) * s, Radius.circular(rad * s));
    canvas.drawRRect(r(3.5, 7, 4, 11, 1.2), p);
    canvas.drawRRect(r(9.5, 4, 4, 14, 1.2), p);
    canvas.drawPath(Path()..addPolygon([Offset(15.4 * s, 6.2 * s), Offset(18.9 * s, 5.3 * s), Offset(21.3 * s, 17 * s), Offset(17.8 * s, 17.9 * s)], true), p);
    canvas.drawRRect(r(2.5, 19.3, 19, 1.8, .9), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final t = byId('harbor');
    final nx = s.nextEp(t);

    if (nx == null) {
      return Entrance(
        fx: Fx.pop,
        child: Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: cardDeco(c, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.accent),
                child: const DrawCheck(size: 24, color: Color(0xFF101114)),
              ),
              const SizedBox(height: 12),
              Text('All caught up on Harbor Lights', style: ts(17, w: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('New episodes land on 3 December.', style: ts(14, color: c.sub)),
            ],
          ),
        ),
      );
    }

    final done = s.watchedCount(t) + (s.marking ? 1 : 0);
    final pct = done / t.totalEps;
    final mins = epMin(t, nx.s, nx.e);
    final posText = s.marking ? '$mins of $mins min' : (s.pos > 0 ? '${(s.pos * mins).round()} of $mins min' : 'Not started');

    return SizedBox(
      height: 280,
      child: ArtBox(
        Art.of(t),
        radius: 24,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00101114), Color(0xE6101114)],
                    stops: [.3, 1],
                  ),
                ),
              ),
            ),
            Positioned(top: 14, right: 14, child: _Ring(pct)),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Entrance(
                    key: ValueKey('${nx.s}-${nx.e}'),
                    child: Tap(
                      label: 'Open Harbor Lights, season ${nx.s} episode ${nx.e}',
                      onTap: () => openTitle(context, 'harbor'),
                      press: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Season ${nx.s} · Episode ${nx.e}',
                            style: ts(12, w: FontWeight.w600, color: Colors.white.withValues(alpha: .8)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.title,
                            style: ts(24, w: FontWeight.w700, ls: -.02, height: 1.15, color: Colors.white),
                          ),
                          const SizedBox(height: 1),
                          Text(epTitle(t, nx.s, nx.e), style: ts(14, color: Colors.white.withValues(alpha: .85))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Bar(value: s.marking ? 1 : s.pos, height: 5, duration: 900, color: Ss.dark.accent, track: Colors.white.withValues(alpha: .25)),
                      ),
                      const SizedBox(width: 10),
                      Text(posText, style: ts(12, color: Colors.white.withValues(alpha: .85), tab: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Tap(
                    onTap: s.markHome,
                    child: AnimatedContainer(
                      duration: ms(context, 300),
                      height: 48,
                      decoration: BoxDecoration(color: s.marking ? c.ok : c.accent, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: s.marking
                          ? Entrance(
                              fx: Fx.pop,
                              duration: 500,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DrawCheck(size: 20, color: c.onOk),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Watched',
                                    style: ts(15, w: FontWeight.w600, color: c.onOk),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Ic(I.check, size: 20, stroke: 2.2, color: c.onAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Mark as watched',
                                  style: ts(15, w: FontWeight.w600, color: c.onAccent),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular progress for the whole series.
class _Ring extends StatelessWidget {
  const _Ring(this.value);
  final double value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${(value * 100).round()} percent of Harbor Lights watched',
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: ms(context, 900),
      curve: kEase,
      builder: (_, v, _) => CustomPaint(
        size: const Size.square(52),
        painter: _RingPainter(v),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: Text(
              '${(value * 100).round()}%',
              style: ts(11, w: FontWeight.w700, color: Colors.white, tab: true),
            ),
          ),
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v);
  final double v;

  @override
  void paint(Canvas canvas, Size size) {
    final o = size.center(Offset.zero);
    canvas.drawCircle(o, 21, Paint()..color = const Color(0x99101114));
    canvas.drawCircle(
      o,
      21,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0x47FFFFFF),
    );
    canvas.drawArc(
      Rect.fromCircle(center: o, radius: 21),
      -1.5708,
      6.2832 * v,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Ss.dark.accent,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v;
}

class _UpNextRow extends StatelessWidget {
  const _UpNextRow(this.r);
  final Release r;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final t = byId(r.id);
    final on = s.reminders.contains(r.key);
    return TitleRow(
      t,
      line2: r.label,
      line3: '${fmtDay(r.d)}, ${r.time}',
      onTap: () => openTitle(context, t.id),
      trailing: Tap(
        label: 'Remind me about ${t.title}, ${r.label}',
        toggled: on,
        onTap: () => s.toggleReminder(r.key),
        child: AnimatedContainer(
          duration: ms(context, 250),
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: on ? c.accent : c.bg, borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.center,
          child: Ic(I.bell, fill: on, color: on ? c.onAccent : c.sub),
        ),
      ),
    );
  }
}
