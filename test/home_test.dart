import 'package:flutter_test/flutter_test.dart';
import 'package:foo/core/app_dependencies.dart';
import 'package:foo/main.dart';
import 'package:foo/models/menu.dart';
import 'package:foo/services/menu_repository.dart';

class _FakeMenuRepository implements MenuRepository {
  @override
  final localMenu = <Menu>[];

  @override
  Future<List<Menu>> fetchMenu() async => [
    Menu(
      id: 'injected',
      group: 1,
      groupName: 'Injected',
      name: 'Injected report',
      router: 'unknown',
    ),
  ];
}

void main() {
  testWidgets('Home renders menu supplied by an injected repository', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        dependencies: AppDependencies(menuRepository: _FakeMenuRepository()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Injected report'), findsOneWidget);
    expect(find.text('Injected'), findsOneWidget);
  });
}
