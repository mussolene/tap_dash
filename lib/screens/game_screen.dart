import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:tap_dash/game/game_state.dart' show GameState, TapResult;
import 'package:tap_dash/game/random_provider.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/screens/settings_screen.dart';
import 'package:tap_dash/services/audio_service.dart';
import 'package:tap_dash/services/audio_service_interface.dart';
import 'package:tap_dash/services/game_stats_service.dart';
import 'package:tap_dash/services/games_services_controller.dart';
import 'package:tap_dash/services/settings_service.dart';
import 'package:tap_dash/widgets/color_button.dart';
import 'package:vibration/vibration.dart';

/// Main game screen: color grid, sequence playback, user input, game over.
///
/// Owns [GameState] and updates UI based on [GameState.processTap] results.
/// Speed increases every 5 rounds via [_noteDisplayMs] and [_pauseMs].
class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.settingsService,
    required this.gameStatsService,
    AudioServiceInterface? audioService,
    RandomProvider? randomProvider,
    super.key,
  })  : _audioService = audioService,
        _randomProvider = randomProvider;

  final SettingsService settingsService;
  final GameStatsService gameStatsService;

  /// Optional; when null, uses [AudioService]. Inject mock for tests.
  final AudioServiceInterface? _audioService;

  /// Optional; when null, uses [Random]. Inject for deterministic tests.
  final RandomProvider? _randomProvider;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  /// Sentinel index for the Start button (not a color); used to avoid
  /// collision with color indices 0–3 when tracking [pressedIndex].
  static const _startButtonIndex = 99;

  GameState _gameState = const GameState();
  int highlightedIndex = -1;
  int pressedIndex = -1;
  int? _lastCorrectIndex;
  late final AudioServiceInterface _audioService =
      widget._audioService ?? AudioService();
  final _confettiController =
      ConfettiController(duration: const Duration(seconds: 1));

  static const _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _audioService.open());
  }

  @override
  void dispose() {
    _audioService.close();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    setState(() {
      _gameState = const GameState().startGame();
      highlightedIndex = -1;
      pressedIndex = -1;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    _nextRound();
  }

  /// Base duration (ms) to show each note; reduced every 5 rounds.
  static const _baseNoteDisplayMs = 350;
  /// Base pause (ms) between notes; reduced every 5 rounds.
  static const _basePauseMs = 200;
  static const _minNoteDisplayMs = 200;
  static const _minPauseMs = 100;

  /// Display duration per note; decreases by 30ms per tier (every 5 rounds).
  int _noteDisplayMs(int score) {
    final tier = score ~/ 5;
    final reduction = tier * 30;
    return (_baseNoteDisplayMs - reduction).clamp(_minNoteDisplayMs, 500);
  }

  /// Pause between notes; decreases by 20ms per tier (every 5 rounds).
  int _pauseMs(int score) {
    final tier = score ~/ 5;
    final reduction = tier * 20;
    return (_basePauseMs - reduction).clamp(_minPauseMs, 300);
  }

  Future<void> _nextRound() async {
    final rng = widget._randomProvider ?? DefaultRandomProvider();
    setState(() {
      _gameState = _gameState.addRound(rng.nextInt(4));
    });
    await Future.delayed(const Duration(seconds: 1));
    _playSequence();
  }

  Future<void> _playSequence() async {
    final noteDisplay = _noteDisplayMs(_gameState.score);
    final pauseBetween = _pauseMs(_gameState.score);
    final soundDuration = (noteDisplay * 0.5).round().clamp(120, 180);

    for (final index in _gameState.sequence) {
      setState(() {
        highlightedIndex = index;
        pressedIndex = index;
      });
      if (widget.settingsService.current.soundEnabled) {
        try {
          await _audioService.playNote(index, durationMs: soundDuration);
        } catch (e) {
          debugPrint('Audio playNote failed: $e');
        }
      }
      if (widget.settingsService.current.hapticsEnabled &&
          (await Vibration.hasVibrator() ?? false)) {
        Vibration.vibrate(duration: 80);
      }
      await Future.delayed(Duration(milliseconds: noteDisplay));
      setState(() {
        highlightedIndex = -1;
        pressedIndex = -1;
      });
      await Future.delayed(Duration(milliseconds: pauseBetween));
    }
    setState(() {});
  }

  Future<void> _onColorTap(int index) async {
    if (!_gameState.isPlaying) return;

    setState(() {
      highlightedIndex = index;
      pressedIndex = index;
    });

    if (widget.settingsService.current.hapticsEnabled &&
        (await Vibration.hasVibrator() ?? false)) {
      Vibration.vibrate(duration: 60);
    }

    if (widget.settingsService.current.soundEnabled) {
      try {
        await _audioService.playNote(index, durationMs: 180);
      } catch (e) {
        debugPrint('Audio playNote failed: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => pressedIndex = -1);
    await Future.delayed(const Duration(milliseconds: 180));
    setState(() => highlightedIndex = -1);

    final result = _gameState.processTap(index);
    if (result.result == TapResult.roundComplete) {
      setState(() => _gameState = result.newState);
      if (_gameState.score % 5 == 0) {
        _confettiController.play();
        if (widget.settingsService.current.soundEnabled) {
          try {
            await _audioService.playCongratsMelody();
          } catch (e) {
            debugPrint('Audio playCongratsMelody failed: $e');
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.congratsScore(
                  '${_gameState.score}',
                ),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      _nextRound();
    } else if (result.result == TapResult.wrong) {
      setState(() {
        highlightedIndex = -1;
        pressedIndex = -1;
        _gameState = result.newState;
      });
      if (widget.settingsService.current.soundEnabled) {
        try {
          await _audioService.playWrongNote();
        } catch (e) {
          debugPrint('Audio playWrongNote failed: $e');
        }
      }
      final wasNewRecord =
          await widget.gameStatsService.recordGame(_gameState.score);
      if (wasNewRecord) {
        GamesServicesController.instance.submitScore(_gameState.score);
      }
      if (mounted) _showGameOverDialog(wasNewRecord);
    } else {
      setState(() {
        _gameState = result.newState;
        _lastCorrectIndex = index;
      });
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _lastCorrectIndex = null);
      });
    }
  }

  void _showGameOverDialog(bool wasNewRecord) {
    final loc = AppLocalizations.of(context)!;
    final highScore = widget.gameStatsService.highScore;
    final score = _gameState.score;

    String subtitle;
    String motivational;
    if (wasNewRecord) {
      subtitle = loc.newRecord('$score');
      motivational = loc.greatRun;
    } else if (highScore > 0) {
      subtitle = loc.scoreVsBest('$highScore', '$score');
      final diff = highScore - score;
      motivational = diff <= 2
          ? loc.soClose
          : diff <= 5
              ? loc.almostThere
              : loc.greatRun;
    } else {
      subtitle = loc.yourScore('$score');
      motivational = loc.greatRun;
    }

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            ),
            child: AlertDialog(
              title: Text(loc.gameOver),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(motivational,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(subtitle),
                  if (highScore > 0 && !wasNewRecord) ...[
                    const SizedBox(height: 4),
                    Text(
                      loc.awayFromBest('${highScore - score}'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.close),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startGame();
                  },
                  child: Text(loc.playAgain),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final buttonSize = size.width / 2.5;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => SettingsScreen(
                    settingsService: widget.settingsService,
                    onShowLeaderboard: () =>
                        GamesServicesController.instance.showLeaderboards(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 90,
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_gameState.score}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.gameStatsService.highScore > 0)
                        Text(
                          loc.bestScore(
                              '${widget.gameStatsService.highScore}'),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.75),
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => ColorButton(
                  color: _colors[index],
                  isHighlighted: highlightedIndex == index,
                  showCorrectFlash: _lastCorrectIndex == index,
                  size: buttonSize,
                  onTap: () => _onColorTap(index),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTapDown: (_) async {
                  setState(() => pressedIndex = _startButtonIndex);
                  if (widget.settingsService.current.hapticsEnabled &&
                      (await Vibration.hasVibrator() ?? false)) {
                    Vibration.vibrate(duration: 40);
                  }
                },
                onTapUp: (_) => setState(() => pressedIndex = -1),
                onTapCancel: () => setState(() => pressedIndex = -1),
                onTap: _startGame,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(pressedIndex == _startButtonIndex),
                  tween: Tween(
                    begin: pressedIndex == _startButtonIndex ? 1.0 : 0.93,
                    end: pressedIndex == _startButtonIndex ? 0.93 : 1.0,
                  ),
                  duration: Duration(
                    milliseconds: pressedIndex == _startButtonIndex ? 80 : 180,
                  ),
                  curve: pressedIndex == _startButtonIndex
                      ? Curves.easeIn
                      : Curves.elasticOut,
                  builder: (context, scale, child) {
                    final isPressed = pressedIndex == _startButtonIndex;
                    final primary = Theme.of(context).colorScheme.primary;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isPressed ? 0.10 : 0.25,
                              ),
                              blurRadius: isPressed ? 4 : 12,
                              offset: Offset(0, isPressed ? 2 : 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 16,
                        ),
                        child: Text(
                          loc.start,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 8,
              minBlastForce: 3,
              emissionFrequency: 0.03,
              numberOfParticles: 35,
              gravity: 0.08,
            ),
          ),
        ],
        ),
      ),
    );
  }
}
