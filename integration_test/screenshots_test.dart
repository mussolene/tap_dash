import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Takes screenshots for README: onboarding, game, settings.
/// Run: `flutter drive --driver=test_driver/integration_test.dart
///        --target=integration_test/screenshots_test.dart -d [device]`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture screenshots for README', (tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final binding = IntegrationTestWidgetsFlutterBinding.instance;
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    // 1. Onboarding (first launch)
    if (find.byType(FilledButton).evaluate().isNotEmpty) {
      await binding.takeScreenshot('onboarding_screen');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // 2. Game screen
    await binding.takeScreenshot('game_screen');

    // 3. Settings screen (only if settings icon visible)
    if (find.byIcon(Icons.settings).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('settings_screen');
    }
  });
}
