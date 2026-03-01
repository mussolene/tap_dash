import 'package:tap_dash/game/random_provider.dart';
import 'package:tap_dash/services/audio_service_interface.dart';

/// No-op implementation for widget tests. Avoids FlutterSound platform usage.
class MockAudioService implements AudioServiceInterface {
  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> playNote(int colorIndex, {int durationMs = 180}) async {}

  @override
  Future<void> playCongratsMelody() async {}

  @override
  Future<void> playWrongNote() async {}
}

/// Returns fixed sequence for deterministic game tests.
class DeterministicRandomProvider implements RandomProvider {
  DeterministicRandomProvider(this._values);
  final List<int> _values;
  int _idx = 0;

  @override
  int nextInt(int max) => _values[_idx++ % _values.length];
}
