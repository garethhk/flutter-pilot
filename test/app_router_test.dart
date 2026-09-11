import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foo/models/menu.dart';
import 'package:foo/navigation/app_router.dart';

void main() {
  testWidgets('unknown menu routes are ignored safely', (tester) async {
    final observer = _RecordingObserver();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () =>
                AppRouter.openReport(context, Menu(router: 'unknown')),
            child: const Text('open'),
          ),
        ),
        navigatorObservers: [observer],
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    expect(observer.pushes, 1); // the initial MaterialApp route only
  });
}

class _RecordingObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}
