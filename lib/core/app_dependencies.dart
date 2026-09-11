import '../services/menu_repository.dart';

/// Composition root for application services.
class AppDependencies {
  const AppDependencies({this.menuRepository = const ConfigMenuRepository()});

  final MenuRepository menuRepository;
}
