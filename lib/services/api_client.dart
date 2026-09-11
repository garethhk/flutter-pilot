import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const timeout = Duration(seconds: 15);

  Future<dynamic> get(Uri uri) async {
    final response = await getResponse(uri);
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<http.Response> getResponse(Uri uri) async {
    if (!['http', 'https'].contains(uri.scheme))
      throw const FormatException('Unsupported URL');
    final response = await _client.get(uri).timeout(timeout);
    if (response.statusCode != 200)
      throw http.ClientException('HTTP ${response.statusCode}');
    return response;
  }

  void close() => _client.close();
}
