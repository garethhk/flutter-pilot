import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:foo/models/analysis.dart';
import 'package:foo/models/question.dart';
import 'package:foo/services/api_client.dart';
import 'package:foo/services/analysis.dart';
import 'package:foo/services/config.dart';
import 'package:foo/services/photoGallery.dart';

void main() {
  late http.Client client;
  setUp(() => client = http.Client());
  tearDown(() => client.close());
  test('Partial legacy payloads default optional fields safely', () {
    final analysis = Analysis.fromJson({
      'items': [
        {'code': '000001'},
      ],
    });
    expect(analysis.resultList, isEmpty);
    expect(analysis.description, '');
    expect(Analysis.fromJson(analysis.toJson()).items.single['code'], '000001');
    final question = Question.fromJson({'tag': 'art', 'total': 2});
    expect(question.link, '');
    expect(question.total, 2);
  });

  test('Offline menu keeps every bundled route', () async {
    client = MockClient((_) async => throw http.ClientException('offline'));
    final menu = await ConfigService(apiClient: ApiClient(client: client))
        .fetchMenu();
    expect(menu.length, ConfigService().getLocalMenu().length);
    expect(menu.map((item) => item.router), contains('BackTracking'));
  });

  test(
    'Newer remote menu replaces complete metadata and adds new entries',
    () async {
      final local = ConfigService().getLocalMenu().first;
      client = MockClient(
        (_) async => http.Response(
          jsonEncode([
            {
              'id': local.id,
              'version': local.version + 1,
              'name': 'Updated',
              'group': 99,
              'groupName': 'New group',
            },
            {'id': 'new', 'version': 1, 'name': 'New'},
          ]),
          200,
        ),
      );
      final menu = await ConfigService(apiClient: ApiClient(client: client))
          .fetchMenu();
      expect(menu.first.name, 'Updated');
      expect(menu.first.group, 99);
      expect(menu.first.version, local.version + 1);
      expect(menu.last.id, 'new');
    },
  );

  test('Invalid JSON and HTTP failures return report failure', () async {
    client = MockClient((_) async => http.Response('not json', 200));
    expect(
      await AnalysisService(apiClient: ApiClient(client: client))
          .getAnalysis('/test'),
      isNull,
    );
    client.close();
    client = MockClient((_) async => http.Response('{}', 503));
    expect(
      await AnalysisService(apiClient: ApiClient(client: client))
          .getAnalysis('/test'),
      isNull,
    );
  });

  test('Gallery download preserves nested query parameters', () async {
    const url = 'https://example.com/answer?id=1&next=2';
    client = MockClient((request) async {
      expect(request.url.queryParameters['detailUrl'], url);
      expect(request.url.queryParameters.keys, ['detailUrl']);
      return http.Response('', 200);
    });
    expect(
      await PhotoGalleryService(apiClient: ApiClient(client: client))
          .downloadDetail(url),
      isTrue,
    );
    expect(
      await PhotoGalleryService(apiClient: ApiClient(client: client))
          .downloadDetail('file:///private'),
      isFalse,
    );
  });
}
