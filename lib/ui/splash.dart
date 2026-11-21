import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'brand_mark.dart';

// Timeline, in seconds. Mirrors the "Neon Filmstrip Reveal" animation:
// play button glows, the film ribbon winds round it into an S, the wordmark
// resolves out of a blur, then neon arcs sweep the corners.
const _tGlow = .0; // play button glow pulses in
const _tTop = .30, _tBottom = .52; // the two ribbons wind in
const _tSettle = 1.45; // neon fades, ribbon goes solid
const _tWord = 1.25;
const _tTag = 1.65;
const _tArcs = 1.85;
const _total = 2.7;
const _hold = Duration(milliseconds: 250);
const _fade = Duration(milliseconds: 350);

/// Mark width in dp. The native launch screens draw the play triangle for this
/// same box (tool/generate_platform_icons.py), so the hand-off does not jump.
const _markWidth = 112.0;
const _bg = kCharcoal;

double _clamp01(double x) => x.clamp(0.0, 1.0).toDouble();

double _easeOut(double x) {
  final v = _clamp01(x);
  return 1 - math.pow(1 - v, 3).toDouble();
}

double _easeInOut(double x) {
  final v = _clamp01(x);
  return v < .5 ? 4 * v * v * v : 1 - math.pow(-2 * v + 2, 3).toDouble() / 2;
}

/// Shows the animated ShowShelf splash on first launch, then reveals [child].
///
/// [child] is only built once the animation finishes, so its own entrance
/// animations play as the splash fades away. Tap to skip.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.child});
  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_total * 1000).round()),
  );
  Timer? _holdTimer;
  bool _started = false;
  bool _revealed = false; // child is built and the splash is fading out
  bool _gone = false; // fade finished, splash removed

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1; // reduced motion: show the finished lockup, no movement
      _holdTimer = Timer(const Duration(milliseconds: 600), _reveal);
    } else {
      _c.forward().whenComplete(() {
        if (mounted) _holdTimer = Timer(_hold, _reveal);
      });
    }
  }

  void _reveal() {
    _holdTimer?.cancel();
    if (!mounted || _revealed) return;
    setState(() => _revealed = true);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_revealed) KeyedSubtree(key: const ValueKey('app'), child: widget.child),
      if (!_gone)
        IgnorePointer(
          key: const ValueKey('splash'),
          ignoring: _revealed,
          child: AnimatedOpacity(
            opacity: _revealed ? 0 : 1,
            duration: _fade,
            onEnd: () {
              if (_revealed && mounted) setState(() => _gone = true);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _reveal,
              child: _SplashArt(controller: _c),
            ),
          ),
        ),
    ],
  );
}

class _SplashArt extends StatelessWidget {
  const _SplashArt({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Material(
      color: _bg,
      child: Semantics(
        label: 'ShowShelf',
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final t = controller.value * _total;
              final markHeight = _markWidth * kMarkH / kMarkW;
              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // Soft stage light behind the mark, plus the neon corner arcs.
                  CustomPaint(painter: _StagePainter(t)),
                  // The mark stays dead-centre so it lines up with the native launch screen.
                  Center(
                    child: SizedBox(
                      width: _markWidth,
                      height: markHeight,
                      child: CustomPaint(painter: _MarkPainter(t)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, markHeight / 2 + 52),
                      child: _Wordmark(t),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Transform.translate(offset: Offset(0, markHeight / 2 + 92), child: _Tagline(t)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

/// "ShowShelf": white "Show", lime "Shelf", resolving out of a blur like the animation.
class _Wordmark extends StatelessWidget {
  const _Wordmark(this.t);
  final double t;

  static const _style = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 1,
    letterSpacing: -.4,
  );

  @override
  Widget build(BuildContext context) {
    final p = _easeOut((t - _tWord) / .6);
    Widget text = Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(0, (1 - p) * 8),
        child: const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Show', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Shelf', style: TextStyle(color: kLime)),
            ],
            style: _style,
          ),
        ),
      ),
    );
    final sigma = (1 - p) * 9;
    if (sigma > .05) {
      text = ImageFiltered(imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal), child: text);
    }
    return text;
  }
}

/// "MOVIES · SERIES · YOUR LIST"
class _Tagline extends StatelessWidget {
  const _Tagline(this.t);
  final double t;

  @override
  Widget build(BuildContext context) {
    final p = _easeOut((t - _tTag) / .5);
    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(0, (1 - p) * 6),
        child: const Text(
          'MOVIES  ·  SERIES  ·  YOUR LIST',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1,
            letterSpacing: 2.6,
            color: Color(0xFF8E939D),
          ),
        ),
      ),
    );
  }
}

