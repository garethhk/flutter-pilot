import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:foo/core/app_dependencies.dart';
import 'package:foo/main.dart';
import 'package:foo/models/menu.dart';
import 'package:foo/services/menu_repository.dart';
import 'package:foo/services/analysis.dart';
import 'package:foo/services/api_client.dart';

class _FakeMenuRepository implements MenuRepository {
  _FakeMenuRepository({List<Menu>? menu})
    : _menu =
          menu ??
          [
            Menu(
              id: 'injected',
              group: 1,
              groupName: 'Injected',
              name: 'Injected report',
              router: 'unknown',
            ),
          ];

  final List<Menu> _menu;

  @override
  List<Menu> get localMenu => _menu;

  @override
  Future<List<Menu>> fetchMenu() async => _menu;
}

void main() {
  testWidgets('Home renders menu supplied by an injected repository', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        dependencies: AppDependencies(menuRepository: _FakeMenuRepository()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Injected report'), findsOneWidget);
    expect(find.text('Injected'), findsOneWidget);
  });

  testWidgets('Home opens a report through injected services', (tester) async {
    final repository = _FakeMenuRepository(
      menu: [
        Menu(
          id: 'report',
          group: 1,
          groupName: 'Reports',
          name: 'Daily report',
          router: 'ReportDetail',
          url: '/analysis/daily',
        ),
      ],
    );
    final client = MockClient(
      (_) async => http.Response(
        '{"resultList": [], "description": "", "generateTime": ""}',
        200,
      ),
    );
    await tester.pumpWidget(
      MyApp(
        dependencies: AppDependencies(
          menuRepository: repository,
          analysisService: AnalysisService(
            apiClient: ApiClient(client: client),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Daily report').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Daily report'), findsWidgets);
    expect(find.text('暂无数据'), findsOneWidget);
  });

  testWidgets('Home remains usable with large text', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MyApp(
          dependencies: AppDependencies(menuRepository: _FakeMenuRepository()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Injected report'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
