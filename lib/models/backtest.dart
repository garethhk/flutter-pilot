class BacktestPoint {
  const BacktestPoint(this.date, this.r1, this.r2);
  final DateTime date;
  final double r1;
  final double r2;

  static List<BacktestPoint> parse(Map<String, dynamic> json) {
    final dates = json['category'];
    final first = json['r1'];
    final second = json['r2'];
    if (dates is! List ||
        first is! List ||
        second is! List ||
        dates.length != first.length ||
        dates.length != second.length) {
      throw const FormatException('Invalid backtest series');
    }
    return List.generate(dates.length, (index) {
      final date = DateTime.tryParse(dates[index].toString());
      final r1 = first[index];
      final r2 = second[index];
      if (date == null ||
          r1 is! num ||
          r2 is! num ||
          !r1.isFinite ||
          !r2.isFinite) {
        throw const FormatException('Invalid backtest point');
      }
      return BacktestPoint(date, r1.toDouble(), r2.toDouble());
    });
  }
}
