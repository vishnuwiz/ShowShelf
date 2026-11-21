import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../shell.dart';
import '../state.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'account.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  // One clock drives the count-up (0-900ms) and the staggered bars.
  late final _clock = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  int bar = 9; // selected month (October)

  static const _months = [18, 22, 31, 27, 35, 29, 41, 38, 33, 44, 36, 24];
  static const _m = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
  static const _years = [('2024', 301), ('2025', 466), ('2026', 412)];
  static const _genres = [('Drama', 34), ('Sci-Fi', 24), ('Thriller', 18), ('Mystery', 12), ('Anime', 12)];
  static const _actors = [('mira', 9), ('jonas', 7), ('tamsin', 6), ('ravi', 5)];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_clock.status == AnimationStatus.dismissed) {
      MediaQuery.of(context).disableAnimations ? _clock.value = 1 : _clock.forward();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  /// Progress of a segment of the clock, in ms.
  double _seg(int start, int dur, [Curve curve = kEase]) => curve.transform(((_clock.value * 1400 - start) / dur).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return AnimatedBuilder(
      animation: _clock,
      builder: (context, _) {
        final k = _seg(0, 900, Curves.easeOutCubic);
        final stats = [
          ('${(128 * k).round()}', 'Movies watched'),
          ('${(31 * k).round()}', 'Series completed'),
          (_thousands((1284 * k).round()), 'Episodes watched'),
          ('${_thousands((1179 * k).round())} h', 'Total watch time'),
        ];
        return ListView(
          padding: EdgeInsets.only(top: top + 20, bottom: 32),
          children: [
            px(
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: hsl(262, 40, 38)),
                    child: Text(
                      'M',
                      style: ts(28, w: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const H1('Maya Rao', size: 26),
                        const SizedBox(height: 2),
                        Text('@mayawatches · joined 2023', style: ts(14, color: c.sub)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (var r = 0; r < 2; r++)
              Padding(
                padding: EdgeInsets.fromLTRB(20, r * 10, 20, 0),
                child: Row(
                  children: [
                    for (var k2 = 0; k2 < 2; k2++) ...[
                      if (k2 > 0) const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: cardDeco(c, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(stats[r * 2 + k2].$1, style: ts(30, w: FontWeight.w700, ls: -.03, height: 1, tab: true)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stats[r * 2 + k2].$2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ts(13, w: FontWeight.w500, color: c.sub),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const H2('Monthly activity', bottom: 4),
            px(
              Semantics(
                liveRegion: true,
                child: Text('${monthNames[bar]} 2026 · ${_months[bar]} hours watched', style: ts(13, color: c.sub)),
              ),
            ),
            const SizedBox(height: 12),
            px(
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 12; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: Tap(
                          press: false,
                          selected: i == bar,
                          label: '${monthNames[i]}, ${_months[i]} hours',
                          onTap: () => setState(() => bar = i),
                          child: Column(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: (.02 + (_months[i] / 44 - .02) * _seg(100 + i * 40, 700)).clamp(.02, 1),
                                    child: AnimatedContainer(
                                      duration: ms(context, 250),
                                      decoration: BoxDecoration(
                                        color: i == bar ? c.accentInk : c.line,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6), bottom: Radius.circular(3)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _m[i],
                                style: ts(11, w: FontWeight.w600, color: c.sub, height: 1),
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const H2('Year by year'),
            for (final y in _years)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(y.$1, style: ts(14, w: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Bar(value: y.$2 / 480 * _seg(100, 900), height: 10, duration: 0)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 58,
                      child: Text(
                        '${y.$2} h',
                        textAlign: TextAlign.right,
                        style: ts(14, color: c.sub, tab: true),
                      ),
                    ),
                  ],
                ),
              ),
            const H2('Favourite genres', top: 14),
            for (final (i, g) in _genres.indexed)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(g.$1, style: ts(14, w: FontWeight.w500)),
                        ),
                        Text(
                          '${g.$2}%',
                          style: ts(14, w: FontWeight.w500, color: c.sub, tab: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Bar(value: g.$2 / 34 * _seg(100 + i * 60, 900), duration: 0),
                  ],
                ),
              ),
            const H2('Most-watched actors', top: 14),
            HRow(
              children: [
                for (final (i, a) in _actors.indexed)
                  SizedBox(
                    width: 92,
                    child: Column(
                      children: [
                        Avatar(people[a.$1]!, color: hsl(i * 70 + 200, 35, 32)),
                        const SizedBox(height: 8),
                        Text(
                          people[a.$1]!,
                          textAlign: TextAlign.center,
                          style: ts(13, w: FontWeight.w600, height: 1.25),
                        ),
                        const SizedBox(height: 2),
                        Text('${a.$2} titles', style: ts(12, color: c.sub)),
                      ],
                    ),
                  ),
              ],
            ),
            const H2('Recently completed'),
            HRow(
              children: [
                for (final id in ['quiet', 'neon', 'fieldwork', 'ninth'])
                  PosterCard(byId(id), width: 104, onTap: () => openTitle(context, id), caption: '${s.ratings[id] ?? '–'} of 5', star: c.accentInk),
              ],
            ),
            const AccountSection(),
            const H2('Settings'),
            px(
              Container(
                padding: const EdgeInsets.all(16),
                decoration: cardDeco(c, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Appearance', style: ts(15, w: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Segmented(
                      labels: const ['Dark', 'Light'],
                      icons: const [I.moon, I.sun],
                      index: s.dark ? 0 : 1,
                      track: c.bg,
                      radius: 14,
                      onTap: (i) => s.setDark(i == 0),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Preview new-user shelf', style: ts(15, w: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('Shows the empty Library state.', style: ts(13, color: c.sub)),
                            ],
                          ),
                        ),
                        SsSwitch(on: s.newUser, label: 'Preview new-user shelf', onTap: s.toggleNewUser),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _thousands(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
