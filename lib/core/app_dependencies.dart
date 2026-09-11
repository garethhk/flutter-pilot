import '../services/menu_repository.dart';
import '../services/analysis.dart';

/// Composition root for application services.
class AppDependencies {
  const AppDependencies({
    this.menuRepository = const ConfigMenuRepository(),
    this.analysisService = const AnalysisService(),
  });

  final MenuRepository menuRepository;
  final AnalysisService analysisService;
}
