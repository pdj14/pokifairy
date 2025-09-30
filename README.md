# PokiFairy

Pocket fairy companion scaffold built with Flutter 3.35, Riverpod, and GoRouter.

## Getting Started

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

- Requires Flutter stable (>= 3.35) with Dart 3.9.
- Assets are optional; `SafeLottie`/fallback icons prevent crashes when missing.

## Project Structure

```
lib/
  app/            # Theme + router definitions
  features/       # Feature-specific UI (home, care, journal, settings, onboarding)
  shared/         # Models, providers, widgets, utilities
  l10n/           # Localisation ARB files
  test/           # Widget & unit tests
```

## Key Dependencies

- `flutter_riverpod` for state management (`AsyncNotifier`, `Notifier`)
- `go_router` for typed navigation
- `shared_preferences` for persistence layer
- `google_fonts` for Noto Sans KR typography
- `lottie` for animation placeholders / safe fallbacks

## TODO / Future Work

- [ ] Migrate storage from `shared_preferences` to Hive for fairy profile + care log persistence (`lib/shared/providers/fairy_providers.dart`).
- [ ] Expand journal with historical stats and charts once Hive history is available (`lib/features/journal/journal_page.dart`).
- [ ] Integrate on-device inference (NCNN/CoreML) to drive fairy mood predictions (`lib/shared/model/growth_rules.dart`).
- [ ] Replace placeholder Lottie and icon assets with production art.
- [ ] Persist settings toggles (theme follow, high-res) via local storage.

## Notes

- The app listens for `AppLifecycleState.resumed` in `lib/main.dart` to re-tick fairy stats when returning to the foreground.
- All primary actions include semantic labels and tooltips for accessibility.
- Tests cover widget smoke run and growth-rule unit clamping/level logic.
