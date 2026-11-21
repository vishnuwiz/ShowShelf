import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../theme.dart';
import 'art.dart';

/// Inline stroke icons (24 grid). No emoji, no text glyphs.
abstract final class I {
  static const mail = '<rect x="3.5" y="5.5" width="17" height="13" rx="3"/><path d="m4.5 7.5 7.5 5.5 7.5-5.5"/>';
  static const eye = '<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12Z"/><circle cx="12" cy="12" r="3"/>';
  static const eyeOff =
      '<path d="M4 4l16 16M10.3 6A9.6 9.6 0 0 1 12 5.5c6 0 9.5 6.5 9.5 6.5a16 16 0 0 1-3 3.8M6.5 7.7A15.5 15.5 0 0 0 2.5 12S6 18.5 12 18.5a9.3 9.3 0 0 0 3.5-.7"/><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"/>';
  static const alert = '<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5v5.5M12 16.2h.01"/>';
  static const logout = '<path d="M10 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h4M15 8l4 4-4 4M19 12H9"/>';
  static const home = '<path d="M4 11.5 12 5l8 6.5V20h-5v-5.5H9V20H4z"/>';
  static const compass = '<circle cx="12" cy="12" r="8.5"/><path d="m15.5 8.5-2 5-5 2 2-5z"/>';
  static const library = '<path d="M5 4h4v16H5zM11 4h4v16h-4z"/><path d="m17 5.5 3.5.9-3.4 13.6-3.5-.9z"/>';
  static const calendar = '<rect x="4" y="5.5" width="16" height="14.5" rx="3"/><path d="M4 10h16M8.5 3.5v4M15.5 3.5v4"/>';
  static const user = '<circle cx="12" cy="8.5" r="3.5"/><path d="M5 20c.8-3.6 3.6-5.5 7-5.5s6.2 1.9 7 5.5"/>';
  static const search = '<circle cx="11" cy="11" r="6.5"/><path d="m16 16 4 4"/>';
  static const bell = '<path d="M6 16v-5a6 6 0 0 1 12 0v5l1.5 2h-15zM10 21h4"/>';
  static const check = '<path d="M5 12.5l4.5 4.5L19 7"/>';
  static const bookmark = '<path d="M7 4h10v16l-5-3.5L7 20z"/>';
  static const star = '<path d="m12 4 2.5 5.2 5.7.8-4.1 4 1 5.7L12 17l-5.1 2.7 1-5.7-4.1-4 5.7-.8z"/>';
  static const plus = '<path d="M12 5v14M5 12h14"/>';
  static const back = '<path d="m15 5-7 7 7 7"/>';
  static const chevR = '<path d="m9 5 7 7-7 7"/>';
  static const x = '<path d="m6 6 12 12M18 6 6 18"/>';
  static const sliders = '<path d="M4 8h9m4 0h3M4 16h3m4 0h9M15 6v4M9 14v4"/>';
  static const list = '<path d="M9 6h11M9 12h11M9 18h11M4.5 6h.01M4.5 12h.01M4.5 18h.01"/>';
  static const grid =
      '<rect x="4" y="4" width="7" height="7" rx="1.5"/><rect x="13" y="4" width="7" height="7" rx="1.5"/><rect x="4" y="13" width="7" height="7" rx="1.5"/><rect x="13" y="13" width="7" height="7" rx="1.5"/>';
  static const trend = '<path d="M4 16l5-5 4 4 7-8m0 0h-5m5 0v5"/>';
  static const moon = '<path d="M20.2 14.6A8.4 8.4 0 0 1 9.4 3.8a8.4 8.4 0 1 0 10.8 10.8Z"/>';
  static const sun =
      '<circle cx="12" cy="12" r="4.2"/><path d="M12 2.5v2.3M12 19.2v2.3M2.5 12h2.3M19.2 12h2.3M5.3 5.3l1.6 1.6M17.1 17.1l1.6 1.6M18.7 5.3l-1.6 1.6M6.9 17.1l-1.6 1.6"/>';
}

class Ic extends StatelessWidget {
  const Ic(this.body, {super.key, this.size = 22, this.color, this.stroke = 1.8, this.fill = false});
  final String body;
  final double size, stroke;
  final Color? color;
  final bool fill;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="${fill ? '#000' : 'none'}" stroke="#000" '
    'stroke-width="$stroke" stroke-linecap="round" stroke-linejoin="round">$body</svg>',
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color ?? DefaultTextStyle.of(context).style.color!, BlendMode.srcIn),
  );
}

