import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_logger.dart';

class ApiClient {
  ApiClient({http.Client? client, AppLogger? logger})
    : _client = client ?? http.Client(),
      _logger = logger ?? const DeveloperAppLogger();

  final http.Client _client;
  final AppLogger _logger;
  bool _closed = false;
  static const timeout = Duration(seconds: 15);

  Future<dynamic> get(Uri uri) async {
    final response = await getResponse(uri);
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<http.Response> getResponse(Uri uri) async {
    if (!['http', 'https'].contains(uri.scheme)) {
      throw const FormatException('Unsupported URL');
    }
    if (_closed) {
      throw StateError('ApiClient is closed');
    }

    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}', uri);
      }
      return response;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'GET request failed for ${uri.host}${uri.path}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void close() {
    if (_closed) {
      return;
    }
    _closed = true;
    _client.close();
  }
}
