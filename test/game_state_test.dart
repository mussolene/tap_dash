import 'package:flutter_test/flutter_test.dart';
import 'package:tap_dash/game/game_state.dart' show GameState, TapResult;

void main() {
  group('GameState', () {
    test('startGame sets isPlaying to true and resets state', () {
      final state = GameState(
        sequence: [1, 2],
        score: 5,
        currentStep: 1,
        isPlaying: false,
      );
      final started = state.startGame();

      expect(started.isPlaying, isTrue);
      expect(started.sequence, isEmpty);
      expect(started.score, 0);
      expect(started.currentStep, 0);
    });

    test('addRound appends color and resets currentStep', () {
      final state = GameState(sequence: [0, 1], isPlaying: true, currentStep: 2);
      final next = state.addRound(3);

      expect(next.sequence, [0, 1, 3]);
      expect(next.currentStep, 0);
    });

    test('addRound throws for invalid color index', () {
      final state = GameState(isPlaying: true);
      expect(() => state.addRound(4), throwsRangeError);
      expect(() => state.addRound(-1), throwsRangeError);
    });

    test('processTap returns wrong when color does not match', () {
      final state = GameState(
        sequence: [0, 1, 2],
        isPlaying: true,
        currentStep: 1,
      );
      final result = state.processTap(2); // Expected 1 at step 1

      expect(result.result, TapResult.wrong);
      expect(result.newState.isPlaying, isFalse);
    });

    test('processTap returns correct for matching non-final tap', () {
      final state = GameState(
        sequence: [0, 1, 2],
        isPlaying: true,
        currentStep: 0,
      );
      final result = state.processTap(0);

      expect(result.result, TapResult.correct);
      expect(result.newState.currentStep, 1);
      expect(result.newState.score, 0);
    });

    test('processTap returns roundComplete when sequence is fully repeated', () {
      final state = GameState(
        sequence: [0, 1],
        score: 2,
        isPlaying: true,
        currentStep: 1,
      );
      final result = state.processTap(1); // Last color in sequence

      expect(result.result, TapResult.roundComplete);
      expect(result.newState.score, 3);
      expect(result.newState.currentStep, 0);
    });

    test('processTap returns wrong when not playing', () {
      final state = GameState(sequence: [0], isPlaying: false);
      final result = state.processTap(0);

      expect(result.result, TapResult.wrong);
    });

    test('processTap returns wrong for invalid index', () {
      final state = GameState(sequence: [0, 1], isPlaying: true);
      expect(state.processTap(4).result, TapResult.wrong);
      expect(state.processTap(-1).result, TapResult.wrong);
    });

    test('processTap returns wrong for empty sequence', () {
      final state = GameState(sequence: [], isPlaying: true);
      final result = state.processTap(0);
      expect(result.result, TapResult.wrong);
    });
  });
}
