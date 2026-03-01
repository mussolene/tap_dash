import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

import 'audio_service_interface.dart';

// C4, D4, E4, F4, G4, A4, B4, C5 — supports up to 8 colors
const _xyloNotes = [
  261.63, 293.66, 329.63, 349.23,
  392.00, 440.00, 493.88, 523.25,
];

/// Service for synthesized xylophone-style audio.
/// Manages player lifecycle; call [close] when done.
class AudioService implements AudioServiceInterface {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  @override
  Future<void> open() => _player.openPlayer();

  @override
  Future<void> close() => _player.closePlayer();

  @override
  Future<void> playNote(int colorIndex, {int durationMs = 180}) async {
    if (colorIndex < 0 || colorIndex >= _xyloNotes.length) return;
    await _playXyloNote(_xyloNotes[colorIndex], durationMs);
  }

  @override
  Future<void> playCongratsMelody() async {
    await _playXyloNote(261.63, 150); // C4
    await _playXyloNote(329.63, 150); // E4
    await _playXyloNote(392.00, 150); // G4
    await _playXyloNote(523.25, 300); // C5
  }

  /// Low buzz sound for wrong tap / game over.
  @override
  Future<void> playWrongNote() async {
    const int sampleRate = 44100;
    const int durationMs = 180;
    final sampleCount = (sampleRate * durationMs / 1000).round();
    final buffer = Float64List(sampleCount);
    const freq = 120.0; // Low frequency for error feel

    for (int i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;
      final envelope = exp(-4 * i / sampleCount);
      buffer[i] = sin(2 * pi * freq * t) * envelope * 0.7;
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
    await Future.delayed(const Duration(milliseconds: durationMs));
    await _player.stopPlayer();
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
