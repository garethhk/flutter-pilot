import '../services/menu_repository.dart';
import '../services/analysis.dart';
import '../services/photoGallery.dart';
import '../services/api_client.dart';

/// Composition root for application services.
class AppDependencies {
  AppDependencies({
    MenuRepository? menuRepository,
    AnalysisService? analysisService,
    PhotoGalleryService? photoGalleryService,
    ApiClient? apiClient,
  }) : menuRepository = menuRepository ?? ConfigMenuRepository(),
       analysisService = analysisService ?? AnalysisService(),
       photoGalleryService = photoGalleryService ?? PhotoGalleryService(),
       apiClient = apiClient ?? ApiClient();

  final MenuRepository menuRepository;
  final AnalysisService analysisService;
  final PhotoGalleryService photoGalleryService;
  final ApiClient apiClient;
}
