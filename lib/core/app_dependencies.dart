import '../navigation/app_router.dart';
import '../services/analysis.dart';
import '../services/api_client.dart';
import '../services/config.dart';
import '../services/menu_repository.dart';
import '../services/photo_gallery.dart';
import 'app_logger.dart';

/// Composition root for application services and their shared resources.
class AppDependencies {
  factory AppDependencies({
    AppLogger? logger,
    ApiClient? apiClient,
    MenuRepository? menuRepository,
    AppRouter? router,
  }) {
    final resolvedLogger = logger ?? const DeveloperAppLogger();
    final resolvedApiClient = apiClient ?? ApiClient(logger: resolvedLogger);
    final resolvedAnalysisService = AnalysisService(
      apiClient: resolvedApiClient,
    );
    final resolvedPhotoGalleryService = PhotoGalleryService(
      apiClient: resolvedApiClient,
    );
    final resolvedMenuRepository =
        menuRepository ??
        ConfigMenuRepository(
          configService: ConfigService(
            apiClient: resolvedApiClient,
            logger: resolvedLogger,
          ),
        );
    final resolvedRouter =
        router ??
        AppRouter(
          analysisService: resolvedAnalysisService,
          photoGalleryService: resolvedPhotoGalleryService,
          apiClient: resolvedApiClient,
        );

    return AppDependencies._(
      logger: resolvedLogger,
      apiClient: resolvedApiClient,
      menuRepository: resolvedMenuRepository,
      analysisService: resolvedAnalysisService,
      photoGalleryService: resolvedPhotoGalleryService,
      router: resolvedRouter,
    );
  }

  AppDependencies._({
    required this.logger,
    required this.apiClient,
    required this.menuRepository,
    required this.analysisService,
    required this.photoGalleryService,
    required this.router,
  });

  final AppLogger logger;
  final ApiClient apiClient;
  final MenuRepository menuRepository;
  final AnalysisService analysisService;
  final PhotoGalleryService photoGalleryService;
  final AppRouter router;
  bool _closed = false;

  void close() {
    if (_closed) {
      return;
    }
    _closed = true;
    apiClient.close();
  }
}
