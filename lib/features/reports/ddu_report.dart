import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/report_type.dart';
import '../../presentation/web_page.dart';
import '../../styles/themes.dart';
import '../../models/analysis.dart';
import '../../models/menu.dart';
import '../../services/analysis.dart';
import '../../core/async_state.dart';

enum DataType { ddu, rps, stock }

class DduReport extends StatefulWidget {
  final Menu reportType;
  final DataType dataType;

  const DduReport({
    super.key,
    required this.reportType,
    required this.dataType,
    required this.analysisService,
  });

  final AnalysisService analysisService;

  @override
  State<DduReport> createState() => _DduReportState();
}

class _DduReportState extends State<DduReport> {
  List<Map<String, dynamic>> _detailData = [];
  String _detailDes = "";
  String _detailTime = "";

  // ui control
  bool _showDes = false;
  AsyncState<Analysis> _state = const AsyncLoading();

  @override
  void initState() {
    super.initState();
    unawaited(fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.reportType.name)),
      // );
      body: Column(
        children: [
          const SizedBox(height: whiteSpaceLarge),
          Expanded(child: _dduReport(context)),
          const Divider(),
          Card(
            margin: EdgeInsets.all(whiteSpaceSmall),
            clipBehavior: Clip.antiAlias,
            child: Container(
              padding: EdgeInsets.all(whiteSpaceMedium),
              child: Column(
                children: [
                  IconButton(
                    icon: _showDes
                        ? Icon(Icons.arrow_circle_down)
                        : Icon(Icons.arrow_circle_up),
                    onPressed: () {
                      setState(() {
                        _showDes = !_showDes;
                      });
                    },
                  ),
                  _showDes ? Text(_detailDes) : Container(),
                  Text('更新时间: $_detailTime'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dduReport(BuildContext context) {
    if (_state is AsyncLoading<Analysis>) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_state is AsyncError<Analysis>) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('数据加载失败，请检查网络后重试'),
            TextButton(onPressed: fetchData, child: const Text('重试')),
          ],
        ),
      );
    }
    if (_detailData.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }
    return ListView.builder(
      itemCount: _detailData.length,
      itemBuilder: (context, i) {
        return _buildRow(_detailData[i], context);
      },
    );
  }

  Widget _buildRow(Map<String, dynamic> item, BuildContext context) {
    final code = item["code"] as String;
    final name = item["name"] as String;
    List<dynamic> detail;
    final line = <Widget>[];

    line.add(SectionTitle(title: "$name [${code.trim()}]"));
    line.add(const Divider());
    if (widget.dataType == DataType.stock) {
      line.add(
        Row(
          children: [
            Text(
              "评分: ${item["total"]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
    } else if (widget.dataType == DataType.ddu) {
      detail = (item["dduData"] as List);
      line.add(
        Row(
          children: [
            Text(
              "DDU5: ${detail[0]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "DDU10: ${detail[1]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "DDU20: ${detail[2]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "DDU30: ${detail[3]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "DDU60: ${detail[4]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(Row(children: [Container(height: whiteSpaceSmall)]));
    } else {
      detail = (item["rpsData"] as List);
      line.add(
        Row(
          children: [
            Text(
              "RPS10: ${detail[0]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "RPS20: ${detail[1]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "RPS30: ${detail[2]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "RPS60: ${detail[3]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "RPS120: ${detail[4]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(
        Row(
          children: [
            Text(
              "RPS250: ${detail[5]}",
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(Row(children: [Container(height: whiteSpaceSmall)]));
    }

    line.add(
      OverflowBar(
        children: [
          ElevatedButton(
            child: const Text("DeMark 回溯"),
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) {
                    return WebPage(
                      title: "DeMark 回溯",
                      url:
                          (widget.dataType == DataType.stock
                                  ? deMarkStockMarkChartUrl
                                  : deMarkFundChartUrl)
                              .replaceFirst(
                                stockNumberPlaceholder,
                                Uri.encodeQueryComponent(code),
                              ),
                    );
                  },
                ),
              );
            },
          ),
          ElevatedButton(
            child: const Text("复制基金代码"),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: item['code']));
            },
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(whiteSpaceMedium),
        child: Column(children: line),
      ),
    );
  }

  Future<void> fetchData() async {
    setState(
      () => _state = AsyncLoading(
        previous: _state is AsyncData<Analysis>
            ? (_state as AsyncData<Analysis>).value
            : null,
      ),
    );
    try {
      final data = await widget.analysisService.getAnalysis(
        widget.reportType.url,
      );
      if (!mounted) return;
      setState(() {
        _state = AsyncData(data);
        _detailData.clear();
        for (final element in data.items) {
          _detailData.add({
            "msg": (element["msg"] ?? "").toString(),
            "name": element["name"] as String,
            "code": element["code"] as String,
            "total": element["total"] ?? 0,
            "dduData": [
              element["ddu5"],
              element["ddu10"],
              element["ddu20"],
              element["ddu30"],
              element["ddu60"],
            ],
            "rpsData": [
              element["rps10"],
              element["rps20"],
              element["rps30"],
              element["rps60"],
              element["rps120"],
              element["rps250"],
            ],
          });
        }

        _detailDes = data.description;
        _detailTime = data.generateTime;
      });
    } on Object catch (error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _state = AsyncError(error, stackTrace: stackTrace);
        _detailData = [];
        _detailDes = 'Error';
        _detailTime = 'Error';
      });
    }
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
