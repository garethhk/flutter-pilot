import 'package:flutter_test/flutter_test.dart';
import 'package:foo/models/backtest.dart';

void main() {
  test('Backtest accepts integer and fractional returns', () {
    final point = BacktestPoint.parse({
      'category': ['2026-01-01'],
      'r1': [1],
      'r2': [2.5],
    }).single;
    expect(point.date, DateTime(2026, 1, 1));
    expect(point.r1, 1.0);
    expect(point.r2, 2.5);
  });
  test('Backtest rejects mismatched series and invalid points', () {
    for (final payload in [
      {
        'category': ['2026-01-01'],
        'r1': [],
        'r2': [2],
      },
      {
        'category': ['invalid'],
        'r1': [1],
        'r2': [2],
      },
      {
        'category': ['2026-01-01'],
        'r1': ['bad'],
        'r2': [2],
      },
    ]) {
      expect(() => BacktestPoint.parse(payload), throwsFormatException);
    }
  });
}
