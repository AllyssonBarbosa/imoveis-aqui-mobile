---
id: 260922-jk3
slug: reescrever-o-readme-md-do-projeto-hoje-b
type: quick
status: complete
tags: [docs, readme]
key-files:
  modified:
    - README.md
completed: 2026-09-22
---

# Quick Task 260922-jk3: Rewrite README.md Summary

Replaced the default `flutter create` boilerplate README with a Portuguese README describing
the "Imóveis Aqui — App (Vitrine)" project, environment setup, run/test commands, location
permission behavior, and a short architecture note — documentation only, no source changes.

## What Was Done

Rewrote `README.md` in full, following the section outline in Tarefa 1 of the plan exactly:

1. Title and short description — project purpose, APP01–APP03 scope, no-business-logic-on-device rule.
2. Prerequisites — Flutter 3.47.5 stable / Dart 3.13.4, macOS M1 install options (official installer or `brew install --cask flutter`), Android/iOS device or emulator requirement, `flutter doctor`.
3. Environment setup — `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`.
4. Running the app — `flutter run`.
5. Tests and analysis — `flutter test` (53 tests per plan), `flutter analyze`.
6. Location permission — Android manifest permissions (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`), iOS `NSLocationWhenInUseUsageDescription`, priming-screen CTA gating and manual-city fallback.
7. Architecture note — Clean Architecture layers (`lib/data/`, `lib/domain/`, `lib/presentation/`), Cubit/freezed/Result/get_it-injectable stack, Portuguese code language convention.

Facts were cross-checked against `pubspec.yaml` (Dart SDK `^3.13.4`, package versions),
`android/app/src/main/AndroidManifest.xml` (location permissions), and
`ios/Runner/Info.plist` (`NSLocationWhenInUseUsageDescription`) before writing — no invented
commands or dependencies.

## Deviations from Plan

None - plan executed exactly as written.

## Verification

- `README.md` no longer contains "A new Flutter project" (grep count: 0).
- Contains all required commands: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter run`, `flutter test`, `flutter analyze`, `brew install --cask flutter`.
- Entire document is in Portuguese.
- Only `README.md` was modified; no files under `lib/`, `test/`, `pubspec.yaml`, `android/`, or `ios/` were touched.

## Commit

- `248ad52`: docs(quick-260922-jk3): rewrite README with environment setup and run instructions

## Self-Check: PASSED

- FOUND: README.md (exists, contains expected content)
- FOUND: 248ad52 (commit exists in git log)
