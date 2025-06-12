import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:confetti/confetti.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

const xyloNotes = [261.63, 329.63, 392.00, 493.88]; // C4, E4, G4, B4

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocalizations.of(context)?.appTitle ?? 'Color Sequence Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
        ),
        cardColor: Colors.grey[850],
        dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
      ),
      themeMode: ThemeMode.system, // <-- автоматический выбор темы
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      home: ColorSequenceGame(),
    );
  }
}

class ColorSequenceGame extends StatefulWidget {
  const ColorSequenceGame({super.key});

  @override
  _ColorSequenceGameState createState() => _ColorSequenceGameState();
}

class _ColorSequenceGameState extends State<ColorSequenceGame> {
  bool isPlaying = false;
  int currentStep = 0;
  List<int> sequence = [];
  int score = 0;
  int highlightedIndex = -1;
  int pressedIndex = -1;
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow
  ];
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await synthPlayer.openPlayer();
    });
  }

  @override
  void dispose() {
    synthPlayer.closePlayer();
    _confettiController.dispose();
    super.dispose();
  }

  void startGame() async {
    setState(() {
      score = 0;
      sequence = [];
      isPlaying = true;
      currentStep = 0;
      highlightedIndex = -1;
      pressedIndex = -1;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    nextRound();
  }

  void nextRound() async {
    setState(() {
      sequence.add(Random().nextInt(4));
      currentStep = 0;
    });
    await Future.delayed(const Duration(seconds: 1));
    playSequence();
  }

  Future<void> playSequence() async {
    for (int index in sequence) {
      setState(() {
        highlightedIndex = index;
        pressedIndex = index;
      });
      try {
        await playXyloNote(xyloNotes[index], 180);
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
    setState(() {
      currentStep = 0;
    });
  }

  Future<void> onColorTap(int index) async {
    if (!isPlaying) return;

    setState(() {
      highlightedIndex = index;
      pressedIndex = index;
    });

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 60);
    }

    try {
      await playXyloNote(xyloNotes[index], 180);
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 120));
    setState(() {
      pressedIndex = -1;
    });

    await Future.delayed(const Duration(milliseconds: 180));
    setState(() {
      highlightedIndex = -1;
    });

    if (sequence[currentStep] == index) {
      currentStep++;
      if (currentStep == sequence.length) {
        setState(() {
          score++;
        });
        if (score % 5 == 0) {
          _confettiController.play();
          try {
            await playCongratsMelody();
          } catch (_) {}
        }
        nextRound();
      }
    } else {
      setState(() {
        highlightedIndex = -1;
        pressedIndex = -1;
        isPlaying = false;
      });
      showGameOverDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final double buttonSize = MediaQuery.of(context).size.width / 2.5;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
      ),
      body: Stack(
        children: [
          Column(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '${loc.score}: $score',
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return ColorButton(
                    color: colors[index],
                    isHighlighted: highlightedIndex == index,
                    size: buttonSize,
                    onTap: () => onColorTap(index),
                  );
                },
              ),
              SizedBox(height: 24),
              GestureDetector(
                onTapDown: (_) async {
                  setState(() => pressedIndex = 99);
                  if (await Vibration.hasVibrator() ?? false) {
                    Vibration.vibrate(duration: 40);
                  }
                },
                onTapUp: (_) => setState(() => pressedIndex = -1),
                onTapCancel: () => setState(() => pressedIndex = -1),
                onTap: startGame,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  curve: Curves.ease,
                  transform: pressedIndex == 99
                      ? (Matrix4.identity()..scale(0.93))
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(pressedIndex == 99 ? 0.10 : 0.25),
                        blurRadius: pressedIndex == 99 ? 4 : 12,
                        offset: Offset(0, pressedIndex == 99 ? 2 : 6),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  child: Text(
                    loc.start,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
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

  void showGameOverDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.gameOver),
          content: Text(loc.yourScore('$score')),
          actions: [
            TextButton(
              child: Text(loc.restart),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
            TextButton(
              child: Text(loc.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showCongratsDialog() async {
    final loc = AppLocalizations.of(context)!;
    _confettiController.play();
    await playCongratsMelody();
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(pattern: [0, 60, 40, 80]);
    } else if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.congrats),
          content: Text(loc.congratsScore('$score')),
          actions: [
            TextButton(
              child: Text(loc.close),
              onPressed: () {
                Navigator.of(context).pop();
                nextRound();
              },
            ),
          ],
        );
      },
    );
  }
}

class ColorButton extends StatefulWidget {
  final Color color;
  final bool isHighlighted;
  final double size;
  final VoidCallback onTap;

  const ColorButton({
    required this.color,
    required this.isHighlighted,
    required this.size,
    required this.onTap,
    super.key,
  });

  @override
  State<ColorButton> createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {
  bool _isPressed = false;

  void _handleTap() async {
    setState(() => _isPressed = true);

    // Тактильная отдача
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(pattern: [0, 40, 20, 40]); // двойной "клёвый" отклик
    } else if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 40); // обычная короткая
    }

    widget.onTap();
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        curve: Curves.ease,
        transform:
            _isPressed ? (Matrix4.identity()..scale(0.93)) : Matrix4.identity(),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.isHighlighted
              ? widget.color.withAlpha((0.5 * 255).toInt())
              : widget.color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withAlpha((_isPressed ? 0.10 : 0.25) * 255 ~/ 1),
              blurRadius: _isPressed ? 4 : 12,
              offset: Offset(0, _isPressed ? 2 : 6),
            ),
          ],
        ),
        child: widget.isHighlighted
            ? SpinKitPulse(color: widget.color, size: widget.size)
            : null,
      ),
    );
  }
}

final FlutterSoundPlayer synthPlayer = FlutterSoundPlayer();

Future<void> playXyloNote(double freq, int durationMs) async {
  const int sampleRate = 44100;
  int sampleCount = (sampleRate * durationMs / 1000).round();
  final buffer = Float64List(sampleCount);

  // Генерируем синусоиду с экспоненциальным затуханием (envelope)
  for (int i = 0; i < sampleCount; i++) {
    double envelope = exp(-3 * i / sampleCount); // быстрое затухание
    buffer[i] = sin(2 * pi * freq * i / sampleRate) * envelope;
  }

  // Преобразуем в 16-битный PCM
  final pcmBuffer = Int16List(sampleCount);
  for (int i = 0; i < sampleCount; i++) {
    pcmBuffer[i] = (buffer[i] * 32767).toInt();
  }

  await synthPlayer.startPlayer(
    fromDataBuffer: Uint8List.view(pcmBuffer.buffer),
    codec: Codec.pcm16,
    sampleRate: sampleRate,
    numChannels: 1,
  );
  await Future.delayed(Duration(milliseconds: durationMs));
  await synthPlayer.stopPlayer();
}

Future<void> playCongratsMelody() async {
  await playXyloNote(261.63, 150); // C4
  await playXyloNote(329.63, 150); // E4
  await playXyloNote(392.00, 150); // G4
  await playXyloNote(523.25, 300); // C5
}
