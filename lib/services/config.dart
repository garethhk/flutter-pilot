import '../constants/report_type.dart';
import '../core/app_logger.dart';
import '../models/menu.dart';
import 'api_client.dart';

class ConfigService {
  ConfigService({required this.apiClient, required this.logger});

  final ApiClient apiClient;
  final AppLogger logger;

  List<Menu> getLocalMenu() => reportTypes
      .map((item) => Menu.fromJson(Map<String, dynamic>.from(item)))
      .toList();

  Future<List<Menu>> fetchMenu() async {
    final menus = getLocalMenu();
    try {
      final data = await apiClient.get(Uri.parse(menuUrl));
      if (data is! List) {
        throw const FormatException('Expected menu list');
      }
      for (final json in data) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Expected menu object');
        }
        final item = Menu.fromJson(json);
        if (item.id.isEmpty) {
          continue;
        }
        final index = menus.indexWhere((local) => local.id == item.id);
        if (index == -1) {
          menus.add(item);
        } else if (item.version > menus[index].version) {
          menus[index] = item;
        }
      }
      return menus;
    } on Object catch (error, stackTrace) {
      logger.warning(
        'Remote menu unavailable; using bundled menu',
        error: error,
        stackTrace: stackTrace,
      );
      return getLocalMenu();
    }
  }
}
