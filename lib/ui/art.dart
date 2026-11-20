import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../theme.dart';

/// Generated poster artwork: a vertical gradient, a light source ("glow")
/// and a silhouette ("ridge"). Four variants: 0 sunset ridge, 1 skyline,
/// 2 moon over waves, 3 planet over horizon. No real artwork is used.
class Art {
  factory Art(int h, int v) => _cache.putIfAbsent(h * 4 + v, () => Art._(h, v));
  static final _cache = <int, Art>{};

  Art._(int h, int v) : variant = v {
    switch (v) {
      case 0:
        bg = [hsl(h, 55, 14), hsl(h + 40, 75, 38), hsl(h + 50, 85, 62)];
        bgStops = [0, .74, 1];
        final a = hsl(h + 50, 100, 82, .95), b = hsl(h + 50, 100, 70, .35);
        glow = Glow(const Offset(.5, .62), [a, a, b, b, b.withValues(alpha: 0)], [0, .09, .10, .26, .27]);
        ridge = hsl(h, 45, 6);
        clip = _pts([0, 72, 14, 52, 26, 68, 42, 40, 58, 64, 72, 48, 86, 66, 100, 54, 100, 100, 0, 100]);
        font = 'BebasNeue';
        fw = FontWeight.w400;
        fs = .21;
      case 1:
        bg = [hsl(h, 60, 10), hsl(h, 70, 28)];
        bgStops = [0, 1];
        final a = hsl(h + 30, 100, 70, .5);
        glow = Glow(const Offset(.5, .28), [a, a.withValues(alpha: 0)], [0, .62], ellipse: true);
        ridge = hsl(h, 50, 5);
        clip = _pts([
          0,
          100,
          0,
          74,
          8,
          74,
          8,
          58,
          16,
          58,
          16,
          78,
          24,
          78,
          24,
          50,
          32,
          50,
          32,
          80,
          42,
          80,
          42,
          62,
          52,
          62,
          52,
          44,
          60,
          44,
          60,
          72,
          70,
          72,
          70,
          56,
          80,
          56,
          80,
          76,
          90,
          76,
          90,
          64,
          100,
          64,
          100,
          100,
        ]);
        font = 'Inter';
        fw = FontWeight.w800;
        fs = .11;
      case 2:
        bg = [hsl(h, 50, 16), hsl(h, 55, 34)];
        bgStops = [0, 1];
        final a = hsl(h, 30, 96), b = hsl(h, 60, 80, .3);
        glow = Glow(const Offset(.7, .26), [a, a, b, b, b.withValues(alpha: 0)], [0, .08, .09, .20, .21]);
        ridge = hsl(h, 55, 8);
        clip = _pts([0, 62, 10, 56, 20, 62, 30, 56, 40, 62, 50, 56, 60, 62, 70, 56, 80, 62, 90, 56, 100, 62, 100, 100, 0, 100]);
        font = 'Fraunces';
        fw = FontWeight.w800;
        fs = .14;
      default:
        bg = [hsl(h, 45, 12), hsl(h, 50, 20)];
        bgStops = [0, 1];
        final a = hsl(h, 90, 62);
        glow = Glow(const Offset(.5, .42), [a, a, a.withValues(alpha: 0)], [0, .24, .25]);
        ridge = hsl(h, 45, 6);
        clip = _pts([0, 80, 100, 80, 100, 100, 0, 100]);
        font = 'Inter';
        fw = FontWeight.w700;
        fs = .12;
    }
  }

  factory Art.of(Show t) => Art(t.h, t.v);

  final int variant;
  late final List<Color> bg;
  late final List<double> bgStops;
  late final Glow glow;
  late final Color ridge;
  late final List<Offset> clip; // fractions of the box
  late final String font;
  late final FontWeight fw;
  late final double fs; // fraction of poster width

  static List<Offset> _pts(List<num> p) => [for (var i = 0; i < p.length; i += 2) Offset(p[i] / 100, p[i + 1] / 100)];
}

class Glow {
  const Glow(this.center, this.colors, this.stops, {this.ellipse = false});
  final Offset center;
  final List<Color> colors;
  final List<double> stops;
  final bool ellipse;
}

class ArtPainter extends CustomPainter {
  ArtPainter(this.art, {this.ridge = true});
  final Art art;
  final bool ridge;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), art.bg, art.bgStops));

    // CSS radial-gradient default size is "farthest-corner".
    final g = art.glow;
    final c = Offset(g.center.dx * size.width, g.center.dy * size.height);
    final fx = math.max(c.dx, size.width - c.dx), fy = math.max(c.dy, size.height - c.dy);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    double r;
    if (g.ellipse) {
      r = math.sqrt2 * fx;
      canvas.scale(1, fy / fx);
    } else {
      r = math.sqrt(fx * fx + fy * fy);
    }
    canvas.drawCircle(Offset.zero, r, Paint()..shader = ui.Gradient.radial(Offset.zero, r, g.colors, g.stops));
    canvas.restore();

    if (ridge) {
      final path = Path()..addPolygon([for (final p in art.clip) Offset(p.dx * size.width, p.dy * size.height)], true);
      canvas.drawPath(path, Paint()..color = art.ridge);
    }
  }

  @override
  bool shouldRepaint(ArtPainter old) => old.art != art || old.ridge != ridge;
}

/// Artwork without title, any size (thumbnails, backdrops, episode stills).
class ArtBox extends StatelessWidget {
  const ArtBox(this.art, {super.key, this.radius = 0, this.ridge = true, this.width, this.height, this.child});
  final Art art;
  final double radius;
  final bool ridge;
  final double? width, height;
  final Widget? child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: CustomPaint(
      painter: ArtPainter(art, ridge: ridge),
      child: SizedBox(width: width, height: height, child: child),
    ),
  );
}

/// 2:3 poster with the title set on the art.
class Poster extends StatelessWidget {
  const Poster(this.show, {super.key, required this.width, this.radius = 12, this.titleBottom = .07, this.title = true, this.footer});
  final Show show;
  final double width, radius, titleBottom;
  final bool title;
  final Widget? footer; // e.g. library progress strip

  @override
  Widget build(BuildContext context) {
    final art = Art.of(show);
    final h = width * 1.5;
    return ArtBox(
      art,
      radius: radius,
      width: width,
      height: h,
      child: Stack(
        children: [
          if (title)
            Positioned(
              left: width * .08,
              right: width * .08,
              bottom: h * titleBottom,
              child: Text(
                show.pt,
                style: TextStyle(
                  fontFamily: art.font,
                  fontWeight: art.fw,
                  fontSize: width * (show.fs ?? art.fs),
                  height: .95,
                  color: Colors.white,
                  shadows: const [Shadow(color: Color(0x73000000), blurRadius: 8, offset: Offset(0, 1))],
                ),
              ),
            ),
          if (footer != null) Positioned(left: 0, right: 0, bottom: 0, child: footer!),
        ],
      ),
    );
  }
}

/// Small 2:3 thumbnail without title (lists).
class PosterThumb extends StatelessWidget {
  const PosterThumb(this.show, {super.key, this.width = 44});
  final Show show;
  final double width;

  @override
  Widget build(BuildContext context) => ArtBox(Art.of(show), radius: 8, width: width, height: width * 1.5);
}
