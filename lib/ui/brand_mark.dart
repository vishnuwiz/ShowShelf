import 'package:material_ui/material_ui.dart';

/// The ShowShelf filmstrip mark: an S-shaped film ribbon wrapped around a play button.
///
/// Geometry is traced from the master logo and mirrored in
/// assets/branding/showshelf-mark.svg (tool/generate_platform_icons.py reads that file).
/// Coordinates are in the mark's own units; the box is [kMarkW] x [kMarkH].

/// Brand colours (assets/branding/BRAND.md).
const kLime = Color(0xFFC6FF4D);
const kCharcoal = Color(0xFF111216);

const kMarkW = 278.5, kMarkH = 375.5;

/// The play triangle's centre, relative to the centre of the mark box.
const kPlayCentre = Offset(15.4, 4.6);

/// Each part is a list of closed contours (outline first, then holes) as flat x,y pairs.
// GENERATED GEOMETRY: do not edit by hand.
const _top = <List<double>>[
  [273.8, 6, 270.2, 3, 265.2, 0.8, 261.2, 0, 255, 0.8, 38.8, 60, 29, 64.2, 23, 68, 14, 76.5, 8, 85, 2.8, 97, 1, 104, 0, 112, 0, 188.5, 0.8, 194.2, 2.8, 201.5, 8.2, 211, 13.5, 216.5, 16.8, 219, 22.5, 222.5, 28.8, 225.2, 62.8, 236.8, 83.8, 244.5, 87.2, 245.2, 90.2, 244, 92, 241.5, 92.2, 238.8, 91, 236, 89.5, 234.8, 32.2, 214.5, 23.8, 210, 18, 204.8, 14.5, 199.8, 12.8, 196, 11, 187, 11, 180.8, 11.8, 175.2, 13.2, 170.8, 17.8, 163.2, 23.5, 157.8, 28, 155, 32.8, 153.2, 246, 95, 256, 92.8, 265.5, 88.8, 268.5, 86.5, 274, 80.2, 276.8, 74.8, 278.5, 67.2, 278.5, 17.2, 277, 11.2],
  [110.8, 71.5, 113.2, 74.5, 114, 77.5, 113.8, 97.5, 112.2, 101.2, 110.5, 103, 106.8, 104.8, 96.2, 107.2, 91.2, 109, 86, 109.2, 83.2, 108, 81.2, 106, 80, 102.8, 80, 82.5, 80.5, 80.5, 82.2, 77.5, 85.5, 75, 104.5, 70, 107.5, 70],
  [176.5, 55.5, 177.5, 57.5, 178, 60.5, 178, 78, 177.5, 81, 175.8, 84, 173.8, 85.8, 171.8, 86.8, 153.2, 91.8, 150, 91.8, 146.8, 90.2, 144.5, 87.5, 143.8, 85, 143.8, 64.8, 144.2, 62.5, 145.5, 60.2, 148.2, 57.8, 150.5, 56.8, 152.8, 56.5, 166, 52.8, 170.8, 52, 173.2, 52.8],
  [238.2, 35.2, 240.5, 37.2, 242.2, 41.2, 242.2, 61.2, 240.8, 65, 239, 67, 235.8, 68.8, 230, 70, 224.8, 71.8, 216.5, 73.8, 215, 73.8, 211.5, 72.5, 209.2, 70.2, 208, 67.5, 207.8, 47.5, 208.5, 44.2, 209.5, 42.5, 211.5, 40.5, 214.5, 38.8, 224.5, 36.5, 229.8, 34.8, 235.5, 34.2],
];

const _play = <List<double>>[
  [122, 149, 119.5, 150.2, 117.2, 152.5, 115.8, 157, 115.8, 227.2, 116.5, 231.5, 119, 234.5, 121.5, 235.8, 125.8, 235.8, 139.5, 228.2, 189.8, 198.5, 191.5, 197, 193.2, 194, 193.5, 190.5, 192, 186.8, 190, 184.8, 129.8, 150.8, 126, 149],
];

const _bottom = <List<double>>[
  [277, 233.2, 274, 228.5, 269.5, 225, 263.5, 223, 257.2, 223.2, 17.2, 289, 11.8, 292, 6, 297.5, 3.8, 300.8, 0.8, 308.5, 0, 312.8, 0, 353, 0.8, 357.8, 2.5, 362.8, 5, 366.8, 8.5, 370.2, 15, 374, 21.8, 375.5, 28.8, 375.2, 249, 315.8, 254.2, 313.8, 261.8, 309.2, 268.2, 303.2, 273.2, 296.2, 277, 287.2, 278.5, 278.8, 278.5, 238.8],
  [71.5, 304.5, 73.5, 306.5, 74.8, 310, 74.8, 330, 74.2, 332, 72.5, 334.8, 70, 336.8, 67, 338, 60.8, 339.2, 50.5, 342.2, 46.8, 342.2, 44, 341, 42, 339, 40.8, 336.2, 40.8, 315.2, 43, 310.8, 44.5, 309.2, 47.2, 307.8, 65.5, 303, 68.2, 303],
  [135.8, 286.8, 137.5, 288.5, 138.8, 291.5, 138.8, 313, 137.2, 316.5, 135, 318.8, 132.5, 320, 114.2, 324.8, 110.8, 324.8, 107.8, 323.2, 105.8, 321, 104.8, 317.8, 104.8, 298.5, 105.2, 296, 107, 293, 108.2, 291.8, 111.5, 290, 127.5, 285.8, 132, 285.2],
  [199, 269, 201.5, 271.5, 202.8, 275.5, 202.8, 295, 200.8, 299.2, 199, 301, 196, 302.5, 178.8, 307, 174.2, 307, 171.5, 305.5, 169.8, 303.5, 168.8, 301, 168.8, 280.2, 170.2, 276.5, 172.2, 274.5, 174.8, 273, 182.5, 270.8, 187.8, 269.8, 193.5, 268, 196.2, 268],
];

Path _build(List<List<double>> contours) {
  final path = Path()..fillType = PathFillType.evenOdd;
  for (final c in contours) {
    path.moveTo(c[0], c[1]);
    for (var i = 2; i < c.length; i += 2) {
      path.lineTo(c[i], c[i + 1]);
    }
    path.close();
  }
  return path;
}

/// The three parts of the mark, built once, in mark units.
final Path markTop = _build(_top);
final Path markPlay = _build(_play);
final Path markBottom = _build(_bottom);

/// The whole mark, in mark units.
Path buildMarkPath() => Path()
  ..addPath(markTop, Offset.zero)
  ..addPath(markPlay, Offset.zero)
  ..addPath(markBottom, Offset.zero);

/// The mark at [width] logical pixels wide, in one colour, with an optional soft neon glow.
class ShowShelfMark extends StatelessWidget {
  const ShowShelfMark({super.key, this.width = 56, this.color = kLime, this.glow = 0});
  final double width;
  final Color color;

  /// 0 for flat, up to 1 for a strong glow.
  final double glow;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: width * kMarkH / kMarkW,
    child: CustomPaint(painter: _MarkPainter(color, glow)),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color, this.glow);
  final Color color;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / kMarkW;
    canvas.scale(k);
    final path = buildMarkPath();
    if (glow > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: .55 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * glow),
      );
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color || old.glow != glow;
}
