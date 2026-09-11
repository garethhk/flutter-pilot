import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../styles/Themes.dart';
import '../core/async_state.dart';
import '../services/menu_repository.dart';
import '../models/menu.dart';
import '../navigation/app_router.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.menuRepository = const ConfigMenuRepository()});

  final MenuRepository menuRepository;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AsyncState<List<Menu>> _menuState;

  static const _biggerFont = TextStyle(fontSize: 18.0);
  static const _smallerFont = TextStyle(fontSize: 14.0);

  @override
  void initState() {
    super.initState();
    _menuState = AsyncData(widget.menuRepository.localMenu);
    _refreshMenu();
  }

  Future<void> _refreshMenu() async {
    if (_menuState is AsyncLoading<List<Menu>>) return;
    final previous = switch (_menuState) {
      AsyncData<List<Menu>>(:final value) => value,
      AsyncError<List<Menu>>(:final previous) => previous,
      AsyncLoading<List<Menu>>(:final previous) => previous,
    };
    setState(() => _menuState = AsyncLoading(previous: previous));
    try {
      final menu = await widget.menuRepository.fetchMenu();
      if (!mounted) return;
      setState(() => _menuState = AsyncData(menu));
    } on Object catch (error, stackTrace) {
      if (!mounted) return;
      setState(
        () => _menuState = AsyncError(
          error,
          previous: previous,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('希望 2.0'),
        actions: [
          IconButton(
            tooltip: '重新整理菜单',
            onPressed: _menuState is AsyncLoading<List<Menu>>
                ? null
                : _refreshMenu,
            icon: _menuState is AsyncLoading<List<Menu>>
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
    final reportTypes = switch (_menuState) {
      AsyncData<List<Menu>>(:final value) => value,
      AsyncLoading<List<Menu>>(:final previous) => previous ?? const <Menu>[],
      AsyncError<List<Menu>>(:final previous) => previous ?? const <Menu>[],
    };
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
      elements: reportTypes,
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
