import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static http.Client client = http.Client();
  static const timeout = Duration(seconds: 15);
  static Future<dynamic> get(Uri uri) async {
    if (!['http', 'https'].contains(uri.scheme))
      throw const FormatException('Unsupported URL');
    final response = await client.get(uri).timeout(timeout);
    if (response.statusCode != 200)
      throw http.ClientException('HTTP ${response.statusCode}');
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
