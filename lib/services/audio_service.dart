import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

const _xyloNotes = [261.63, 329.63, 392.00, 493.88]; // C4, E4, G4, B4

/// Service for synthesized xylophone-style audio.
/// Manages player lifecycle; call [dispose] when done.
class AudioService {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  Future<void> open() => _player.openPlayer();
  Future<void> close() => _player.closePlayer();

  Future<void> playNote(int colorIndex, {int durationMs = 180}) async {
    if (colorIndex < 0 || colorIndex >= _xyloNotes.length) return;
    await _playXyloNote(_xyloNotes[colorIndex], durationMs);
  }

  Future<void> playCongratsMelody() async {
    await _playXyloNote(261.63, 150); // C4
    await _playXyloNote(329.63, 150); // E4
    await _playXyloNote(392.00, 150); // G4
    await _playXyloNote(523.25, 300); // C5
  }

  Future<void> _playXyloNote(double freq, int durationMs) async {
    const int sampleRate = 44100;
    final sampleCount = (sampleRate * durationMs / 1000).round();
    final buffer = Float64List(sampleCount);

    for (int i = 0; i < sampleCount; i++) {
      final envelope = exp(-3 * i / sampleCount);
      buffer[i] = sin(2 * pi * freq * i / sampleRate) * envelope;
    }

    final pcmBuffer = Int16List(sampleCount);
    for (int i = 0; i < sampleCount; i++) {
      pcmBuffer[i] = (buffer[i] * 32767).toInt();
    }

    await _player.startPlayer(
      fromDataBuffer: Uint8List.view(pcmBuffer.buffer),
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: 1,
    );
    await Future.delayed(Duration(milliseconds: durationMs));
    await _player.stopPlayer();
  }
}
