// Demo catalogue. All titles, people and artwork are fictional.

enum Kind { movie, series, anime }

class Show {
  const Show({
    required this.id,
    required this.kind,
    required this.title,
    required this.pt,
    required this.year,
    required this.genre,
    required this.r,
    required this.h,
    required this.v,
    required this.cast,
    required this.dir,
    required this.syn,
    this.run = 0,
    this.seasons = const [],
    this.fs,
  });

  final String id, title, genre, dir, syn;
  final String pt; // poster title, may contain a line break
  final Kind kind;
  final int year, run, h, v; // run in minutes; h = art hue; v = art variant 0..3
  final double r; // TMDB-style rating
  final List<String> cast;
  final List<int> seasons; // episodes per season (series/anime only)
  final double? fs; // poster title size override, fraction of poster width

  bool get isMovie => kind == Kind.movie;
  int get totalEps => seasons.fold(0, (a, b) => a + b);
  String get kindLabel => switch (kind) {
    Kind.movie => 'Movie',
    Kind.anime => 'Anime',
    Kind.series => 'Series',
  };
}

const people = {'mira': 'Mira Adeyemi', 'jonas': 'Jonas Hale', 'tamsin': 'Tamsin Okoro', 'ravi': 'Ravi Menon', 'lena': 'Lena Voss', 'idris': 'Idris Calder'};

String initials(String name) => name.split(' ').map((x) => x[0]).join();

