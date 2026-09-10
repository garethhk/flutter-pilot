import '../constants/reportType.dart';
import '../models/menu.dart';
import 'api_client.dart';

class ConfigService {
  static List<Menu> getLocalMenu() => REPORT_TYPES
      .map((item) => Menu.fromJson(Map<String, dynamic>.from(item)))
      .toList();
  static Future<List<Menu>> getMenu() async {
    final menus = getLocalMenu();
    try {
      final data = await ApiClient.get(Uri.parse(MEMU_URL));
      if (data is! List) throw const FormatException('Expected menu list');
      for (final json in data) {
        if (json is! Map<String, dynamic>)
          throw const FormatException('Expected menu object');
        final item = Menu.fromJson(json);
        if (item.id.isEmpty) continue;
        final index = menus.indexWhere((local) => local.id == item.id);
        if (index == -1) {
          menus.add(item);
        } else if (item.version > menus[index].version) {
          menus[index] = item;
        }
      }
      return menus;
    } on Exception {
      return getLocalMenu();
    }
  }
}
