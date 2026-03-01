import 'package:flutter/material.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/services/game_stats_service.dart';
import 'package:tap_dash/services/settings_service.dart';
import 'package:tap_dash/widgets/color_button.dart';

/// "How to play" welcome screen shown on first launch.
///
/// Displays animated demo sequence (red → green → blue) via [_onDemoTick].
/// On "Start" tap, marks onboarding as seen and calls [onComplete].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.settingsService,
    required this.gameStatsService,
    required this.onComplete,
    super.key,
  });

  final SettingsService settingsService;
  final GameStatsService gameStatsService;
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const _demoColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];

  late AnimationController _demoController;
  int _demoHighlightIndex = -1;

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: false);
    _demoController.addListener(_onDemoTick);
  }

  /// Demo animation: step 0→index 0 (red), step 2→index 1 (green), step 4→index 2 (blue).
  /// step = (progress * 8).floor() % 6; other steps show no highlight (-1).
  void _onDemoTick() {
    final progress = _demoController.value;
    final step = (progress * 8).floor() % 6;
    final newIndex = step == 0
        ? 0
        : step == 2
            ? 1
            : step == 4
                ? 2
                : -1;
    if (newIndex != _demoHighlightIndex && mounted) {
      setState(() => _demoHighlightIndex = newIndex);
    }
  }

  @override
  void dispose() {
    _demoController.removeListener(_onDemoTick);
    _demoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final buttonSize = size.width / 2.5;

    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  loc.howToPlay,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 40),
                _StepRow(
                  number: 1,
                  text: loc.onboardingStep1,
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: buttonSize * 2 + 16,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) => ColorButton(
                        color: _demoColors[index],
                        isHighlighted: _demoHighlightIndex == index,
                        size: buttonSize,
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _StepRow(
                  number: 2,
                  text: loc.onboardingStep2,
                ),
                const SizedBox(height: 16),
                _StepRow(
                  number: 3,
                  text: loc.onboardingStep3,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    await widget.gameStatsService.setHasSeenOnboarding();
                    widget.onComplete();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: Text(loc.start),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }
}
