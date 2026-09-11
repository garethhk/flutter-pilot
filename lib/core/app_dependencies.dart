import '../services/menu_repository.dart';
import '../services/analysis.dart';

/// Composition root for application services.
class AppDependencies {
  AppDependencies({
    MenuRepository? menuRepository,
    AnalysisService? analysisService,
  }) : menuRepository = menuRepository ?? ConfigMenuRepository(),
       analysisService = analysisService ?? AnalysisService();

  final MenuRepository menuRepository;
  final AnalysisService analysisService;
}
