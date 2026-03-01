// Color Sequence Game (Simon Says-style) — Flutter app entry point.
//
// Bootstrap: initializes [SettingsService] and [GameStatsService], then runs
// [MyApp] with dependency injection. Services are passed down; no globals
// except [GamesServicesController.instance].
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/screens/initial_screen.dart';
import 'package:tap_dash/services/audio_service_interface.dart';
import 'package:tap_dash/services/game_stats_service.dart';
import 'package:tap_dash/services/games_services_controller.dart';
import 'package:tap_dash/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsService = await SettingsService.create();
  final gameStatsService = await GameStatsService.create();
  runApp(MyApp(
    settingsService: settingsService,
    gameStatsService: gameStatsService,
  ));
}

/// Root widget: MaterialApp with theme, localization, and [InitialScreen] home.
/// Listens to [SettingsService] for theme changes.
class MyApp extends StatefulWidget {
  const MyApp({
    required this.settingsService,
    required this.gameStatsService,
    this.locale,
    this.audioService,
    super.key,
  });

  final SettingsService settingsService;
  final GameStatsService gameStatsService;

  /// Optional locale override for testing.
  final Locale? locale;

  /// Optional audio service for testing (avoids FlutterSound in tests).
  final AudioServiceInterface? audioService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.settingsService.settings.addListener(_onSettingsChanged);
    Future.microtask(() => GamesServicesController.instance.initialize());
  }

  @override
  void dispose() {
    widget.settingsService.settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final themeMode = widget.settingsService.current.themeMode;
    return MaterialApp(
      title: 'Color Sequence Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
        ),
        cardColor: Colors.grey[850],
        dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
      ),
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: widget.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      home: InitialScreen(
        settingsService: widget.settingsService,
        gameStatsService: widget.gameStatsService,
        audioService: widget.audioService,
      ),
    );
  }
}
