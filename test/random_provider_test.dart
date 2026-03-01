import 'package:flutter_test/flutter_test.dart';
import 'package:tap_dash/game/random_provider.dart';

import 'mock_audio_service.dart';

void main() {
  group('DeterministicRandomProvider', () {
    test('returns fixed sequence', () {
      final provider = DeterministicRandomProvider([0, 2, 1, 3]);
      expect(provider.nextInt(4), 0);
      expect(provider.nextInt(4), 2);
      expect(provider.nextInt(4), 1);
      expect(provider.nextInt(4), 3);
    });

    test('cycles when exhausted', () {
      final provider = DeterministicRandomProvider([1]);
      expect(provider.nextInt(4), 1);
      expect(provider.nextInt(4), 1);
    });
  });

  group('DefaultRandomProvider', () {
    test('returns values in range', () {
      final provider = DefaultRandomProvider();
      for (var i = 0; i < 100; i++) {
        final v = provider.nextInt(4);
        expect(v, greaterThanOrEqualTo(0));
        expect(v, lessThan(4));
      }
    });
  });
}
