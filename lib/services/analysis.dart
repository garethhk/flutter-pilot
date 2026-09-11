import '../constants/reportType.dart';
import '../models/analysis.dart';
import 'api_client.dart';

class AnalysisService {
  const AnalysisService();

  Future<Analysis?> getAnalysis(String url) async {
    try {
      final data = await ApiClient.get(Uri.parse(HOST).resolve(url));
      if (data is! Map<String, dynamic>)
        throw const FormatException('Expected report object');
      return Analysis.fromJson(data);
    } on Exception {
      return null;
    }
  }
}
