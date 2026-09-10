import '../constants/reportType.dart';
import '../models/question.dart';
import 'api_client.dart';

class PhotoGalleryService {
  static Future<List<Question>> getList(String url) async {
    final data = await ApiClient.get(
      Uri.parse(PHOTO_GALLERY_HOST).resolve(url),
    );
    if (data is! List) throw const FormatException('Expected gallery list');
    return data.map((item) {
      if (item is! Map<String, dynamic>)
        throw const FormatException('Expected gallery object');
      return Question.fromJson(item);
    }).toList();
  }

  static Future<bool> downloadDetail(String url) async {
    final target = Uri.tryParse(url);
    if (target == null ||
        !['http', 'https'].contains(target.scheme) ||
        target.host.isEmpty)
      return false;
    try {
      final uri = Uri.parse(
        PHOTO_GALLERY_DOWNLOAD_URL,
      ).replace(queryParameters: {'detailUrl': url});
      final response = await ApiClient.client
          .get(uri)
          .timeout(ApiClient.timeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }
}
