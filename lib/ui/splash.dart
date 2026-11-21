import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

// Brand colours (assets/branding/BRAND.md).
const _lime = Color(0xFFC5FF36);
const _ink = Color(0xFF111111);

// Glyph geometry in the 1024-unit master (assets/branding/showshelf-app-icon.svg).
// The leaning book is stored upright with its foot on the spot where the final,
// rotated book rests, so it can tip over by rotating about that foot.
const _gw = 668.0, _gh = 468.0; // glyph bounding box width, height
const _gcx = 512.0, _gcy = 484.0; // its centre
const _bookBottom = 610.0;
const _footX = 691.9, _footY = 620.8;
const _leanDeg = -12.0;

// Timeline, in seconds.
const _tShelf = .05, _tA = .20, _tB = .30, _tC = .40, _tLean = .85, _tWord = 1.10, _tTag = 1.50;
const _stagger = .04;
const _total = 2.0;
const _hold = Duration(milliseconds: 200);
const _fade = Duration(milliseconds: 350);

const _markWidth = 156.0; // same width as the native launch image
const _name = 'ShowShelf';
const _tagline = 'Never miss an episode.';

/// Damped spring from 0 to 1. [w] is stiffness (rad/s), [z] the damping ratio (< 1 overshoots).
double _spring(double t, double w, double z) {
  if (t <= 0) return 0;
  final wd = w * math.sqrt(1 - z * z);
  return 1 - math.exp(-z * w * t) * (math.cos(wd * t) + (z * w / wd) * math.sin(wd * t));
}

double _easeOut(double x) {
  final v = x.clamp(0.0, 1.0).toDouble();
  return 1 - math.pow(1 - v, 4).toDouble();
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
    value: SystemUiOverlayStyle.dark,
    child: Material(
      color: _lime,
      child: Semantics(
        label: 'ShowShelf',
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final t = controller.value * _total;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: _markWidth,
                    height: _markWidth * _gh / _gw,
                    child: CustomPaint(painter: _MarkPainter(t)),
                  ),
                  // Wordmark sits below the glyph; the glyph itself stays dead-centre
                  // so the hand-off from the native launch image doesn't jump.
                  Transform.translate(
                    offset: const Offset(0, 110),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < _name.length; i++) _Letter(_name[i], _easeOut((t - _tWord - i * _stagger) / .5)),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final p = _easeOut((t - _tTag) / .45);
                      return Transform.translate(
                        offset: Offset(0, 152 + (1 - p) * 10),
                        child: Opacity(
                          opacity: p,
                          child: const Text(
                            _tagline,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              height: 1,
                              letterSpacing: .2,
                              color: Color(0xB3111111), // ink at 70%
                            ),
                          ),
                        ),
                      );
                    },
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

class _Letter extends StatelessWidget {
  const _Letter(this.ch, this.p);
  final String ch;
  final double p;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: p,
    child: Transform.translate(
      offset: Offset(0, (1 - p) * 16),
      child: Text(
        ch,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          fontSize: 30,
          height: 1,
          letterSpacing: -.6,
          color: _ink,
        ),
      ),
    ),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.t);
  final double t;

  static RRect _r(double x, double y, double w, double h) => RRect.fromLTRBR(x, y, x + w, y + h, const Radius.circular(34));

  /// Scales [draw] vertically about [baseY] (a book growing up from the shelf).
  static void _grow(Canvas canvas, double baseY, double s, void Function() draw) {
    canvas
      ..save()
      ..translate(0, baseY)
      ..scale(1, s)
      ..translate(0, -baseY);
    draw();
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _ink;
    canvas
      ..translate(size.width / 2, size.height / 2)
      ..scale(size.width / _gw)
      ..translate(-_gcx, -_gcy);

    // Shelf wipes out from the centre.
    final shelf = _easeOut((t - _tShelf) / .45);
    if (shelf > 0) {
      canvas
        ..save()
        ..translate(_gcx, 0)
        ..scale(shelf, 1)
        ..translate(-_gcx, 0)
        ..drawRRect(_r(178, 650, 668, 68), paint)
        ..restore();
    }

    double rise(double start) => _spring(t - start, 15, .62);

    final a = rise(_tA);
    if (a > .001) _grow(canvas, _bookBottom, a, () => canvas.drawRRect(_r(250, 360, 140, 250), paint));
    final b = rise(_tB);
    if (b > .001) _grow(canvas, _bookBottom, b, () => canvas.drawRRect(_r(440, 250, 140, 360), paint));
    final c = rise(_tC);
    if (c > .001) {
      _grow(canvas, _footY, c, () {
        final lean = _leanDeg * math.pi / 180 * _spring(t - _tLean, 12, .45);
        canvas
          ..save()
          ..translate(_footX, _footY)
          ..rotate(lean)
          ..translate(-_footX, -_footY)
          ..drawRRect(_r(_footX, _footY - 340, 140, 340), paint)
          ..restore();
      });
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.t != t;
}
