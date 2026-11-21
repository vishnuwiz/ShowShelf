import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:showshelf/ui/brand_mark.dart';

void main() {
  test('mark geometry fills its box and the play button sits between the two ribbons', () {
    final all = buildMarkPath().getBounds();
    expect(all.width, closeTo(kMarkW, 1));
    expect(all.height, closeTo(kMarkH, 1));

    final play = markPlay.getBounds();
    expect(play.top, greaterThan(markTop.getBounds().top));
    expect(play.bottom, lessThan(markBottom.getBounds().bottom));
    expect(play.center.dx - kMarkW / 2, closeTo(kPlayCentre.dx, 1));
    expect(play.center.dy - kMarkH / 2, closeTo(kPlayCentre.dy, 1));
  });

  testWidgets('ShowShelfMark keeps the logo proportions', (tester) async {
    await tester.pumpWidget(const Directionality(textDirection: TextDirection.ltr, child: Center(child: ShowShelfMark(width: 100, glow: 1))));
    final size = tester.getSize(find.byType(ShowShelfMark));
    expect(size.width, 100);
    expect(size.height, closeTo(100 * kMarkH / kMarkW, .01));
  });
}
