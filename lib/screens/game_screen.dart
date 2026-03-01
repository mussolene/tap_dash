import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:tap_dash/game/game_state.dart' show GameState, TapResult;
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/services/audio_service.dart';
import 'package:tap_dash/widgets/color_button.dart';
import 'package:vibration/vibration.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState _gameState = const GameState();
  int highlightedIndex = -1;
  int pressedIndex = -1;
  final _audioService = AudioService();
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

  Future<void> _nextRound() async {
    setState(() {
      _gameState = _gameState.addRound(Random().nextInt(4));
    });
    await Future.delayed(const Duration(seconds: 1));
    _playSequence();
  }

  Future<void> _playSequence() async {
    for (final index in _gameState.sequence) {
      setState(() {
        highlightedIndex = index;
        pressedIndex = index;
      });
      try {
        await _audioService.playNote(index, durationMs: 180);
      } catch (_) {}
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 80);
      }
      await Future.delayed(const Duration(milliseconds: 350));
      setState(() {
        highlightedIndex = -1;
        pressedIndex = -1;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }
    setState(() {});
  }

  Future<void> _onColorTap(int index) async {
    if (!_gameState.isPlaying) return;

    setState(() {
      highlightedIndex = index;
      pressedIndex = index;
    });

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 60);
    }

    try {
      await _audioService.playNote(index, durationMs: 180);
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => pressedIndex = -1);
    await Future.delayed(const Duration(milliseconds: 180));
    setState(() => highlightedIndex = -1);

    final result = _gameState.processTap(index);
    if (result.result == TapResult.roundComplete) {
      setState(() => _gameState = result.newState);
      if (_gameState.score % 5 == 0) {
        _confettiController.play();
        try {
          await _audioService.playCongratsMelody();
        } catch (_) {}
      }
      _nextRound();
    } else if (result.result == TapResult.wrong) {
      setState(() {
        highlightedIndex = -1;
        pressedIndex = -1;
        _gameState = result.newState;
      });
      _showGameOverDialog();
    } else {
      setState(() => _gameState = result.newState);
    }
  }

  void _showGameOverDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.gameOver),
        content: Text(loc.yourScore('${_gameState.score}')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: Text(loc.restart),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.close),
          ),
        ],
      ),
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 32,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${loc.score}: ${_gameState.score}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                  size: buttonSize,
                  onTap: () => _onColorTap(index),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTapDown: (_) async {
                  setState(() => pressedIndex = 99);
                  if (await Vibration.hasVibrator() ?? false) {
                    Vibration.vibrate(duration: 40);
                  }
                },
                onTapUp: (_) => setState(() => pressedIndex = -1),
                onTapCancel: () => setState(() => pressedIndex = -1),
                onTap: _startGame,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.ease,
                  transform: pressedIndex == 99
                      ? (Matrix4.identity()..scaleByDouble(0.93, 0.93, 1.0, 1.0))
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: pressedIndex == 99 ? 0.10 : 0.25,
                        ),
                        blurRadius: pressedIndex == 99 ? 4 : 12,
                        offset: Offset(0, pressedIndex == 99 ? 2 : 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 16,
                  ),
                  child: Text(
                    loc.start,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
