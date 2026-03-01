import 'package:shared_preferences/shared_preferences.dart';

const _keyHighScore = 'high_score';
const _keyGamesPlayed = 'games_played';
const _keyHasSeenOnboarding = 'has_seen_onboarding';

/// Service for persisting and retrieving game statistics.
class GameStatsService {
  GameStatsService._(SharedPreferences prefs)
      : _prefs = prefs,
        _highScore = prefs.getInt(_keyHighScore) ?? 0,
        _gamesPlayed = prefs.getInt(_keyGamesPlayed) ?? 0,
        _hasSeenOnboarding = prefs.getBool(_keyHasSeenOnboarding) ?? false;

  final SharedPreferences _prefs;
  int _highScore;
  int _gamesPlayed;
  bool _hasSeenOnboarding;

  int get highScore => _highScore;
  int get gamesPlayed => _gamesPlayed;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  static Future<GameStatsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return GameStatsService._(prefs);
  }

  /// Records a game result. Returns true if this was a new record.
  Future<bool> recordGame(int score) async {
    _gamesPlayed++;
    await _prefs.setInt(_keyGamesPlayed, _gamesPlayed);

    final wasNewRecord = score > _highScore;
    if (wasNewRecord) {
      _highScore = score;
      await _prefs.setInt(_keyHighScore, _highScore);
    }
    return wasNewRecord;
  }

  Future<void> setHasSeenOnboarding() async {
    if (_hasSeenOnboarding) return;
    _hasSeenOnboarding = true;
    await _prefs.setBool(_keyHasSeenOnboarding, true);
  }
}
