import '../models/backtest.dart';
import '../services/api_client.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:foo/constants/reportType.dart';
import 'package:foo/models/menu.dart';
import 'package:intl/intl.dart';

class BackTracking extends StatefulWidget {
  final Menu reportType;
  BackTracking({required this.reportType});

  @override
  _BackTrackingState createState() =>
      _BackTrackingState(reportType: reportType);
}

class _BackTrackingState extends State<BackTracking> {
  final Menu reportType;
  String _stockNumber = "000001";
  String _searchText = "000001";
  String _stockName = "平安银行";
  int _backDays = 200;
  final DateTime _nowDate = DateTime.now();
  int _requestId = 0;
  int _searchId = 0;
  bool _loading = true;
  bool _failed = false;
  late List<charts.Series<LinearSales, DateTime>> _seriesList;

  DateTime _time = DateTime.now();
  Map<String, num> _measures = {"r1": 0, "r2": 0};

  _BackTrackingState({required this.reportType}) {
    _seriesList = _createLineData({"category": [], "r1": [], "r2": []});
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(reportType.name)),
      //   body: _reportDetail(context),
      // );
      body: SingleChildScrollView(
        child: new Column(
          children: [
            Container(
              padding: EdgeInsets.all(5.0),
              child: new TextField(
                onSubmitted: (value) {
                  _searchText = value;
                  fetchStock();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '股票代码',
                ),
              ),
            ),
            new Divider(),
            new ListTile(title: new Text("开始日期")),
            new OverflowBar(
              alignment: MainAxisAlignment.start,
              children: [
                new ElevatedButton(
                  child: Text('三个月'),
                  onPressed: () {
                    _backDays = 100;
                    fetchData();
                  },
                ),
                new ElevatedButton(
                  child: Text('六个月'),
                  onPressed: () {
                    _backDays = 200;
                    fetchData();
                  },
                ),
                new ElevatedButton(
                  child: Text('一年'),
                  onPressed: () {
                    _backDays = 365;
                    fetchData();
                  },
                ),
                new ElevatedButton(
                  child: Text('三年'),
                  onPressed: () {
                    _backDays = 365 * 3;
                    fetchData();
                  },
                ),
              ],
            ),
            new Divider(),
            new ListTile(
              subtitle: new Text(
                "日期: ${DateFormat('yyyy-MM-dd').format(_time)}\nr1: ${_measures['r1']}\nr2: ${_measures['r2']}",
              ),
              title: new Text("$_stockName | $_stockNumber "),
            ),
            new Divider(),
            new Container(height: 300.0, child: _reportDetail(context)),
          ],
        ),
      ),
    );
  }

  Widget _reportDetail(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed)
      return Center(
        child: TextButton(onPressed: fetchData, child: const Text('加载失败，点击重试')),
      );
    if (_seriesList.isEmpty || _seriesList.first.data.isEmpty)
      return const Center(child: Text('暂无数据'));

    return new ListView(
      scrollDirection: Axis.horizontal,
      children: [
        new Container(
          width: (5 * _backDays).toDouble(),
          child: charts.TimeSeriesChart(
            _seriesList,
            animate: !MediaQuery.disableAnimationsOf(context),
            primaryMeasureAxis: new charts.NumericAxisSpec(
              tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                zeroBound: false,
                desiredTickCount: 10,
              ),
            ),
            domainAxis: new charts.DateTimeAxisSpec(
              tickProviderSpec: new charts.DayTickProviderSpec(
                increments: [10],
              ),
              tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                day: new charts.TimeFormatterSpec(
                  format: 'd',
                  transitionFormat: 'yyyy-MM-dd',
                ),
              ),
            ),
            behaviors: [new charts.SeriesLegend()],
            selectionModels: [
              new charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                changedListener: _onSelectionChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> fetchStock() async {
    final searchId = ++_searchId;
    final uri = Uri.parse(
      SEARCH_STOCK_URL.replaceFirst(
        STOCK_NUM,
        Uri.encodeQueryComponent(_searchText.trim()),
      ),
    );
    try {
      final data = await ApiClient.get(uri);
      if (!mounted || searchId != _searchId) return;
      if (data is! Map || data['code'] == 100 || data['symbols'] is! List)
        throw const FormatException('Invalid stock search');
      final symbols = data['symbols'] as List;
      if (symbols.isEmpty) {
        _showError();
        return;
      }
      if (symbols.length == 1) {
        setState(() {
          _stockName = symbols.first['name'].toString();
          _stockNumber = symbols.first['code'].toString();
        });
        await fetchData();
      } else {
        _showCupertinoPicker(context, symbols);
      }
    } on Exception {
      if (searchId == _searchId) _showError();
    }
  }

  Future<void> fetchData() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _failed = false;
    });
    final startDate = DateFormat(
      'yyyy-MM-dd',
    ).format(_nowDate.subtract(Duration(days: _backDays)));
    final uri = Uri.parse(HOST).resolve(
      reportType.url
          .replaceFirst('{code}', Uri.encodeComponent(_stockNumber))
          .replaceFirst(START_DATE, startDate),
    );
    try {
      final data = await ApiClient.get(uri);
      if (!mounted || requestId != _requestId) return;
      if (data is! Map<String, dynamic> || data['code'] == 100)
        throw const FormatException('Invalid backtest');
      final series = _createLineData(data);
      setState(() {
        _seriesList = series;
        _loading = false;
      });
    } on Exception {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  /// Preserve the two return series and their date domain.
  static List<charts.Series<LinearSales, DateTime>> _createLineData(
    Map<String, dynamic> result,
  ) {
    final data = BacktestPoint.parse(
      result,
    ).map((point) => LinearSales(point.date, point.r1, point.r2)).toList();

    return [
      new charts.Series<LinearSales, DateTime>(
        id: 'r1',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.date,
        measureFn: (LinearSales sales, _) => sales.r1,
        data: data,
      ),
      new charts.Series<LinearSales, DateTime>(
        id: 'r2',
        colorFn: (_, __) => charts.MaterialPalette.black,
        domainFn: (LinearSales sales, _) => sales.date,
        measureFn: (LinearSales sales, _) => sales.r2,
        data: data,
      ),
    ];
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isEmpty) return;
    DateTime time = selectedDatum.first.datum.date;
    final measures = <String, num>{};

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.date;
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.id] = datumPair.datum.getProp(
          datumPair.series.id,
        );
      });
    }

    // Request a build.
    setState(() {
      _time = time;
      _measures = measures;
    });
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('数据加载失败，请重试')));
  }

  void _showCupertinoPicker(BuildContext context, stockLists) {
    var names = stockLists;
    List<Widget> options = names.map<Widget>((e) {
      var e2 = "${e['code']} | ${e['name']}";
      return Text(e2);
    }).toList();
    final picker = CupertinoPicker(
      itemExtent: 40,
      backgroundColor: Colors.white,
      onSelectedItemChanged: (position) {
        setState(() {
          _stockName = names[position]['name'];
          _stockNumber = names[position]['code'];
          fetchData();
        });
      },
      children: options,
    );
    showCupertinoModalPopup(
      context: context,
      builder: (cxt) {
        return Container(height: 200, child: picker);
      },
    );
  }
}

/// Sample linear data type.
class LinearSales {
  final DateTime date;
  final double r1;
  final double r2;

  dynamic getProp(String key) => <String, dynamic>{'r1': r1, 'r2': r2}[key];

  LinearSales(this.date, this.r1, this.r2);
}