/// The mark. The play button is solid from the first frame (the native launch screen
/// shows it); the two ribbons then wind in around it with a neon glow that settles.
class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.t);
  final double t;

  static final _pad = Rect.fromLTWH(-60, -60, kMarkW + 120, kMarkH + 120);

  /// Draws [path] revealed by a soft wipe. [p] is 0..1 progress; [fromLeft] picks the direction.
  void _ribbon(Canvas canvas, Path path, double p, bool fromLeft, double drop, double neon) {
    if (p <= 0) return;
    final eased = _easeInOut(p);
    const soft = .35;
    final edge = eased * (1 + soft);
    final a = _clamp01(edge - soft), b = _clamp01(edge);
    const opaque = Colors.white;
    const clear = Color(0x00FFFFFF);
    final gradient = LinearGradient(
      begin: fromLeft ? Alignment.centerLeft : Alignment.centerRight,
      end: fromLeft ? Alignment.centerRight : Alignment.centerLeft,
      colors: [opaque, opaque, clear],
      stops: [0, a, b <= a ? a + .001 : b],
    );

    canvas
      ..save()
      ..translate(0, drop * (1 - _easeOut(p)))
      ..saveLayer(_pad, Paint());
    if (neon > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = kLime.withValues(alpha: .6 * neon)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
    }
    // Early on the ribbon is a darker, translucent lime; it fills to solid as the neon settles.
    final solid = _easeOut((t - _tSettle + .5) / .6);
    canvas.drawPath(path, Paint()..color = Color.lerp(const Color(0xFF6F9A22), kLime, solid)!);
    canvas
      ..drawRect(_pad, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, kMarkW, kMarkH))..blendMode = BlendMode.dstIn)
      ..restore()
      ..restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / kMarkW);

    final glowIn = _easeOut((t - _tGlow) / .6);
    final settle = _easeOut((t - _tSettle) / .7);
    final neon = (1 - settle * .75);

    // Play button: solid at t = 0, a neon halo pulses in around it.
    if (glowIn > 0) {
      canvas.drawPath(
        markPlay,
        Paint()
          ..color = kLime.withValues(alpha: .7 * glowIn * neon)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * glowIn),
      );
    }
    canvas.drawPath(markPlay, Paint()..color = kLime);

    _ribbon(canvas, markTop, (t - _tTop) / .85, true, -26, neon * _clamp01((t - _tTop) / .3));
    _ribbon(canvas, markBottom, (t - _tBottom) / .85, false, 26, neon * _clamp01((t - _tBottom) / .3));

    // After it settles, a faint halo stays so the mark reads as neon on the dark stage.
    if (settle > 0) {
      canvas.drawPath(
        buildMarkPath(),
        Paint()
          ..color = kLime.withValues(alpha: .16 * settle)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.t != t;
}

/// Dark stage: a soft light behind the mark and two neon arcs that sweep the opposite corners.
class _StagePainter extends CustomPainter {
  const _StagePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final light = _easeOut(t / 1.4);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [kLime.withValues(alpha: .07 * light), const Color(0x00C6FF4D)],
        ).createShader(Rect.fromCircle(center: centre, radius: size.shortestSide * .75)),
    );

    final p = _easeInOut((t - _tArcs) / .75);
    if (p <= 0) return;
    // A circle that just clips the corners, so each arc hugs one corner of the screen.
    final r = centre.distance * .9;
    final rect = Rect.fromCircle(center: centre, radius: r);
    final toCorner = math.atan2(-size.height, size.width);
    // One arc around the top-right corner, one around the bottom-left.
    for (final base in [toCorner, toCorner + math.pi]) {
      const span = math.pi / 3.2;
      const n = 18;
      for (var i = 0; i < n; i++) {
        final u = (i + .5) / n;
        final shown = _clamp01(p * 1.25 - u * .25);
        final alpha = math.sin(math.pi * u) * shown * (1 - .35 * _clamp01((t - _tArcs - .8) / .5));
        if (alpha <= .01) continue;
        final start = base - span / 2 + span * i / n;
        final seg = span / n + .004;
        canvas
          ..drawArc(
            rect,
            start,
            seg,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 9
              ..color = kLime.withValues(alpha: .22 * alpha)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          )
          ..drawArc(
            rect,
            start,
            seg,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round
              ..color = kLime.withValues(alpha: .9 * alpha),
          );
      }
    }
  }

  @override
  bool shouldRepaint(_StagePainter old) => old.t != t;
}
