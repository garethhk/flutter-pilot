import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:foo/features/reports/ddu_report.dart';
import 'package:foo/features/reports/demark_report.dart';
import 'package:foo/features/backtesting/backtracking.dart';
import 'package:foo/models/menu.dart';
import 'package:foo/services/api_client.dart';
import 'package:foo/services/analysis.dart';

void main() {
  tearDown(() => LegacyApiClient.client.close());

  testWidgets(
    'RPS report handles missing optional fields and displays scores',
    (tester) async {
      LegacyApiClient.client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'items': [
              {'name': 'Test fund', 'code': '000001', 'rps10': 92},
            ],
          }),
          200,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: DduReport(
            reportType: Menu(name: 'RPS', url: '/rps'),
            dataType: DataType.rps,
            analysisService: AnalysisService(
              apiClient: ApiClient(client: LegacyApiClient.client),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('RPS10: 92'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Report can retry after a network failure', (tester) async {
    var calls = 0;
    LegacyApiClient.client = MockClient(
      (_) async => ++calls == 1
          ? http.Response('offline', 503)
          : http.Response('{"resultList": []}', 200),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DeMarkReport(
          reportType: Menu(name: 'DeMark', url: '/demark'),
          analysisService: AnalysisService(
            apiClient: ApiClient(client: LegacyApiClient.client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('数据加载失败，请检查网络后重试'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('暂无数据'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('Backtest chart builds and substitutes the date query', (
    tester,
  ) async {
    Uri? requested;
    LegacyApiClient.client = MockClient((request) async {
      requested = request.url;
      return http.Response(
        '{"category":["2026-01-01","2026-01-02"],"r1":[1,2.5],"r2":[2,3]}',
        200,
      );
    });
    await tester.pumpWidget(
      MaterialApp(
        home: BackTracking(
          reportType: Menu(
            name: 'Backtest',
            url: '/backtracking/{code}?startDate=START_DATE',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(requested!.path, '/backtracking/000001');
    expect(
      requested!.queryParameters['startDate'],
      matches(r'^\d{4}-\d{2}-\d{2}$'),
    );
    expect(requested!.queryParameters.containsKey('unUsed'), isFalse);
    expect(tester.takeException(), isNull);

    LegacyApiClient.client.close();
    LegacyApiClient.client = MockClient(
      (_) async => http.Response('{"code":100}', 200),
    );
    await tester.enterText(find.byType(TextField), 'invalid-symbol');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('平安银行 | 000001'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
