import 'dart:math';
import 'package:flutter/material.dart';
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
  int? _milestoneScore;
  late final AudioServiceInterface _audioService =
      widget._audioService ?? AudioService();

  /// Colors for 4, 6, or 8 cubes. Use sublist(0, numColors).
  static const _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.deepPurple,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _audioService.open());
  }

  @override
  void dispose() {
    _audioService.close();
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
    final numColors = widget.settingsService.current.numColors;
    setState(() {
      _gameState = _gameState.addRound(rng.nextInt(numColors), numColors: numColors);
    });
    await Future.delayed(const Duration(seconds: 1));
    _playSequence();
  }

  Future<void> _playSequence() async {
    final speed = widget.settingsService.current.speedMultiplier;
    var noteDisplay = (_noteDisplayMs(_gameState.score) / speed).round().clamp(80, 500);
    var pauseBetween = (_pauseMs(_gameState.score) / speed).round().clamp(50, 300);
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
    final numColors = widget.settingsService.current.numColors;
    if (index < 0 || index >= numColors) return;

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

    // Demo mode: when game not started, only play sound (no score impact)
    if (!_gameState.isPlaying) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) setState(() => pressedIndex = -1);
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => highlightedIndex = -1);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => pressedIndex = -1);
    await Future.delayed(const Duration(milliseconds: 180));
    setState(() => highlightedIndex = -1);

    final result = _gameState.processTap(index, numColors: numColors);
    if (result.result == TapResult.roundComplete) {
      setState(() => _gameState = result.newState);
      final isMilestone = _gameState.score % 5 == 0 && _gameState.score > 0;
      if (isMilestone) {
        setState(() => _milestoneScore = _gameState.score);
        if (widget.settingsService.current.soundEnabled) {
          try {
            await _audioService.playCongratsMelody();
          } catch (e) {
            debugPrint('Audio playCongratsMelody failed: $e');
          }
        }
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) setState(() => _milestoneScore = null);
      }
      if (isMilestone) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (mounted) _nextRound();
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
    return ValueListenableBuilder<AppSettings>(
      valueListenable: widget.settingsService.settings,
      builder: (context, appSettings, _) {
        final numColors = appSettings.numColors;
        const gridSpacing = 12.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
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
                    begin: pressedIndex == _startButtonIndex ? 1.0 : 0.95,
                    end: pressedIndex == _startButtonIndex ? 0.95 : 1.0,
                  ),
                  duration: Duration(
                    milliseconds: pressedIndex == _startButtonIndex ? 80 : 150,
                  ),
                  curve: pressedIndex == _startButtonIndex
                      ? Curves.easeIn
                      : Curves.easeOut,
                  builder: (context, scale, _) {
                    final primary =
                        Theme.of(context).colorScheme.primary;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          loc.start,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_milestoneScore != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          loc.milestoneLevel(
                              '${(_milestoneScore! ~/ 5) + 1}'),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Text(
                      '${_gameState.score}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.gameStatsService.highScore > 0) ...[
                      Text(
                        ' · ${widget.gameStatsService.highScore}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
        ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final rows = (numColors + 1) ~/ 2;
            const pad = 20.0;
            final bottomInset = MediaQuery.of(context).padding.bottom;
            final availW = constraints.maxWidth - pad * 2 - gridSpacing;
            final availH = constraints.maxHeight - pad * 2 - bottomInset - gridSpacing * (rows - 1);
            final sizeFromWidth = availW / 2;
            final sizeFromHeight = availH / rows;
            final buttonSize = sizeFromWidth < sizeFromHeight ? sizeFromWidth : sizeFromHeight;
            return Padding(
              padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + bottomInset),
              child: Center(
                child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: gridSpacing,
                  crossAxisSpacing: gridSpacing,
                  childAspectRatio: 1,
                  mainAxisExtent: buttonSize,
                ),
                itemCount: numColors,
                itemBuilder: (context, index) => ColorButton(
                  color: _colors[index],
                  isHighlighted: highlightedIndex == index,
                  showCorrectFlash: _lastCorrectIndex == index,
                  size: buttonSize,
                  onTap: () => _onColorTap(index),
                ),
              ),
            ),
            );
          },
        ),
      ),
    );
      },
    );
  }
}
