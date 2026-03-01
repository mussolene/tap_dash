# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Difficulty setting: 4, 6, or 8 color cubes (Settings → Difficulty)
- Demo mode: tap cubes before game start to play sounds only (no score impact)

### Changed

- Upgrade Kotlin to 1.9.25 for games_services compatibility
- Raise macOS deployment target to 11.0 for games_services

## [1.1.0] - 2025-02-28

### Added

- Flutter-focused .gitignore
- Full CI builds: Android, iOS, Web, Linux, macOS, Windows
- Conventional Commits (commitlint)
- Release workflow: builds and GitHub Release on tag push (v*)
- cliff.toml for changelog generation
- InitialScreen: routes to OnboardingScreen or GameScreen based on first-launch flag
- OnboardingScreen: "How to play" welcome on first launch
- SettingsScreen: sound, haptics, theme (accessed from GameScreen)
- GameStatsService: high score, games played, onboarding flag persistence
- GamesServicesController: Game Center (iOS) / Play Games (Android) leaderboard integration

## [1.0.0] - 2025-02-28

### Added

- Color Sequence Game (Simon Says-style memory game)
- 4-color grid with synthesized xylophone notes
- Haptic feedback (vibration)
- Milestone celebration every 5 points (badge + melody)
- Light/dark theme support
- Localization: English and Russian
- Modular architecture: screens, widgets, services, game logic
- Unit tests for game logic
- Widget tests for game UI
- GitHub Actions CI (analyze, test)
- AGENTS.md and .cursor/rules for AI-assisted development

### Changed

- Removed unused dependencies (audioplayers, flame)
- Replaced MP3 assets with synthesized audio
- Extracted GameState for testable logic
- Replaced global audio player with AudioService