const titles = <Show>[
  Show(
    id: 'lighthouse',
    kind: Kind.movie,
    title: 'The Last Lighthouse',
    pt: 'The Last\nLighthouse',
    year: 2026,
    run: 118,
    genre: 'Drama',
    r: 8.1,
    h: 205,
    v: 2,
    cast: ['mira', 'jonas', 'tamsin'],
    dir: 'Lena Voss',
    syn: 'A retired signal keeper returns to the island she left as a girl, just as the last lamp on the coast fails and the sea begins asking for old debts.',
  ),
  Show(
    id: 'neon',
    kind: Kind.movie,
    title: 'Neon Meridian',
    pt: 'NEON\nMERIDIAN',
    year: 2025,
    run: 132,
    genre: 'Sci-Fi',
    r: 7.6,
    h: 285,
    v: 1,
    cast: ['ravi', 'lena', 'idris'],
    dir: 'Idris Calder',
    syn: 'In a city that never dims, a courier carrying a stranger’s memories has one night to deliver them before the owner is erased.',
  ),
  Show(
    id: 'salt',
    kind: Kind.movie,
    title: 'Salt & Ember',
    pt: 'SALT\n& EMBER',
    year: 2026,
    run: 104,
    genre: 'Thriller',
    r: 7.2,
    h: 18,
    v: 0,
    cast: ['jonas', 'tamsin', 'mira'],
    dir: 'Ravi Menon',
    syn: 'Two rival salvage crews race through a winter storm to reach the same wreck, and the cargo neither expected to find.',
  ),
  Show(
    id: 'quiet',
    kind: Kind.movie,
    title: 'Quiet Orbit',
    pt: 'QUIET\nORBIT',
    year: 2024,
    run: 141,
    genre: 'Sci-Fi',
    r: 8.4,
    h: 245,
    v: 3,
    cast: ['lena', 'ravi', 'mira'],
    dir: 'Lena Voss',
    syn: 'A survey ship drifts toward a silent orbit where every previous crew stopped transmitting, one by one, mid-sentence.',
  ),
  Show(
    id: 'marlowe',
    kind: Kind.movie,
    title: 'Midnight at Marlowe',
    pt: 'MIDNIGHT\nAT MARLOWE',
    year: 2025,
    run: 109,
    genre: 'Mystery',
    r: 7.4,
    h: 265,
    v: 1,
    cast: ['tamsin', 'idris', 'jonas'],
    dir: 'Tamsin Okoro',
    syn: 'When the night porter of a grand hotel vanishes, a retired detective checks in under a name that isn’t hers.',
  ),
  Show(
    id: 'fieldwork',
    kind: Kind.movie,
    title: 'Fieldwork',
    pt: 'FIELD\nWORK',
    year: 2023,
    run: 97,
    genre: 'Drama',
    r: 7.9,
    h: 95,
    v: 0,
    cast: ['mira', 'ravi', 'lena'],
    dir: 'Jonas Hale',
    syn: 'A soil scientist and her estranged brother spend one harvest season deciding whether to sell the farm their mother built.',
  ),
  Show(
    id: 'harbor',
    kind: Kind.series,
    title: 'Harbor Lights',
    pt: 'Harbor\nLights',
    year: 2024,
    seasons: [8, 6, 6],
    genre: 'Drama',
    r: 8.3,
    h: 190,
    v: 2,
    cast: ['mira', 'idris', 'jonas'],
    dir: 'Lena Voss',
    syn: 'Three generations of a fishing family fight to keep their harbor open as the town around it changes. Secrets surface with every tide.',
  ),
  Show(
    id: 'ninth',
    kind: Kind.series,
    title: 'The Ninth Floor',
    pt: 'THE NINTH\nFLOOR',
    year: 2025,
    seasons: [8, 8],
    genre: 'Thriller',
    r: 8.0,
    h: 340,
    v: 1,
    cast: ['tamsin', 'ravi', 'idris'],
    dir: 'Ravi Menon',
    syn: 'Every tenant on the ninth floor of an old office tower is hiding something, and the lifts only stop there after midnight.',
  ),
  Show(
    id: 'tidewater',
    kind: Kind.series,
    title: 'Tidewater',
    pt: 'Tidewater',
    year: 2023,
    seasons: [6, 6, 6],
    genre: 'Crime',
    r: 7.7,
    h: 170,
    v: 2,
    cast: ['jonas', 'lena', 'mira'],
    dir: 'Idris Calder',
    syn: 'A coastal detective untangles cases that wash up with the tide, each leading back to a drowned village beneath the bay.',
  ),
  Show(
    id: 'kiln',
    kind: Kind.anime,
    title: 'Kiln',
    pt: 'KILN',
    fs: .30,
    year: 2025,
    seasons: [12, 12],
    genre: 'Fantasy',
    r: 8.6,
    h: 20,
    v: 3,
    cast: ['ravi', 'tamsin', 'lena'],
    dir: 'Studio Ember',
    syn: 'An apprentice glassmaker discovers that the furnace in her master’s workshop burns memories instead of coal.',
  ),
  Show(
    id: 'papermoons',
    kind: Kind.anime,
    title: 'Paper Moons',
    pt: 'PAPER\nMOONS',
    year: 2024,
    seasons: [12],
    genre: 'Slice of life',
    r: 8.2,
    h: 320,
    v: 0,
    cast: ['mira', 'idris', 'ravi'],
    dir: 'Studio Ember',
    syn: 'A quiet year in a mountain town, told through letters four neighbours leave in each other’s mailboxes.',
  ),
  Show(
    id: 'static',
    kind: Kind.anime,
    title: 'Static Bloom',
    pt: 'STATIC\nBLOOM',
    year: 2026,
    seasons: [10],
    genre: 'Sci-Fi',
    r: 8.0,
    h: 175,
    v: 1,
    cast: ['lena', 'jonas', 'tamsin'],
    dir: 'Studio Ember',
    syn: 'A radio operator on a remote relay station hears a broadcast from tomorrow and starts to change the ending.',
  ),
];

Show byId(String id) => titles.firstWhere((t) => t.id == id);

enum RelType { ep, season, movie }

