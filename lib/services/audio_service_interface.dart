/// Abstract interface for audio playback.
///
/// Implementations: [AudioService] (real). For tests, use a no-op mock.
abstract class AudioServiceInterface {
  Future<void> open();
  Future<void> close();
  Future<void> playNote(int colorIndex, {int durationMs = 180});
  Future<void> playCongratsMelody();
  Future<void> playWrongNote();
}
