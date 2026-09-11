import '../services/menu_repository.dart';
import '../services/analysis.dart';
import '../services/photoGallery.dart';

/// Composition root for application services.
class AppDependencies {
  AppDependencies({
    MenuRepository? menuRepository,
    AnalysisService? analysisService,
    PhotoGalleryService? photoGalleryService,
  }) : menuRepository = menuRepository ?? ConfigMenuRepository(),
       analysisService = analysisService ?? AnalysisService(),
       photoGalleryService = photoGalleryService ?? PhotoGalleryService();

  final MenuRepository menuRepository;
  final AnalysisService analysisService;
  final PhotoGalleryService photoGalleryService;
}
