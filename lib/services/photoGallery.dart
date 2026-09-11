import '../constants/reportType.dart';
import '../models/question.dart';
import 'api_client.dart';

class PhotoGalleryService {
  PhotoGalleryService({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  final ApiClient apiClient;

  Future<List<Question>> getList(String url) async {
    final data = await apiClient.get(
      Uri.parse(PHOTO_GALLERY_HOST).resolve(url),
    );
    if (data is! List) throw const FormatException('Expected gallery list');
    return data.map((item) {
      if (item is! Map<String, dynamic>)
        throw const FormatException('Expected gallery object');
      return Question.fromJson(item);
    }).toList();
  }

  Future<bool> downloadDetail(String url) async {
    final target = Uri.tryParse(url);
    if (target == null ||
        !['http', 'https'].contains(target.scheme) ||
        target.host.isEmpty)
      return false;
    try {
      final uri = Uri.parse(PHOTO_GALLERY_DOWNLOAD_URL)
          .replace(queryParameters: {'detailUrl': url});
      await apiClient.getResponse(uri);
      return true;
    } on Exception {
      return false;
    }
  }
}

class LegacyPhotoGalleryService {
  static Future<List<Question>> getList(String url) =>
      PhotoGalleryService(apiClient: ApiClient(client: LegacyApiClient.client))
          .getList(url);

  static Future<bool> downloadDetail(String url) =>
      PhotoGalleryService(apiClient: ApiClient(client: LegacyApiClient.client))
          .downloadDetail(url);
}
