import '../constants/report_type.dart';
import '../models/analysis.dart';
import 'api_client.dart';

class AnalysisService {
  AnalysisService({required this.apiClient});

  final ApiClient apiClient;

  Future<Analysis> getAnalysis(String url) async {
    final data = await apiClient.get(Uri.parse(host).resolve(url));
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Expected report object');
    }
    return Analysis.fromJson(data);
  }
}
