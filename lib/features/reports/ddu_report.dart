import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/reportType.dart';
import '../../presentation/web_page.dart';
import '../../styles/Themes.dart';
import '../../models/analysis.dart';
import '../../models/menu.dart';
import '../../services/analysis.dart';
import '../../core/async_state.dart';

enum DataType { ddu, rps, stock }

class DduReport extends StatefulWidget {
  final Menu reportType;
  final DataType dataType;

  DduReport({
    required this.reportType,
    required this.dataType,
    AnalysisService? analysisService,
  }) : analysisService = analysisService ?? AnalysisService();

  final AnalysisService analysisService;

  @override
  _DduReportState createState() =>
      _DduReportState(reportType: reportType, dataType: dataType);
}

class _DduReportState extends State<DduReport> {
  final Menu reportType;
  final DataType dataType;

  List<Map<String, dynamic>> _detailData = [];
  String _detailDes = "";
  String _detailTime = "";

  // ui control
  bool _showDes = false;
  AsyncState<Analysis?> _state = const AsyncLoading();

  _DduReportState({required this.reportType, required this.dataType});

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reportType.name)),
      // );
      body: Column(
        children: [
          Container(height: WHITE_SPACE_L),
          Expanded(child: _DduReport(context)),
          Divider(),
          Card(
            margin: EdgeInsets.all(WHITE_SPACE_S),
            clipBehavior: Clip.antiAlias,
            child: Container(
              padding: EdgeInsets.all(WHITE_SPACE_M),
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
                  Text('更新时间: ' + _detailTime),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _DduReport(BuildContext context) {
    if (_state is AsyncLoading<Analysis?>) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_state is AsyncError<Analysis?>)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('数据加载失败，请检查网络后重试'),
            TextButton(onPressed: fetchData, child: const Text('重试')),
          ],
        ),
      );
    if (_detailData.isEmpty) return const Center(child: Text('暂无数据'));
    return ListView.builder(
      itemCount: _detailData.length,
      itemBuilder: (context, i) {
        return _buildRow(_detailData[i], context);
      },
    );
  }

  Widget _buildRow(item, BuildContext context) {
    String code = item["code"] as String;
    String name = item["name"] as String;
    List<dynamic> detail;
    List<Widget> line = [];

    line.add(Container(child: SectionTitle(title: "$name [${code.trim()}]")));
    line.add(Divider());
    if (this.dataType == DataType.stock) {
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
    } else if (this.dataType == DataType.ddu) {
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
      line.add(Row(children: [Container(height: WHITE_SPACE_S)]));
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
      line.add(Row(children: [Container(height: WHITE_SPACE_S)]));
    }

    line.add(
      OverflowBar(
        children: [
          ElevatedButton(
            child: Text("DeMark 回溯"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return WebPage(
                      title: "DeMark 回溯",
                      url:
                          (dataType == DataType.stock
                                  ? DEMARK_STOCK_MARK_CHART_URL
                                  : DEMARK_FUND_CHART_URL)
                              .replaceFirst(
                                STOCK_NUM,
                                Uri.encodeQueryComponent(code),
                              ),
                    );
                  },
                ),
              );
            },
          ),
          ElevatedButton(
            child: Text("复制基金代码"),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: item['code']));
            },
          ),
        ],
      ),
    );

    return Container(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(WHITE_SPACE_M),
          child: Column(children: line),
        ),
      ),
    );
  }

  Future<void> fetchData() async {
    setState(
      () => _state = AsyncLoading(
        previous: _state is AsyncData<Analysis?>
            ? (_state as AsyncData<Analysis?>).value
            : null,
      ),
    );
    Analysis? data = await widget.analysisService.getAnalysis(reportType.url);
    if (!mounted) return;
    setState(
      () => _state = data == null
          ? AsyncError(StateError('Unable to load report'))
          : AsyncData(data),
    );
    if (data != null) {
      setState(() {
        _detailData.clear();
        data.items.forEach((element) {
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
        });

        _detailDes = data.description;
        _detailTime = data.generateTime;
      });
    } else {
      setState(() {
        _detailData = [];
        _detailDes = "Error";
        _detailTime = "Error";
      });
    }
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({Key? key, required this.title}) : super(key: key);

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
