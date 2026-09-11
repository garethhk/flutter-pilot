import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../styles/Themes.dart';
import '../services/config.dart';
import '../models/menu.dart';
import '../navigation/app_router.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Menu> _reportTypes = ConfigService.getLocalMenu();
  bool _refreshing = false;

  static const _biggerFont = TextStyle(fontSize: 18.0);
  static const _smallerFont = TextStyle(fontSize: 14.0);

  @override
  void initState() {
    super.initState();
    _refreshMenu();
  }

  Future<void> _refreshMenu() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    final menu = await ConfigService.getMenu();
    if (!mounted) return;
    setState(() {
      _reportTypes = menu;
      _refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('希望 2.0'),
        actions: [
          IconButton(
            tooltip: '重新整理菜单',
            onPressed: _refreshing ? null : _refreshMenu,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMenu,
        child: _reportType(context),
      ),
    );
  }

  Widget _reportType(BuildContext context) {
    return GroupedListView<Menu, int>(
      // itemCount: _reportTypes.length * 2,
      padding: const EdgeInsets.all(16.0),
      // 对于每个建议的单词对都会调用一次itemBuilder，然后将单词对添加到ListTile行中
      // 在偶数行，该函数会为单词对添加一个ListTile row.
      // 在奇数行，该函数会添加一个分割线widget，来分隔相邻的词对。
      // 注意，在小屏幕上，分割线看起来可能比较吃力。
      itemBuilder: (context, element) {
        return _buildRow(element, context);
      },
      groupBy: (element) => element.group,
      groupHeaderBuilder: (groupItem) => Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(WHITE_SPACE_M),
        child: Text(groupItem.groupName, style: _biggerFont),
      ),
      elements: _reportTypes,
    );
  }

  Widget _buildRow(Menu reportType, BuildContext context) {
    return InkWell(
      child: Card(
        child: Column(
          children: [
            ExtendedImage.network(
              reportType.image.isEmpty ? DEFAULT_REPORT_IMG : reportType.image,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              cache: true,
            ),
            Container(
              padding: EdgeInsets.all(WHITE_SPACE_M),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(), // fill width
                  Text(reportType.name, style: _biggerFont),
                  Text(reportType.description, style: _smallerFont),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        AppRouter.openReport(context, reportType);
      },
    );
  }
}
