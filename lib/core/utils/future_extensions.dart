/// Extension on Future to provide utility methods.
extension FutureExtensions<T> on Future<T> {
  /// Silently ignore the result of this future.
  /// This is useful when you want to fire and forget a future.
  void ignore() {
    // ignore: unawaited_futures
    then((_) => null);
  }
}