class Release {
  const Release(this.d, this.id, this.label, this.time, this.type);
  final DateTime d;
  final String id, label, time;
  final RelType type;
  String get key => '${isoDate(d)}$id';
  String get kindLabel => switch (type) {
    RelType.movie => 'Movie',
    RelType.season => 'New season',
    RelType.ep => 'New episode',
  };
}

final releases = <Release>[
  Release(DateTime(2026, 11, 21), 'kiln', 'Season 2 · Episode 3', '8:30 PM', RelType.ep),
  Release(DateTime(2026, 11, 22), 'ninth', 'Season 2 · Episode 6', '9:00 PM', RelType.ep),
  Release(DateTime(2026, 11, 23), 'static', 'Season 1 · Episode 7', '11:00 PM', RelType.ep),
  Release(DateTime(2026, 11, 23), 'harbor', 'Season 3 trailer drops', '6:00 PM', RelType.ep),
  Release(DateTime(2026, 11, 26), 'tidewater', 'Season 3 premiere', '7:00 PM', RelType.season),
  Release(DateTime(2026, 11, 27), 'salt', 'In cinemas', 'All day', RelType.movie),
  Release(DateTime(2026, 11, 28), 'kiln', 'Season 2 · Episode 4', '8:30 PM', RelType.ep),
  Release(DateTime(2026, 12, 3), 'harbor', 'Season 3 premiere', '9:00 PM', RelType.season),
  Release(DateTime(2026, 12, 6), 'ninth', 'Season 2 finale', '9:00 PM', RelType.ep),
  Release(DateTime(2026, 12, 18), 'lighthouse', 'In cinemas', 'All day', RelType.movie),
];

/// The demo is pinned to this date so releases and "today" line up.
final today = DateTime(2026, 11, 20);

String isoDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String fmtDay(DateTime d) => '${_wd[d.weekday - 1]} ${d.day} ${_mo[d.month - 1]}';

String epTitle(Show t, int s, int e) {
  if (t.id == 'harbor') {
    const l = [
      ['Landfall', 'The Net', 'Low Tide', 'Salt Ledger', 'Fog Signal', 'The Keeper’s Son', 'Undertow', 'Harbor Lights'],
      ['Return Tide', 'Rust', 'Manifest', 'Slack Water', 'The Long Haul', 'Beacon'],
      ['Dry Dock', 'Ballast', 'Squall', 'Open Water', 'Anchor Chain', 'Homeport'],
    ];
    return l[s - 1][e - 1];
  }
  const pool = [
    'Pilot',
    'Undertow',
    'The Long Way',
    'Quiet Hours',
    'Borrowed Light',
    'Fault Lines',
    'Open Ground',
    'The Turning',
    'Last Call',
    'Small Hours',
    'Paper Trail',
    'Afterglow',
  ];
  return pool[(s * 5 + e * 3) % pool.length];
}

int epMin(Show t, int s, int e) => (t.kind == Kind.anime ? 22 : 38) + ((s * 7 + e * 5) % 9);

String epKey(String id, int s, int e) => '$id-$s-$e';

Set<String> seedWatched() => {
  for (var e = 1; e <= 8; e++) epKey('harbor', 1, e),
  for (var e = 1; e <= 3; e++) epKey('harbor', 2, e),
  for (var s = 1; s <= 2; s++)
    for (var e = 1; e <= 8; e++) epKey('ninth', s, e),
  for (var e = 1; e <= 5; e++) epKey('kiln', 1, e),
};

const seedStatus = {
  'lighthouse': 'plan',
  'neon': 'completed',
  'salt': 'plan',
  'quiet': 'completed',
  'marlowe': 'onhold',
  'fieldwork': 'completed',
  'harbor': 'watching',
  'ninth': 'watching',
  'tidewater': 'dropped',
  'kiln': 'watching',
  'papermoons': 'plan',
  'static': 'plan',
};

const statusLabel = {'watching': 'Watching', 'completed': 'Completed', 'plan': 'Plan to watch', 'onhold': 'On hold', 'dropped': 'Dropped'};
