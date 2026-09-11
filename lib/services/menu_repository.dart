import '../models/menu.dart';
import 'config.dart';

abstract interface class MenuRepository {
  List<Menu> get localMenu;
  Future<List<Menu>> fetchMenu();
}

final class ConfigMenuRepository implements MenuRepository {
  const ConfigMenuRepository();

  @override
  List<Menu> get localMenu => ConfigService.getLocalMenu();

  @override
  Future<List<Menu>> fetchMenu() => ConfigService.getMenu();
}
