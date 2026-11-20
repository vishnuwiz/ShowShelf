import 'package:material_ui/material_ui.dart';

/// Colour tokens from the ShowShelf design (dark first, light variant).
@immutable
class Ss extends ThemeExtension<Ss> {
  const Ss({
    required this.bg,
    required this.bg2,
    required this.card,
    required this.cardEdge,
    required this.text,
    required this.sub,
    required this.line,
    required this.accent,
    required this.accentInk,
    required this.onAccent,
    required this.edge,
    required this.ok,
    required this.onOk,
    required this.isDark,
  });

  final Color bg, bg2, card, cardEdge, text, sub, line;
  final Color accent; // lime fill
  final Color accentInk; // lime used as text/ink (dark green in light theme for contrast)
  final Color onAccent, edge, ok, onOk;
  final bool isDark;

  static const dark = Ss(
    bg: Color(0xFF101114),
    bg2: Color(0xFF181A1F),
    card: Color(0xFF202329),
    cardEdge: Color(0x00000000),
    text: Color(0xFFFFFFFF),
    sub: Color(0xFFA1A5AE),
    line: Color(0xFF30343B),
    accent: Color(0xFFC6FA4B),
    accentInk: Color(0xFFC6FA4B),
    onAccent: Color(0xFF101114),
    edge: Color(0x00000000),
    ok: Color(0xFFA8E66B),
    onOk: Color(0xFF101114),
    isDark: true,
  );

  static const light = Ss(
    bg: Color(0xFFF6F7F2),
    bg2: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardEdge: Color(0xFFE1E4EA),
    text: Color(0xFF14161A),
    sub: Color(0xFF5B606A),
    line: Color(0xFFE1E4EA),
    accent: Color(0xFFC6FA4B),
    accentInk: Color(0xFF4C7A00),
    onAccent: Color(0xFF101114),
    edge: Color(0x29101114),
    ok: Color(0xFF2F7D00),
    onOk: Color(0xFFFFFFFF),
    isDark: false,
  );

  static Ss of(BuildContext context) => Theme.of(context).extension<Ss>()!;

  @override
  Ss copyWith() => this;

  @override
  Ss lerp(Ss? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Ss(
      bg: l(bg, other.bg),
      bg2: l(bg2, other.bg2),
      card: l(card, other.card),
      cardEdge: l(cardEdge, other.cardEdge),
      text: l(text, other.text),
      sub: l(sub, other.sub),
      line: l(line, other.line),
      accent: l(accent, other.accent),
      accentInk: l(accentInk, other.accentInk),
      onAccent: l(onAccent, other.onAccent),
      edge: l(edge, other.edge),
      ok: l(ok, other.ok),
      onOk: l(onOk, other.onOk),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

ThemeData buildTheme(Ss c) => ThemeData(
  brightness: c.isDark ? Brightness.dark : Brightness.light,
  scaffoldBackgroundColor: c.bg,
  fontFamily: 'Inter',
  colorScheme: ColorScheme.fromSeed(seedColor: c.accent, brightness: c.isDark ? Brightness.dark : Brightness.light, surface: c.bg),
  textSelectionTheme: TextSelectionThemeData(cursorColor: c.accentInk, selectionColor: c.accentInk.withValues(alpha: .3), selectionHandleColor: c.accentInk),
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  extensions: [c],
);

/// Text style helper. [ls] is letter spacing in em, like the CSS source.
/// [tab] turns on tabular numerals, for counters and stats that change.
TextStyle ts(double size, {FontWeight w = FontWeight.w400, Color? color, double ls = 0, double? height, bool tab = false}) => TextStyle(
  fontSize: size,
  fontWeight: w,
  color: color,
  letterSpacing: ls * size,
  height: height,
  fontFeatures: tab ? const [FontFeature.tabularFigures()] : null,
);

// Motion: 200-400ms, spring overshoot where it fits.
const kEase = Cubic(.2, .8, .2, 1);
const kSpring = Cubic(.34, 1.56, .64, 1);
const kSpringSoft = Cubic(.34, 1.3, .64, 1);

/// Duration that collapses to zero when the OS asks for reduced motion.
Duration ms(BuildContext context, int milliseconds) => MediaQuery.of(context).disableAnimations ? Duration.zero : Duration(milliseconds: milliseconds);

Color hsl(num h, num s, num l, [double a = 1]) => HSLColor.fromAHSL(a, (h % 360).toDouble(), s / 100, l / 100).toColor();
