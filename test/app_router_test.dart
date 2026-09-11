import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pilot/models/menu.dart';
import 'package:flutter_pilot/navigation/app_router.dart';
import 'package:flutter_pilot/services/analysis.dart';
import 'package:flutter_pilot/services/api_client.dart';
import 'package:flutter_pilot/services/photo_gallery.dart';
import 'package:http/testing.dart';

void main() {
  testWidgets('unknown menu routes are ignored safely', (tester) async {
    final observer = _RecordingObserver();
    final apiClient = ApiClient(
      client: MockClient((_) async => throw StateError('unused')),
    );
    final router = AppRouter(
      analysisService: AnalysisService(apiClient: apiClient),
      photoGalleryService: PhotoGalleryService(apiClient: apiClient),
      apiClient: apiClient,
    );
    addTearDown(apiClient.close);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () =>
                router.openReport(context, Menu(router: 'unknown')),
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
