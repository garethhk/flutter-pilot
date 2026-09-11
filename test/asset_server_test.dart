import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pilot/services/asset_server.dart';

class _LoopbackHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Chart server serves bundled assets and rejects unrelated paths',
    () async {
      final server = AssetServer();
      // Only this loopback integration test bypasses Flutter's HTTP-400 stub.
      final client = HttpOverrides.runWithHttpOverrides(
        HttpClient.new,
        _LoopbackHttpOverrides(),
      );
      try {
        final uri = await server.start('code=000001');
        expect(uri.host, '127.0.0.1');
        expect(uri.queryParameters['code'], '000001');
        final response = await (await client.getUrl(uri)).close();
        expect(response.statusCode, 200);
        expect(response.headers.contentType?.mimeType, 'text/html');
        await response.drain<void>();
        final rejected = await (await client.getUrl(
          uri.resolve('/pubspec.yaml'),
        )).close();
        expect(rejected.statusCode, 404);
        await rejected.drain<void>();
      } finally {
        client.close(force: true);
        await server.close();
      }
    },
  );
}
