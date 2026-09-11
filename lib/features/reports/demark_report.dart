import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/report_type.dart';
import '../../presentation/web_page.dart';
import '../../styles/themes.dart';
import '../../models/analysis.dart';
import '../../models/menu.dart';
import '../../services/analysis.dart';
import '../../core/async_state.dart';

class DeMarkReport extends StatefulWidget {
  final Menu reportType;

  const DeMarkReport({
    super.key,
    required this.reportType,
    required this.analysisService,
  });

  final AnalysisService analysisService;

  @override
  State<DeMarkReport> createState() => _DeMarkReportState();
}

class _DeMarkReportState extends State<DeMarkReport> {
  List<Map<String, dynamic>> _detailData = [];
  String _detailDes = "";
  String _detailTime = "";
  final DateFormat _formatter = DateFormat('yyyy年MM月dd日');

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
          Expanded(child: _deMarkReport(context)),
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

  Widget _deMarkReport(BuildContext context) {
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
    final detail = List<dynamic>.of(item["data"] as List);
    final line = <Widget>[];

    line.add(SectionTitle(title: "$name [${code.trim()}]"));
    line.add(const Divider());
    if (detail.length > 2) {
      detail.removeRange(0, detail.length - 2);
    }
    for (final element in detail) {
      line.add(
        Row(
          children: [
            Text(
              "BS: ${element["setup"] > 0 ? _formatter.format(DateTime.fromMillisecondsSinceEpoch(element["setup"])) : '未出现'} (${element['setupNumber']})",
              style: TextStyle(
                color: element['setupNumber'] >= 9
                    ? Colors.redAccent
                    : Colors.black,
              ),
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
              "BC: ${element["countdown"] > 0 ? _formatter.format(DateTime.fromMillisecondsSinceEpoch(element["countdown"])) : '未出现'} (${element['countdownNumber']})",
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
      line.add(const SizedBox(height: whiteSpaceSmall));
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
                      url: deMarkChartUrl.replaceFirst(
                        stockNumberPlaceholder,
                        Uri.encodeQueryComponent(code),
                      ),
                      localChart: true,
                    );
                  },
                ),
              );
            },
          ),
          ElevatedButton(
            child: const Text("复制股票代码"),
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
        previous: _state is AsyncData
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
        for (final element in data.resultList) {
          final flag = element["data"] is Map
              ? (element["data"]["flag"] as List? ?? [])
              : [];
          // 去掉后端没有 flag 的垃圾数据
          if (flag.isNotEmpty) {
            _detailData.add({
              "msg": (element["msg"] ?? "").toString(),
              "name": element["name"] as String,
              "code": element["code"] as String,
              "url": (element["url"] ?? "").toString(),
              "data": flag,
            });
          }
        }

        _detailData.sort((left, right) {
          if (left['data'] is List &&
              right['data'] is List &&
              (right['data'] as List).isNotEmpty &&
              (left['data'] as List).isNotEmpty) {
            return (right['data'] as List).last["countdown"].compareTo(
              (left['data'] as List).last["countdown"],
            );
          } else {
            return 0;
          }
        });
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