/// Tappable with a springy press scale. Pass [label] for icon-only targets.
class Tap extends StatefulWidget {
  const Tap({super.key, required this.child, this.onTap, this.label, this.selected, this.toggled, this.press = true});
  final Widget child;
  final VoidCallback? onTap;
  final String? label;
  final bool? selected, toggled;
  final bool press;

  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool _down = false;
  void _d(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) => Semantics(
    button: widget.toggled == null,
    label: widget.label,
    selected: widget.selected,
    toggled: widget.toggled,
    excludeSemantics: widget.label != null,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.press ? (_) => _d(true) : null,
      onTapUp: widget.press ? (_) => _d(false) : null,
      onTapCancel: widget.press ? () => _d(false) : null,
      child: AnimatedScale(scale: _down ? .95 : 1, duration: ms(context, 220), curve: kSpring, child: widget.child),
    ),
  );
}

BoxDecoration cardDeco(Ss c, double r, {Color? color}) => BoxDecoration(
  color: color ?? c.card,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: c.cardEdge),
);

/// 44x44 icon button on a card surface.
class IconBtn extends StatelessWidget {
  const IconBtn(this.icon, {super.key, required this.label, required this.onTap, this.size = 22, this.badge = false, this.plain = false});
  final String icon, label;
  final VoidCallback onTap;
  final double size;
  final bool badge, plain;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    return Tap(
      label: label,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: plain ? null : cardDeco(c, 14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Ic(icon, size: size, color: c.text, stroke: icon == I.back || icon == I.chevR ? 2 : 1.8),
            if (badge)
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.accentInk,
                    border: Border.all(color: c.card, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Filter / season chip.
class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, required this.on, required this.onTap, this.padH = 18});
  final String label;
  final bool on;
  final VoidCallback onTap;
  final double padH;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    return Tap(
      selected: on,
      onTap: onTap,
      child: AnimatedContainer(
        duration: ms(context, 250),
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: padH),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? c.accent : c.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: on ? c.edge : c.cardEdge),
        ),
        child: Text(
          label,
          style: ts(14, w: FontWeight.w600, color: on ? c.onAccent : c.text),
        ),
      ),
    );
  }
}

class PillRow extends StatelessWidget {
  const PillRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [for (final w in children) Padding(padding: const EdgeInsets.only(right: 8), child: w)],
    ),
  );
}

