import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_pilot/core/app_logger.dart';
import 'package:flutter_pilot/models/analysis.dart';
import 'package:flutter_pilot/models/question.dart';
import 'package:flutter_pilot/services/api_client.dart';
import 'package:flutter_pilot/services/analysis.dart';
import 'package:flutter_pilot/services/config.dart';
import 'package:flutter_pilot/services/photo_gallery.dart';

void main() {
  const logger = NoopAppLogger();
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
    final service = ConfigService(
      apiClient: ApiClient(client: client, logger: logger),
      logger: logger,
    );
    final menu = await service.fetchMenu();
    expect(menu.length, service.getLocalMenu().length);
    expect(menu.map((item) => item.router), contains('BackTracking'));
  });

  test(
    'Newer remote menu replaces complete metadata and adds new entries',
    () async {
      final localService = ConfigService(
        apiClient: ApiClient(client: client, logger: logger),
        logger: logger,
      );
      final local = localService.getLocalMenu().first;
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
      final menu = await ConfigService(
        apiClient: ApiClient(client: client, logger: logger),
        logger: logger,
      ).fetchMenu();
      expect(menu.first.name, 'Updated');
      expect(menu.first.group, 99);
      expect(menu.first.version, local.version + 1);
      expect(menu.last.id, 'new');
    },
  );

  test('Invalid JSON and HTTP failures surface typed errors', () async {
    client = MockClient((_) async => http.Response('not json', 200));
    expect(
      AnalysisService(
        apiClient: ApiClient(client: client, logger: logger),
      ).getAnalysis('/test'),
      throwsA(isA<FormatException>()),
    );
    client.close();
    client = MockClient((_) async => http.Response('{}', 503));
    expect(
      AnalysisService(
        apiClient: ApiClient(client: client, logger: logger),
      ).getAnalysis('/test'),
      throwsA(isA<http.ClientException>()),
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
      await PhotoGalleryService(
        apiClient: ApiClient(client: client, logger: logger),
      ).downloadDetail(url),
      isTrue,
    );
    expect(
      await PhotoGalleryService(
        apiClient: ApiClient(client: client, logger: logger),
      ).downloadDetail('file:///private'),
      isFalse,
    );
  });
}
