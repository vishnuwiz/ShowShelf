import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../shell.dart';
import '../state.dart';
import '../theme.dart';
import '../ui/kit.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int offset = 0; // months from November 2026, -2..3
  bool forward = true;
  DateTime day = DateTime(2026, 11, 23);

  void _move(int dir) {
    final o = offset + dir;
    if (o < -2 || o > 3) return;
    setState(() {
      offset = o;
      forward = dir > 0;
      day = DateTime(2026, 11 + o, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = Ss.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final first = DateTime(2026, 11 + offset, 1);
    final dim = DateUtils.getDaysInMonth(first.year, first.month);
    final lead = first.weekday - 1; // Monday start
    bool hasRelease(DateTime d) => releases.any((r) => DateUtils.isSameDay(r.d, d));
    final items = releases.where((r) => DateUtils.isSameDay(r.d, day)).toList();

    return ListView(
      padding: EdgeInsets.only(top: top + 20, bottom: 32),
      children: [
        px(const H1('Calendar')),
        const SizedBox(height: 14),
        px(
          Row(
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text('${monthNames[first.month - 1]} ${first.year}', style: ts(19, w: FontWeight.w700, ls: -.02)),
                ),
              ),
              IconBtn(I.back, label: 'Previous month', size: 20, onTap: () => _move(-1)),
              const SizedBox(width: 8),
              IconBtn(I.chevR, label: 'Next month', size: 20, onTap: () => _move(1)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        px(
          Row(
            children: [
              for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
                Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: ts(12, w: FontWeight.w600, color: c.sub),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Entrance(
          key: ValueKey(offset),
          fx: forward ? Fx.slideL : Fx.slideR,
          duration: 340,
          child: px(
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: lead + dim,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 46, mainAxisSpacing: 2),
              itemBuilder: (context, i) {
                if (i < lead) return const SizedBox.shrink();
                final d = DateTime(first.year, first.month, i - lead + 1);
                return _DayCell(
                  date: d,
                  selected: DateUtils.isSameDay(d, day),
                  isToday: DateUtils.isSameDay(d, today),
                  hasRelease: hasRelease(d),
                  onTap: () => setState(() => day = d),
                );
              },
            ),
          ),
        ),
        H2(DateUtils.isSameDay(day, today) ? 'Today' : fmtDay(day), top: 22),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Entrance(
                  fx: Fx.pop,
                  duration: 500,
                  child: CustomPaint(size: const Size.square(72), painter: _EmptyCal(c.sub, c.accentInk)),
                ),
                const SizedBox(height: 12),
                Text('Nothing releases on this day', style: ts(16, w: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Days with a dot have new releases.', style: ts(14, color: c.sub)),
              ],
            ),
          )
        else
          Entrance(
            key: ValueKey(day),
            child: Column(
              children: [
                for (final r in items)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: TitleRow(
                      byId(r.id),
                      thumb: 48,
                      line2: r.label,
                      line3: '${r.kindLabel} · ${r.time}',
                      onTap: () => openTitle(context, r.id),
                      trailing: SsSwitch(on: s.reminders.contains(r.key), label: 'Remind me about ${byId(r.id).title}', onTap: () => s.toggleReminder(r.key)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.date, required this.selected, required this.isToday, required this.hasRelease, required this.onTap});
  final DateTime date;
  final bool selected, isToday, hasRelease;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    return Tap(
      press: false,
      selected: selected,
      label: '${date.day} ${monthNames[date.month - 1]}${hasRelease ? ', has releases' : ''}${isToday ? ', today' : ''}',
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: ms(context, 250),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? c.accent : Colors.transparent,
              border: Border.all(color: isToday && !selected ? c.accentInk : Colors.transparent, width: 1.5),
            ),
            child: Text(
              '${date.day}',
              style: ts(15, w: selected || isToday ? FontWeight.w700 : FontWeight.w500, color: selected ? c.onAccent : c.text, tab: true),
            ),
          ),
          if (hasRelease)
            Positioned(
              bottom: 2,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? c.onAccent : c.accentInk),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCal extends CustomPainter {
  _EmptyCal(this.line, this.accent);
  final Color line, accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 72;
    Paint p(Color col) => Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(RRect.fromLTRBR(10 * s, 14 * s, 62 * s, 60 * s, Radius.circular(9 * s)), p(line));
    canvas.drawLine(Offset(10 * s, 28 * s), Offset(62 * s, 28 * s), p(line));
    canvas.drawLine(Offset(24 * s, 8 * s), Offset(24 * s, 20 * s), p(line));
    canvas.drawLine(Offset(48 * s, 8 * s), Offset(48 * s, 20 * s), p(line));
    canvas.drawLine(Offset(26 * s, 44 * s), Offset(46 * s, 44 * s), p(accent));
  }

  @override
  bool shouldRepaint(_EmptyCal o) => o.line != line || o.accent != accent;
}
