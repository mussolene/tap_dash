import 'dart:math';

/// Abstraction for random number generation. Enables deterministic tests.
abstract class RandomProvider {
  int nextInt(int max);
}

/// Default implementation using [Random]. Used when no provider is injected.
class DefaultRandomProvider implements RandomProvider {
  final _r = Random();

  @override
  int nextInt(int max) => _r.nextInt(max);
}
