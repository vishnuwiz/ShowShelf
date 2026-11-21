import 'package:flutter_test/flutter_test.dart';
import 'package:showshelf/cloud_store.dart';
import 'package:showshelf/state.dart';

class FakeCloud implements CloudStore {
  FakeCloud([this.doc]);

  Map<String, dynamic>? doc;
  int saves = 0;

  @override
  Future<Map<String, dynamic>?> load() async => doc;

  @override
  Future<void> save(Map<String, dynamic> data) async {
    doc = data;
    saves++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('state round-trips through the cloud format', () {
    final a = AppState(loadHome: false)
      ..setRating('lighthouse', 3)
      ..toggleEp('harbor', 2, 4)
      ..setStatus('lighthouse', 'completed');
    final b = AppState(loadHome: false);
    b.applyCloud(a.toCloud());
    expect(b.watched, a.watched);
    expect(b.status, a.status);
    expect(b.ratings, a.ratings);
    expect(b.reminders, a.reminders);
    expect(b.recents, a.recents);
    a.dispose();
    b.dispose();
  });

  test('restore replaces local data with the saved document', () async {
    final cloud = FakeCloud({
      'v': 1,
      'dark': false,
      'status': {'neon': 'plan'},
      'ratings': {'neon': 5},
      'watched': {
        'harbor': ['1-1'],
      },
      'reminders': <String>[],
      'recents': ['Kiln'],
    });
    final s = AppState(loadHome: false, cloud: cloud);
    await s.restore();
    expect(s.dark, isFalse);
    expect(s.status, {'neon': 'plan'});
    expect(s.ratings, {'neon': 5});
    expect(s.watched, {'harbor-1-1'});
    expect(s.recents, ['Kiln']);
    s.dispose();
  });

  testWidgets('a burst of changes is saved once, after a short pause', (tester) async {
    final cloud = FakeCloud();
    final s = AppState(loadHome: false, cloud: cloud);
    await s.restore();
    s
      ..setRating('lighthouse', 4)
      ..setRating('neon', 2);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(cloud.saves, 0);
    await tester.pump(const Duration(milliseconds: 700));
    expect(cloud.saves, 1);
    expect(cloud.doc!['ratings'], containsPair('neon', 2));
    s.dispose();
  });
}
