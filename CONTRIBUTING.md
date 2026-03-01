# Contributing to tap_dash

## Development Setup

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter analyze` and `flutter test` to verify

## Conventional Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/). All commits must follow this format so that CHANGELOG can be generated automatically.

### Format

```
<type>(<scope>): <description>

[optional body]
[optional footer]
```

### Types

| Type       | Description                    |
|------------|--------------------------------|
| `feat`     | New feature                    |
| `fix`      | Bug fix                        |
| `docs`     | Documentation only             |
| `style`    | Code style (formatting, etc.)   |
| `refactor` | Code change, no feature/fix     |
| `perf`     | Performance improvement        |
| `test`     | Adding or updating tests       |
| `build`    | Build system, dependencies     |
| `ci`       | CI configuration               |
| `chore`    | Other changes (no code change)  |
| `revert`   | Revert a previous commit       |

### Examples

- `feat: add high score persistence`
- `fix: correct sequence playback timing`
- `docs: update README installation steps`
- `feat(game): add difficulty levels`

## CHANGELOG

CHANGELOG is generated from conventional commits using [git-cliff](https://git-cliff.org/). Configuration: `cliff.toml`.

### During release

When you push a tag (`v*`), the release workflow runs `git cliff` and uses the generated changelog as the GitHub Release body. No manual CHANGELOG edit is needed for releases.

### Local generation

To preview or update `CHANGELOG.md` locally:

```bash
# Install git-cliff (e.g. via cargo)
cargo install git-cliff

# Generate full changelog
git cliff -o CHANGELOG.md

# Generate changelog for next release (unreleased commits)
git cliff --unreleased -o CHANGELOG.md --prepend
```

### Releasing

1. Ensure all changes are merged and conventional commits are used
2. Update version in `pubspec.yaml` to match the release (optional — release builds use the tag):
   ```bash
   ./scripts/set_version_from_tag.sh v1.2.0
   ```
3. Commit, then push a tag: `git tag v1.2.0 && git push origin v1.2.0`
4. The release workflow builds all platforms with `--build-name` and `--build-number` from the tag, and creates a GitHub Release with auto-generated changelog

**Versioning:** Release builds derive version from the git tag (e.g. `v1.2.0` → version `1.2.0`, build number from semver). The tag is the source of truth for releases.

## Making Changes

- Follow the project's Dart/Flutter style (see `.cursor/rules/`)
- Add tests for new logic in `lib/game/` or `lib/services/`; **coverage for `lib/` must stay ≥90%**
- Add or update localization strings in `lib/l10n/app_en.arb` and `app_ru.arb`

## Submitting Changes

1. Ensure `flutter analyze` passes
2. Ensure `flutter test` passes
3. Check coverage: run `flutter test --coverage`; coverage for `lib/` must be ≥90% (CI enforces this)
4. Use conventional commit messages (commitlint checks on PR)
5. Open a pull request