/// 48x28 switch with an overshooting knob.
class SsSwitch extends StatelessWidget {
  const SsSwitch({super.key, required this.on, required this.onTap, required this.label});
  final bool on;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    return Tap(
      label: label,
      toggled: on,
      press: false,
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 44,
        child: Center(
          child: AnimatedContainer(
            duration: ms(context, 250),
            width: 48,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: on ? c.accent : c.line,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: on ? c.edge : Colors.transparent),
            ),
            child: AnimatedAlign(
              duration: ms(context, 300),
              curve: kSpring,
              alignment: on ? Alignment.centerRight : Alignment.centerLeft,
              child: AnimatedContainer(
                duration: ms(context, 250),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? c.onAccent : c.sub,
                  boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1))],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented control with a sliding lime thumb. [index] null = nothing selected.
class Segmented extends StatelessWidget {
  const Segmented({super.key, required this.labels, required this.index, required this.onTap, this.icons, this.track, this.radius = 16});
  final List<String> labels;
  final List<String>? icons;
  final int? index;
  final ValueChanged<int> onTap;
  final Color? track;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final n = labels.length;
    final i = index ?? 0;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: track != null ? BoxDecoration(color: track, borderRadius: BorderRadius.circular(radius - 2)) : cardDeco(c, radius),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              duration: ms(context, 400),
              curve: kSpringSoft,
              alignment: Alignment(n == 1 ? 0 : -1 + 2 * i / (n - 1), 0),
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                child: AnimatedOpacity(
                  duration: ms(context, 200),
                  opacity: index == null ? 0 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(radius - 4),
                      border: Border.all(color: c.edge),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var k = 0; k < n; k++)
                Expanded(
                  child: Tap(
                    press: false,
                    selected: k == index,
                    onTap: () => onTap(k),
                    child: SizedBox(
                      height: 44,
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(end: k == index ? c.onAccent : c.text),
                        duration: ms(context, 250),
                        builder: (context, col, _) => Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                children: [
                                  if (icons != null) ...[Ic(icons![k], size: 18, stroke: 1.9, color: col), const SizedBox(width: 8)],
                                  Text(
                                    labels[k],
                                    style: ts(14, w: FontWeight.w600, color: col),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum Fx { rise, pop, drop, slideL, slideR, expand }

/// One-shot entrance animation, played when the widget is first built.
/// Give it a new key to replay.
class Entrance extends StatelessWidget {
  const Entrance({super.key, required this.child, this.fx = Fx.rise, this.delay = 0, this.duration = 380});
  final Widget child;
  final Fx fx;
  final int delay, duration;

  @override
  Widget build(BuildContext context) {
    final total = delay + duration;
    final d = ms(context, total);
    if (d == Duration.zero) return child;
    final start = delay / total;
    final curve = Interval(start, 1, curve: fx == Fx.pop || fx == Fx.drop ? kSpring : kEase);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: d,
      child: child,
      builder: (context, t, child) {
        final v = curve.transform(t);
        final op = Interval(start, math.min(1, start + .5 * (1 - start))).transform(t);
        return switch (fx) {
          Fx.rise => Opacity(
            opacity: op,
            child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
          ),
          Fx.slideL => Opacity(
            opacity: op,
            child: Transform.translate(offset: Offset(28 * (1 - v), 0), child: child),
          ),
          Fx.slideR => Opacity(
            opacity: op,
            child: Transform.translate(offset: Offset(-28 * (1 - v), 0), child: child),
          ),
          Fx.pop => Opacity(
            opacity: op,
            child: Transform.scale(scale: .4 + .6 * v, child: child),
          ),
          Fx.drop => Opacity(
            opacity: op,
            child: Transform.translate(offset: Offset(0, -34 * (1 - v)), child: child),
          ),
          Fx.expand => Opacity(
            opacity: op,
            child: Transform.scale(scaleX: .88 + .12 * v, alignment: Alignment.centerLeft, child: child),
          ),
        };
      },
    );
  }
}

/// Check mark that draws itself in.
class DrawCheck extends StatelessWidget {
  const DrawCheck({super.key, this.size = 22, required this.color, this.stroke = 2.6});
  final double size, stroke;
  final Color color;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: ms(context, 480),
    curve: const Interval(.2, 1, curve: Curves.easeOut),
    builder: (_, t, _) => CustomPaint(size: Size.square(size), painter: _CheckPainter(t, color, stroke)),
  );
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t, this.color, this.stroke);
  final double t, stroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = Path()
      ..moveTo(5 * s, 12.5 * s)
      ..lineTo(9.5 * s, 17 * s)
      ..lineTo(19 * s, 7 * s);
    final m = p.computeMetrics().first;
    canvas.drawPath(
      m.extractPath(0, m.length * t),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter o) => o.t != t || o.color != color;
}

/// Skeleton placeholder.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.width, required this.height, this.radius = 12});
  final double? width;
  final double height, radius;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final still = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final x = still ? 0.0 : -1 + 3 * _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(begin: Alignment(x - 1, -.3), end: Alignment(x + 1, .3), colors: [c.card, c.line, c.card], stops: const [.3, .5, .7]),
          ),
        );
      },
    );
  }
}

/// Horizontal bar that animates its fill with scaleX.
class Bar extends StatelessWidget {
  const Bar({super.key, required this.value, this.height = 8, this.color, this.track, this.duration = 700, this.fromZero = false, this.radius});
  final double value, height;
  final Color? color, track;
  final int duration;
  final bool fromZero;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final r = BorderRadius.circular(radius ?? height / 2);
    return ClipRRect(
      borderRadius: r,
      child: Container(
        width: double.infinity,
        height: height,
        color: track ?? c.line,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: fromZero ? 0 : value, end: value),
          duration: ms(context, duration),
          curve: kEase,
          builder: (_, v, _) => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: v.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(color: color ?? c.accentInk, borderRadius: r),
            ),
          ),
        ),
      ),
    );
  }
}

class H1 extends StatelessWidget {
  const H1(this.text, {super.key, this.size = 30});
  final String text;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: ts(size, w: FontWeight.w700, ls: -.03, height: 1.12)),
  );
}

class H2 extends StatelessWidget {
  const H2(this.text, {super.key, this.top = 26, this.bottom = 12});
  final String text;
  final double top, bottom;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, top, 20, bottom),
    child: Semantics(
      header: true,
      child: Text(text, style: ts(17, w: FontWeight.w600, ls: -.01)),
    ),
  );
}

