sealed class AsyncState<T> {
  const AsyncState();
}

final class AsyncData<T> extends AsyncState<T> {
  const AsyncData(this.value);
  final T value;
}

final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading({this.previous});
  final T? previous;
}

final class AsyncError<T> extends AsyncState<T> {
  const AsyncError(this.error, {this.previous, this.stackTrace});
  final Object error;
  final T? previous;
  final StackTrace? stackTrace;
}
