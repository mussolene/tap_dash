# Contributing to tap_dash

## Development Setup

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter analyze` and `flutter test` to verify

## Conventional Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/). Format:

```
<type>(<scope>): <description>

[optional body]
[optional footer]
```

**Types:** feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

**Examples:**
- `feat: add high score persistence`
- `fix: correct sequence playback timing`
- `docs: update README installation steps`

## Making Changes

- Follow the project's Dart/Flutter style (see `.cursor/rules/`)
- Add tests for new logic in `lib/game/` or `lib/services/`
- Add or update localization strings in `lib/l10n/app_en.arb` and `app_ru.arb`

## Submitting Changes

1. Ensure `flutter analyze` passes
2. Ensure `flutter test` passes
3. Use conventional commit messages
4. Update CHANGELOG.md if appropriate
5. Open a pull request
