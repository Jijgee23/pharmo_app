import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/data/database/track_data.dart';

TrackData _point({
  double lat = 47.9,
  double lng = 106.9,
  DateTime? date,
  bool sended = false,
}) {
  return TrackData(
    latitude: lat,
    longitude: lng,
    date: date ?? DateTime(2026, 1, 1, 12, 0, 0),
    sended: sended,
  );
}

void main() {
  group('TrackData equality', () {
    test('two points with the same lat/lng/date are equal', () {
      final date = DateTime(2026, 1, 1, 12, 0, 0);
      final a = _point(date: date);
      final b = _point(date: date);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('points differing by lat, lng, or date are not equal', () {
      final date = DateTime(2026, 1, 1, 12, 0, 0);
      final base = _point(date: date);
      expect(base, isNot(equals(_point(lat: 47.91, date: date))));
      expect(base, isNot(equals(_point(lng: 106.91, date: date))));
      expect(base, isNot(equals(_point(date: date.add(const Duration(seconds: 1))))));
    });

    test('sended flag does not affect equality (identity is location+time)', () {
      final date = DateTime(2026, 1, 1, 12, 0, 0);
      final a = _point(date: date, sended: false);
      final b = _point(date: date, sended: true);
      expect(a, equals(b));
    });

    test('Set-based dedup actually removes duplicates', () {
      final date = DateTime(2026, 1, 1, 12, 0, 0);
      final points = [_point(date: date), _point(date: date), _point(date: date)];
      expect(points.toSet().length, equals(1));
    });
  });
}
