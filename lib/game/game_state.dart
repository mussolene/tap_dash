// Pure game logic for Color Sequence Game.
// No Flutter or platform dependencies.

/// Result of processing a color tap.
enum TapResult {
  correct,
  roundComplete,
  wrong,
}

class GameState {
  final List<int> sequence;
  final int score;
  final int currentStep;
  final bool isPlaying;

  const GameState({
    this.sequence = const [],
    this.score = 0,
    this.currentStep = 0,
    this.isPlaying = false,
  });

  /// Creates initial state for a new game.
  GameState startGame() => GameState(isPlaying: true);

  /// Adds a new color to the sequence and starts a new round.
  /// [nextColor] must be 0-3 (indices for the 4 colors).
  GameState addRound(int nextColor) {
    if (nextColor < 0 || nextColor > 3) {
      throw RangeError('nextColor must be 0-3, got $nextColor');
    }
    final newSequence = [...sequence, nextColor];
    return copyWith(
      sequence: newSequence,
      currentStep: 0,
    );
  }

  /// Processes a color tap. Returns the result and the new state (for roundComplete/wrong).
  /// For [correct], the state is updated in-place; call [processTap] again for subsequent taps.
  ({TapResult result, GameState newState}) processTap(int index) {
    if (!isPlaying || index < 0 || index > 3) {
      return (result: TapResult.wrong, newState: this);
    }
    if (sequence.isEmpty) {
      return (result: TapResult.wrong, newState: this);
    }
    if (sequence[currentStep] != index) {
      return (
        result: TapResult.wrong,
        newState: copyWith(isPlaying: false),
      );
    }
    final nextStep = currentStep + 1;
    if (nextStep == sequence.length) {
      return (
        result: TapResult.roundComplete,
        newState: copyWith(score: score + 1, currentStep: 0),
      );
    }
    return (
      result: TapResult.correct,
      newState: copyWith(currentStep: nextStep),
    );
  }

  GameState copyWith({
    List<int>? sequence,
    int? score,
    int? currentStep,
    bool? isPlaying,
  }) =>
      GameState(
        sequence: sequence ?? this.sequence,
        score: score ?? this.score,
        currentStep: currentStep ?? this.currentStep,
        isPlaying: isPlaying ?? this.isPlaying,
      );
}
