import 'package:flutter_test/flutter_test.dart';
import 'package:foo/core/async_state.dart';

void main() {
  test('AsyncState preserves data while refreshing', () {
    const state = AsyncLoading<List<String>>(previous: ['cached']);

    expect(state.previous, ['cached']);
    expect(state, isA<AsyncLoading<List<String>>>());
  });

  test('AsyncError preserves stale data and diagnostics', () {
    final stack = StackTrace.current;
    final state = AsyncError<String>(
      StateError('offline'),
      previous: 'cached',
      stackTrace: stack,
    );

    expect(state.previous, 'cached');
    expect(state.error, isA<StateError>());
    expect(state.stackTrace, stack);
  });
}
