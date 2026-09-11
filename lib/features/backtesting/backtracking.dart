import 'dart:async';

import '../../models/backtest.dart';
import '../../services/api_client.dart';
import '../../core/async_state.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter_pilot/constants/report_type.dart';
import 'package:flutter_pilot/models/menu.dart';
import 'package:intl/intl.dart';

class BackTracking extends StatefulWidget {
  final Menu reportType;
  const BackTracking({
    super.key,
    required this.reportType,
    required this.apiClient,
  });

  final ApiClient apiClient;

  @override
  State<BackTracking> createState() => _BackTrackingState();
}

class _BackTrackingState extends State<BackTracking> {
  String _stockNumber = "000001";
  String _searchText = "000001";
  String _stockName = "平安银行";
  int _backDays = 200;
  final DateTime _nowDate = DateTime.now();
  int _requestId = 0;
  int _searchId = 0;
  late AsyncState<List<charts.Series<LinearSales, DateTime>>> _state;
  late List<charts.Series<LinearSales, DateTime>> _seriesList;

  DateTime _time = DateTime.now();
  Map<String, num> _measures = {"r1": 0, "r2": 0};

  @override
  void initState() {
    super.initState();
    _seriesList = _createLineData({"category": [], "r1": [], "r2": []});
    _state = AsyncLoading(previous: _seriesList);
    unawaited(fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.reportType.name)),
      //   body: _reportDetail(context),
      // );
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(5.0),
              child: TextField(
                onSubmitted: (value) {
                  _searchText = value;
                  unawaited(fetchStock());
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '股票代码',
                ),
              ),
            ),
            Divider(),
            ListTile(title: Text("开始日期")),
            OverflowBar(
              alignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  child: Text('三个月'),
                  onPressed: () {
                    _backDays = 100;
                    unawaited(fetchData());
                  },
                ),
                ElevatedButton(
                  child: Text('六个月'),
                  onPressed: () {
                    _backDays = 200;
                    unawaited(fetchData());
                  },
                ),
                ElevatedButton(
                  child: Text('一年'),
                  onPressed: () {
                    _backDays = 365;
                    unawaited(fetchData());
                  },
                ),
                ElevatedButton(
                  child: Text('三年'),
                  onPressed: () {
                    _backDays = 365 * 3;
                    unawaited(fetchData());
                  },
                ),
              ],
            ),
            Divider(),
            ListTile(
              subtitle: Text(
                "日期: ${DateFormat('yyyy-MM-dd').format(_time)}\nr1: ${_measures['r1']}\nr2: ${_measures['r2']}",
              ),
              title: Text("$_stockName | $_stockNumber "),
            ),
            Divider(),
            SizedBox(height: 300, child: _reportDetail(context)),
          ],
        ),
      ),
    );
  }

  Widget _reportDetail(BuildContext context) {
    if (_state is AsyncLoading<List<charts.Series<LinearSales, DateTime>>>) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_state is AsyncError<List<charts.Series<LinearSales, DateTime>>>) {
      return Center(
        child: TextButton(onPressed: fetchData, child: const Text('加载失败，点击重试')),
      );
    }
    if (_seriesList.isEmpty || _seriesList.first.data.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        SizedBox(
          width: (5 * _backDays).toDouble(),
          child: charts.TimeSeriesChart(
            _seriesList,
            animate: !MediaQuery.disableAnimationsOf(context),
            primaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(
                zeroBound: false,
                desiredTickCount: 10,
              ),
            ),
            domainAxis: charts.DateTimeAxisSpec(
              tickProviderSpec: charts.DayTickProviderSpec(increments: [10]),
              tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                day: charts.TimeFormatterSpec(
                  format: 'd',
                  transitionFormat: 'yyyy-MM-dd',
                ),
              ),
            ),
            behaviors: [charts.SeriesLegend()],
            selectionModels: [
              charts.SelectionModelConfig(
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
      searchStockUrl.replaceFirst(
        stockNumberPlaceholder,
        Uri.encodeQueryComponent(_searchText.trim()),
      ),
    );
    try {
      final data = await widget.apiClient.get(uri);
      if (!mounted || searchId != _searchId) return;
      if (data is! Map || data['code'] == 100 || data['symbols'] is! List) {
        throw const FormatException('Invalid stock search');
      }
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
        unawaited(_showCupertinoPicker(context, symbols));
      }
    } on Exception {
      if (searchId == _searchId) {
        _showError();
      }
    }
  }

  Future<void> fetchData() async {
    final requestId = ++_requestId;
    setState(() => _state = AsyncLoading(previous: _seriesList));
    final startDate = DateFormat('yyyy-MM-dd')
        .format(_nowDate.subtract(Duration(days: _backDays)));
    final uri = Uri.parse(host).resolve(
      widget.reportType.url
          .replaceFirst('{code}', Uri.encodeComponent(_stockNumber))
          .replaceFirst(startDatePlaceholder, startDate),
    );
    try {
      final data = await widget.apiClient.get(uri);
      if (!mounted || requestId != _requestId) return;
      if (data is! Map<String, dynamic> || data['code'] == 100) {
        throw const FormatException('Invalid backtest');
      }
      final series = _createLineData(data);
      setState(() {
        _seriesList = series;
        _state = AsyncData(series);
      });
    } on Exception {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _state = AsyncError(
          StateError('Unable to load backtest'),
          previous: _seriesList,
        );
      });
    }
  }

  /// Preserve the two return series and their date domain.
  static List<charts.Series<LinearSales, DateTime>> _createLineData(
    Map<String, dynamic> result,
  ) {
    final data = BacktestPoint.parse(result)
        .map((point) => LinearSales(point.date, point.r1, point.r2))
        .toList();

    return [
      charts.Series<LinearSales, DateTime>(
        id: 'r1',
        colorFn: (_, _) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.date,
        measureFn: (LinearSales sales, _) => sales.r1,
        data: data,
      ),
      charts.Series<LinearSales, DateTime>(
        id: 'r2',
        colorFn: (_, _) => charts.MaterialPalette.black,
        domainFn: (LinearSales sales, _) => sales.date,
        measureFn: (LinearSales sales, _) => sales.r2,
        data: data,
      ),
    ];
  }

  void _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isEmpty) {
      return;
    }
    DateTime time = selectedDatum.first.datum.date;
    final measures = <String, num>{};

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.date;
      for (final datumPair in selectedDatum) {
        measures[datumPair.series.id] = datumPair.datum.getProp(
          datumPair.series.id,
        );
      }
    }

    // Request a build.
    setState(() {
      _time = time;
      _measures = measures;
    });
  }

  void _showError() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('数据加载失败，请重试')));
  }

  Future<void> _showCupertinoPicker(
    BuildContext context,
    List<dynamic> stockLists,
  ) async {
    final options = stockLists.map<Widget>((stock) {
      return Text("${stock['code']} | ${stock['name']}");
    }).toList();
    final picker = CupertinoPicker(
      itemExtent: 40,
      backgroundColor: Colors.white,
      onSelectedItemChanged: (position) {
        setState(() {
          _stockName = stockLists[position]['name'];
          _stockNumber = stockLists[position]['code'];
        });
        unawaited(fetchData());
      },
      children: options,
    );
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return SizedBox(height: 200, child: picker);
      },
    );
  }
}

/// Sample linear data type.
class LinearSales {
  final DateTime date;
  final double r1;
  final double r2;

  double? getProp(String key) => <String, double>{'r1': r1, 'r2': r2}[key];

  LinearSales(this.date, this.r1, this.r2);
}
