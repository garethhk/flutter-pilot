import 'dart:convert';

import 'package:flutter_pilot/core/app_dependencies.dart';
import 'package:flutter_pilot/core/app_logger.dart';
import 'package:flutter_pilot/services/api_client.dart';
import 'package:flutter_pilot/services/menu_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('composition root shares and closes one ApiClient', () {
    final transport = _TrackingClient();
    final apiClient = ApiClient(
      client: transport,
      logger: const NoopAppLogger(),
    );
    final dependencies = AppDependencies(apiClient: apiClient);

    expect(identical(dependencies.apiClient, apiClient), isTrue);
    expect(
      identical(dependencies.analysisService.apiClient, apiClient),
      isTrue,
    );
    expect(
      identical(dependencies.photoGalleryService.apiClient, apiClient),
      isTrue,
    );
    final repository = dependencies.menuRepository as ConfigMenuRepository;
    expect(identical(repository.configService.apiClient, apiClient), isTrue);
    expect(identical(dependencies.router.apiClient, apiClient), isTrue);

    dependencies.close();
    dependencies.close();
    expect(transport.closed, isTrue);
    expect(transport.closeCount, 1);
  });
}

final class _TrackingClient extends http.BaseClient {
  bool closed = false;
  int closeCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode('[]')),
      200,
      request: request,
    );
  }

  @override
  void close() {
    closed = true;
    closeCount++;
    super.close();
  }
}
