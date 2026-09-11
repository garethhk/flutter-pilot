import '../models/menu.dart';
import 'config.dart';

abstract interface class MenuRepository {
  List<Menu> get localMenu;
  Future<List<Menu>> fetchMenu();
}

final class ConfigMenuRepository implements MenuRepository {
  const ConfigMenuRepository({required this.configService});

  final ConfigService configService;

  @override
  List<Menu> get localMenu => configService.getLocalMenu();

  @override
  Future<List<Menu>> fetchMenu() => configService.fetchMenu();
}