/// Horizontal scroller that bleeds to the screen edges.
class HRow extends StatelessWidget {
  const HRow({super.key, required this.children, this.gap = 12});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(width: gap), children[i]],
      ],
    ),
  );
}

/// Page padding for non-bleeding content.
Widget px(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);

/// Poster plus title and one caption line.
class PosterCard extends StatelessWidget {
  const PosterCard(this.show, {super.key, required this.width, required this.onTap, required this.caption, this.radius = 12, this.star, this.pop = false});
  final Show show;
  final double width, radius;
  final VoidCallback onTap;
  final String caption;
  final Color? star; // star colour; null = no star
  final bool pop;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final poster = Poster(show, width: width, radius: radius);
    return Tap(
      label: 'Open ${show.title}',
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pop ? Entrance(fx: Fx.pop, child: poster) : poster,
            const SizedBox(height: 8),
            Text(
              show.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ts(width > 140 ? 14 : 13, w: FontWeight.w600),
            ),
            const SizedBox(height: 1),
            Row(
              children: [
                if (star != null) ...[Ic(I.star, size: 12, fill: true, stroke: 0, color: star), const SizedBox(width: 4)],
                Flexible(
                  child: Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(12, color: c.sub),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card row with thumbnail, two lines and a trailing widget.
class TitleRow extends StatelessWidget {
  const TitleRow(this.show, {super.key, required this.line2, this.line3, required this.onTap, this.trailing, this.leading, this.thumb = 44});
  final Show show;
  final String line2;
  final String? line3;
  final VoidCallback onTap;
  final Widget? trailing, leading;
  final double thumb;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: cardDeco(c, 18),
      child: Row(
        children: [
          Expanded(
            child: Tap(
              onTap: onTap,
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  PosterThumb(show, width: thumb),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          show.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts(15, w: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(line2, style: ts(13, color: c.sub)),
                        if (line3 != null) ...[const SizedBox(height: 1), Text(line3!, style: ts(13, color: c.sub))],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class Rating extends StatelessWidget {
  const Rating(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Ic(I.star, size: 14, fill: true, stroke: 0, color: Ss.of(context).accentInk),
      const SizedBox(width: 4),
      Text(text, style: ts(14, w: FontWeight.w600)),
    ],
  );
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, required this.color, this.size = 64});
  final String name;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: Text(
      initials(name),
      style: ts(size * .31, w: FontWeight.w700, color: Colors.white),
    ),
  );
}

/// Text field on a card surface with a lime focus ring.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.height = 48,
    this.radius = 16,
    this.fontSize = 15,
    this.autofocus = false,
    this.trailing,
  });
  final TextEditingController controller;
  final String hint;
  final double height, radius, fontSize;
  final bool autofocus;
  final Widget? trailing;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final f = _focus.hasFocus;
    return AnimatedContainer(
      duration: ms(context, 250),
      height: widget.height,
      padding: EdgeInsets.only(left: 14, right: widget.trailing == null ? 14 : 4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: f ? c.accentInk : c.cardEdge),
        boxShadow: [BoxShadow(color: f ? c.accentInk.withValues(alpha: .22) : Colors.transparent, spreadRadius: 3)],
      ),
      child: Row(
        children: [
          Ic(I.search, size: widget.height > 50 ? 22 : 20, color: c.sub),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              style: ts(widget.fontSize, color: c.text),
              decoration: InputDecoration.collapsed(
                hintText: widget.hint,
                hintStyle: ts(widget.fontSize, color: c.sub),
              ),
            ),
          ),
          ?widget.trailing,
        ],
      ),
    );
  }
}

/// Full-width 52px button: lime when primary, outlined when secondary.
class SsButton extends StatelessWidget {
  const SsButton({super.key, required this.label, required this.onTap, this.busy = false, this.secondary = false});
  final String label;
  final VoidCallback onTap;
  final bool busy, secondary;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final fg = secondary ? c.text : c.onAccent;
    return Tap(
      label: label,
      onTap: busy ? null : onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: secondary ? Colors.transparent : c.accent,
          borderRadius: BorderRadius.circular(16),
          border: secondary ? Border.all(color: c.isDark ? c.line : c.edge) : null,
        ),
        child: busy
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
              )
            : Text(label, style: ts(16, w: FontWeight.w700, color: fg)),
      ),
    );
  }
}
