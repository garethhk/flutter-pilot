import 'dart:io';

import 'package:flutter/services.dart';

/// Bound only to loopback, with a port and lifetime owned by the chart page.
class AssetServer {
  HttpServer? _server;
  Future<Uri> start(String query) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    server.listen((request) async {
      try {
        final path = request.uri.path;
        if (!path.startsWith('/h5/deMarkDetail/') ||
            path.split('/').contains('..') ||
            path.contains('\\')) {
          request.response.statusCode = HttpStatus.notFound;
        } else {
          final data = await rootBundle.load('assets$path');
          final mime =
              {
                'html': 'text/html; charset=utf-8',
                'js': 'application/javascript; charset=utf-8',
                'css': 'text/css; charset=utf-8',
                'png': 'image/png',
                'jpg': 'image/jpeg',
                'gif': 'image/gif',
                'svg': 'image/svg+xml',
              }[path.split('.').last.toLowerCase()] ??
              'application/octet-stream';
          request.response.headers.set(HttpHeaders.contentTypeHeader, mime);
          request.response.add(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          );
        }
      } catch (_) {
        request.response.statusCode = HttpStatus.notFound;
      } finally {
        await request.response.close();
      }
    });
    return Uri(
      scheme: 'http',
      host: '127.0.0.1',
      port: server.port,
      path: '/h5/deMarkDetail/Hope2.html',
      query: query,
    );
  }

  Future<void> close() async {
    await _server?.close(force: true);
  }
}
