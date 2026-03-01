import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

bool get _isMobile {
  if (kIsWeb) return false;
  // Use defaultTargetPlatform - avoids dart:io for web compatibility
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}

/// Leaderboard IDs from App Store Connect (iOS) and Google Play Console (Android).
/// Replace with your actual IDs after creating leaderboards in developer consoles.
/// See: https://docs.flutter.dev/cookbook/games/achievements-leaderboard
const _iosLeaderboardId = 'tap_dash_high_score';
const _androidLeaderboardId = 'tap_dash_high_score';

/// Facade for Game Center (iOS) and Google Play Games (Android).
class GamesServicesController {
  GamesServicesController._();
  static final GamesServicesController _instance = GamesServicesController._();
  static GamesServicesController get instance => _instance;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  /// Call after app start. Sign-in is async and non-blocking.
  Future<void> initialize() async {
    if (!_isMobile) return;
    try {
      await GameAuth.signIn();
      _isSignedIn = await GameAuth.isSignedIn;
      debugPrint('GamesServices: signed in = $_isSignedIn');
    } catch (e) {
      debugPrint('GamesServices sign-in failed: $e');
      _isSignedIn = false;
    }
  }

  /// Submit score to leaderboard.
  Future<void> submitScore(int score) async {
    if (!_isSignedIn) return;
    try {
      await Leaderboards.submitScore(
        score: Score(
          iOSLeaderboardID: _iosLeaderboardId,
          androidLeaderboardID: _androidLeaderboardId,
          value: score,
        ),
      );
      debugPrint('GamesServices: submitted score $score');
    } catch (e) {
      debugPrint('GamesServices submitScore failed: $e');
    }
  }

  /// Show platform leaderboard UI.
  Future<void> showLeaderboards() async {
    if (!_isSignedIn) {
      await _trySignInAndShowLeaderboards();
      return;
    }
    try {
      await Leaderboards.showLeaderboards(
        iOSLeaderboardID: _iosLeaderboardId,
        androidLeaderboardID: _androidLeaderboardId,
      );
    } catch (e) {
      debugPrint('GamesServices showLeaderboards failed: $e');
    }
  }

  Future<void> _trySignInAndShowLeaderboards() async {
    try {
      await GameAuth.signIn();
      _isSignedIn = await GameAuth.isSignedIn;
      if (_isSignedIn) {
        await Leaderboards.showLeaderboards(
          iOSLeaderboardID: _iosLeaderboardId,
          androidLeaderboardID: _androidLeaderboardId,
        );
      }
    } catch (e) {
      debugPrint('GamesServices sign-in/leaderboards failed: $e');
    }
  }
}
